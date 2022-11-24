use std::ops::RangeInclusive;
use std::collections::{HashMap, HashSet};
use std::collections::BinaryHeap;
use rayon::prelude::*;
use crate::ngram_parser::NgramParser;
use crate::frequency;

type Size = usize;
type Distance = usize;
type Key = String;
type Plaintext = String;
type Score = f64;

const KEYS_TO_CONSIDER: usize = 5;

const ALPHABET_LOWER_RANGE: RangeInclusive<u8> = 97..=122;
const ALPHABET_UPPER_RANGE: RangeInclusive<u8> = 65..=90;
const ALPHABET_RANGE: u8 = 26;
const NONALPHABETIC_ERROR: &str = "Key must only contain alphabetic characters";

pub struct Vigenere {
    key: String,
}

impl Vigenere {
    pub fn new(key: &str) -> Result<Self, String> {
        if has_invalid_characters(key) {
            return Err(NONALPHABETIC_ERROR.to_string());
        }

        Ok(Vigenere { key: key.to_string() })
    }

    pub fn encrypt(&self, plaintext: &str) -> Result<String, String> {
        if has_invalid_characters(plaintext) {
            return Err(NONALPHABETIC_ERROR.to_string());
        }

        let mut key_iter = self.key.chars().cycle();

        Ok(plaintext.chars().map(|plaintext_char| {
            let key_char = key_iter.next().unwrap();
            let ciphertext_index = (index_for(plaintext_char) + index_for(key_char)) % ALPHABET_RANGE;

            char_for(ciphertext_index, plaintext_char.is_uppercase())
        }).collect())
    }

    pub fn decrypt(&self, ciphertext: &str) -> Result<String, String> {
        if has_invalid_characters(ciphertext) {
            return Err(NONALPHABETIC_ERROR.to_string());
        }

        let mut key_iter = self.key.chars().cycle();

        Ok(ciphertext.chars().map(|ciphertext_char| {
            let key_char = key_iter.next().unwrap();
            let plaintext_index = index_for(ciphertext_char) as i16 - index_for(key_char) as i16;
            let plaintext_index = plaintext_index.rem_euclid(ALPHABET_RANGE as i16) as u8;

            char_for(plaintext_index, ciphertext_char.is_uppercase())
        }).collect())
    }

    pub fn decrypt_without_key(cipher: &str) -> Vec<(Key, Plaintext)> {
        let mut suggestions: Vec<(Key, Plaintext)> = Vec::new();
        let mut cache = HashSet::new();

        let mut plaintexts: Vec<(Key, Score, Score, Plaintext)> = kasiski(cipher)
            .par_iter()
            .map(|key_length| Vigenere::decrypt_with_key_len(cipher, *key_length))
            .flatten()
            .map(|(key, plaintext)| {
                let parser = NgramParser::new(&plaintext);
                (key, parser.score(2), parser.score(3), plaintext)
            })
            .collect();

        plaintexts.sort_by(|(_, bigram1, _, _), (_, bigram2, _, _)| bigram2.partial_cmp(bigram1).unwrap());

        plaintexts.iter().take(2).for_each(|(key, _, _, plaintext)| {
            suggestions.push((key.to_string(), plaintext.to_string()));
            cache.insert(key.to_string());
        });

        plaintexts.sort_by(|(_, _, trigram1, _), (_, _, trigram2, _)| trigram2.partial_cmp(trigram1).unwrap());

        plaintexts.iter().take(2).for_each(|(key, _, _, plaintext)| {
            if !cache.contains(key) {
                suggestions.push((key.to_string(), plaintext.to_string()));
            }
        });

        suggestions
    }

    // Decrypt the ciphertext using a guessed key length and return potential keys scored by letter frequency analysis.
    pub fn decrypt_with_key_len(cipher: &str, key_length: usize) -> Vec<(Key, Plaintext)> {
        let mut monoalphabetic_ciphers: Vec<Vec<char>> = Vec::new();
        let mut keys: Vec<Vec<char>> = Vec::new();

        monoalphabetic_ciphers.resize(key_length, Vec::new());
        keys.resize(KEYS_TO_CONSIDER, Vec::new());

        for (i, c) in cipher.chars().enumerate() {
            monoalphabetic_ciphers[i % key_length].push(c);
        }

        // Building the top likely keys to consider for each monoalphabetic cipher.
        // Each decrypted monoalphabet cipher will provide one character for our final key.
        let monoalphabetic_ciphers: Vec<Vec<(char, Score)>> = monoalphabetic_ciphers
            .par_iter()
            .map(|monoalphabetic_cipher| scored_decryption_candidates(monoalphabetic_cipher, KEYS_TO_CONSIDER))
            .collect();

        monoalphabetic_ciphers.iter().for_each(|candidates| {
            candidates.iter().enumerate().for_each(|(index, (c, _))| keys[index].push(*c));
        });

        keys.iter().map(|key| {
            let key = key.iter().collect::<String>();
            let vigenere = Vigenere::new(&key).unwrap();
            (key, vigenere.decrypt(cipher).unwrap())
        }).collect()
    }
}

fn has_invalid_characters(source: &str) -> bool {
    source.chars().any(|c| { !c.is_ascii_alphabetic() })
}

fn index_for(c: char) -> u8 {
    let ascii_code = c as u8;

    if ALPHABET_LOWER_RANGE.contains(&ascii_code) {
        ascii_code - ALPHABET_LOWER_RANGE.start()
    } else {
        ascii_code - ALPHABET_UPPER_RANGE.start()
    }
}

fn char_for(index: u8, is_uppercase: bool) -> char {
    if is_uppercase {
        (ALPHABET_UPPER_RANGE.start() + index) as char
    } else {
        (ALPHABET_LOWER_RANGE.start() + index) as char
    }
}

// We are going to use a pretty simple heuristic to guess the key by iterating over our alphabet, decrypting with each
// letter in the alphabet and doing a frequency analysis by letter in the plaintext. Ideally we should also consider
// bigrams, trigrams and even quadrigrams in our analysis.
//
// We will return the top N candidates for the key.
fn scored_decryption_candidates(cipher: &[char], top: usize) -> Vec<(char, Score)> {
    let cipher = cipher.iter().collect::<String>();

    let mut candidates: Vec<(char, Score)> = (b'a'..=b'z').map(|c| {
        let letter = String::from(c as char);
        let vigenere = Vigenere::new(&letter).unwrap();
        let decrypted = vigenere.decrypt(&cipher).unwrap();

        let score = decrypted.chars().fold(0.0, |acc, decrypted_char| {
            acc + frequency::fetch(&String::from(decrypted_char))
        });

        (c as char, score)
    }).collect();

    candidates.sort_by(|(_, a), (_, b)| b.partial_cmp(a).unwrap());

    candidates.into_iter().take(top).collect()
}

// We are taking the lazy way out here. Here's the plan:
//
// 1. Split the cipher into ngrams starting at N = 10 and going
//    down to N = 3.
// 2. Iterate through ngrams:
//    - Search for matching ngrams from different positions within the cipher.
//    - Check if we have seem these positions before with bigger ngrams.
//    - If not calculate the distance between the positions and also cache these positions.
//    - Keep track of the most common distances and biggest ngrams found
//
// Returns the most likely key length in the cipher by considering in order:
//   1. GCD between distances between matching ngrams.
//   2. The factors of the most common distance between matching ngrams.
//   3. The biggest two ngram sizes
fn kasiski(cipher: &str) -> HashSet<usize> {
    let mut candidates: HashSet<usize> = HashSet::new();
    let mut cache: HashSet<(usize, usize)> = HashSet::new();
    let mut matching_ngrams: HashMap<Size, Vec<Distance>> = HashMap::new();
    let mut distances_map: HashMap<Distance, usize> = HashMap::new();
    let mut ngrams_heap: BinaryHeap<Size> = BinaryHeap::new();
    let ngram_parser = NgramParser::new(cipher);

    for ngram_size in (3..=10).rev() {
        let ngrams = ngram_parser.compute_common(ngram_size).unwrap_or_default();

        for positions in ngrams.values() {
            ngrams_heap.push(ngram_size);

            for (i, position) in positions.iter().enumerate() {
                for other_position in positions[i + 1..].iter() {
                    if cache.contains(&(*position, *other_position)) {
                        continue;
                    }

                    // We need to consider that larger ngrams will also be matched by smaller ngrams, so we need to
                    // invalidate the entire range of positions of new ngrams. See the example below for more details.
                    //
                    // "abcde1234abcde" will have matching ngrams for "abcde", but will also have ngrams for:
                    //     - "abcd" and "bcde"
                    //     - "abc" and "bcd" and "cde"
                    //     - "ab" and "bc" and "cd" and "de"
                    for i in 1..ngram_size {
                        cache.insert((*position + i, *other_position + i));
                    }

                    cache.insert((*position, *other_position));
                    let distance = position.abs_diff(*other_position);

                    distances_map
                        .entry(distance)
                        .and_modify(|count| *count += 1)
                        .or_insert(1);

                    matching_ngrams
                        .entry(ngram_size)
                        .and_modify(|distances| distances.push(distance))
                        .or_insert_with(|| vec![distance]);

                }
            }
        }
    }

    // Now we can try to find a common factor between the computed distances.
    let distances = matching_ngrams.values().flatten().collect::<Vec<_>>();
    let gcd = multi_gcd(&distances);

    if gcd > 1 {
        candidates.insert(gcd);
    }

    // The most common distance might also be a good indication of the key length.
    let most_common_distance = distances_map
        .into_iter()
        .max_by(|(_, count_a), (_, count_b)| count_a.cmp(count_b))
        .expect("No distances between commom ngrams found")
        .0;

    // We can also try to find the factors of the most common distance.
    get_factors(most_common_distance).into_iter().for_each(|n| { candidates.insert(n); });

    // Last but not least we can try to use the two biggest ngrams lengths as a key length.
    ngrams_heap
        .into_iter()
        .take(2)
        .for_each(|n| { candidates.insert(n);});

    candidates
}

fn multi_gcd(nums: &[&usize]) -> usize {
    if nums.len() == 1 {
        return *nums[0];
    }

    let a = *nums[0];
    let b = multi_gcd(&nums[1..]);

    gcd(a, b)
}

fn gcd(a: usize, b: usize) -> usize {
    if b == 0 {
        return a;
    }

    gcd(b, a % b)
}

fn get_factors(n: usize) -> Vec<usize> {
    let root = (n as f64).sqrt() as usize;
    (2..=root).into_iter().filter(|&x| n % x == 0).collect::<Vec<usize>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_rejects_keys_containing_non_alphabetic_characters() {
        assert!(Vigenere::new("abc123").is_err());
    }

    #[test]
    fn it_allows_keys_with_only_alphabetic_characters() {
        assert!(Vigenere::new("caesar").is_ok());
    }

    #[test]
    fn it_rejects_plaintexts_containing_non_alphabetic_characters() {
        let cipher = Vigenere::new("caesar").unwrap();
        assert!(cipher.encrypt("abc123").is_err());
    }


    #[test]
    fn it_successfully_encrypts_a_valid_plaintext() {
        let cipher = Vigenere::new("caesar").unwrap();
        let ciphertext = cipher.encrypt("thequickbrownfoxjumpsoverthelazydog").unwrap();
        assert_eq!(ciphertext, "vhiiuzekfjonpfspjlopwgvvttlwlrbyhgg");
    }

    #[test]
    fn it_rejects_ciphertexts_containing_non_alphabetic_characters() {
        let cipher = Vigenere::new("caesar").unwrap();
        assert!(cipher.decrypt("abc123").is_err());
    }

    #[test]
    fn it_successfully_decrypts_a_valid_ciphertext() {
        let cipher = Vigenere::new("caesar").unwrap();
        let plaintext = cipher.decrypt("vhiiuzekfjonpfspjlopwgvvttlwlrbyhgg").unwrap();
        assert_eq!(plaintext, "thequickbrownfoxjumpsoverthelazydog");
    }

    #[test]
    fn it_returns_the_most_probable_key_lengths_for_vigenere() {
        let candidates = kasiski("kkalclgqlccrefckvmpwbsurrzuzmhpwzjozfhiffbmavvfqascoksiigoibvtdsarbomsehsviuuqffvowxcesiqikwzckysdiqzjuppccaharyqwqzjupvrbpwieqxioetdsawcdxvkvqjokoxpczbestkvqwskkajcvgmtozfajgkodgffgehzfjqvgkowihysuvz");
        assert_eq!(HashSet::from_iter([3,5,4]), candidates);
    }

    #[test]
    fn it_provides_the_best_key_guesses_for_vigenere() {
        let candidates = Vigenere::decrypt_without_key("kkalclgqlccrefckvmpwbsurrzuzmhpwzjozfhiffbmavvfqascoksiigoibvtdsarbomsehsviuuqffvowxcesiqikwzckysdiqzjuppccaharyqwqzjupvrbpwieqxioetdsawcdxvkvqjokoxpczbestkvqwskkajcvgmtozfajgkodgffgehzfjqvgkowihysuvz");
        assert_eq!(vec![
            ("romeo".to_string(), "twohouseholdsbothalikeindignityinfairveronawherewelayourscenefromancientgrudgebreaktonewmutinywherecivilbloodmakescivilhandsuncleanfromforththefatalloinsofthesetwofoesapairofstarcrossdloverstaketheirl".to_string()),
            ("ocr".to_string(), "wijxausouoaaqdlwtvbukesadxdlkqbuivmirfrrdkyyehdzmqlaibugpagkhrmeyanmvecqetrgszrdeaugocbuorwuioihebrcxsgnyoajtyakofcxsgnedzyigncvraccpqjiamjtthosaixjnllznerthofeitmhlhevfmiryssixpeorentxovoesixigqkqdhx".to_string()),
            ("cwi".to_string(), "iosjgdeudagjcjuizenatqyjpdmxqznarhsrdladjtkentjiywumokgmymmttxvqejzseqizqzasyidjnmapaikguaiaraoqqhaodbsthagsfejwuoodbstnpfhumwobamilbwsugvvzctubmogvtuxfwqxctuoqocynutkersrdebeogbkxdkwfdxhuneogumzwwmtd".to_string())
        ], candidates);
    }
}
