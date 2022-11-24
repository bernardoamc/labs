use crate::ngram_parser::NgramParser;

const ALPHABET_SIZE: usize = 26;

pub struct Monoalphabetic {
    ciphertext: String,
}

impl Monoalphabetic {
    pub fn new(ciphertext: &str) -> Self {
        Monoalphabetic { ciphertext: ciphertext.to_string() }
    }

    // Tries to find the most probable plaintexts by trying all possible letter shifts and computing each score.
    pub fn decipher(&self, ngram_size: usize) -> Vec<String> {
        let candidates = (1..ALPHABET_SIZE).into_iter().map( |shift_by|
            self.ciphertext.chars().map(|c| {
                if !c.is_ascii_alphabetic() {
                    return c as char;
                }

                let ascii_code = c as u8;
                let mut shifted_code = ascii_code + shift_by as u8;

                if shifted_code > b'z' {
                    shifted_code -= ALPHABET_SIZE as u8;
                }

                shifted_code as char
            }).collect::<String>()
        );

        let mut scored_candidates = candidates.map(|candidate| {
            let ngram_parser = NgramParser::new(&candidate);
            let score = ngram_parser.score(ngram_size);
            (candidate, score)
        })
        .collect::<Vec<(String, f64)>>();

        scored_candidates.sort_by(|(_, score1), (_, score2)| score2.partial_cmp(score1).unwrap());
        scored_candidates.into_iter().map(|(candidate, _)| candidate).take(3).collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_breaks_monoalphabetic_ciphers_with_digraphs() {
        let cipher = Monoalphabetic::new("wkh fdw lq wkh kdw vwulnhv edfn");

        assert_eq!(
            cipher.decipher(2),
            ["the cat in the hat strikes back", "iwt rpi xc iwt wpi higxzth qprz", "gur png va gur ung fgevxrf onpx"]
        );
    }

    #[test]
    fn it_breaks_monoalphabetic_ciphers_with_trigrams() {
        let cipher = Monoalphabetic::new("wkh fdw lq wkh kdw vwulnhv edfn");

        assert_eq!(
            cipher.decipher(3),
            ["the cat in the hat strikes back", "xli gex mr xli lex wxvmoiw fego", "ymj hfy ns ymj mfy xywnpjx gfhp"]
        );
    }
}
