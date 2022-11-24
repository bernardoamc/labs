pub struct ColumnarTransposition {
    key: usize,
}

impl ColumnarTransposition {
    pub fn new(key: usize) -> Self {
        ColumnarTransposition { key }
    }

    pub fn encrypt(&self, plaintext: &str) -> String {
        if self.key >= plaintext.len() {
            return plaintext.to_string();
        }

        let mut ciphertext = String::with_capacity(plaintext.len());

        for column in 0..self.key {
            plaintext.chars().skip(column).step_by(self.key).for_each(|c| ciphertext.push(c));
        }

        ciphertext
    }

    // There are a few things to be considered here:
    // 1. We need to read a character, skip the next row number of characters, and then read the next
    // 2. If a column is not completely filled, we need to detect that and only skip (row - 1) characters

    // Plaintext
    // ["a", "k", "p", "k", "n", "l", "l", "a"],
    // ["l", "e", "n", "l", "l", "n", "a", "s"],
    // ["y", "b", "w", "d", "y", "j", "a", "o"],
    // ["o", "n", "m", "o", "d", "y", "r", "o"],
    // ["a", "h", "u", nil, nil, nil, nil, nil]

    // Ciphertext
    // ["a", "l", "y", "o", "a", "k", "e", "b"],
    // ["n", "h", "p", "n", "w", "m", "u", "k"],
    // ["l", "d", "o", "n", "l", "y", "d", "l"],
    // ["n", "j", "y", "l", "a", "a", "r", "a"],
    // ["s", "o", "o", nil, nil, nil, nil, nil]
    pub fn decrypt(&self, ciphertext: &str) -> String {
        if self.key >= ciphertext.len() {
            return ciphertext.to_string();
        }

        let mut plaintext = String::with_capacity(ciphertext.len());
        let chars = ciphertext.chars().collect::<Vec<_>>();
        let incomplete_columns = (self.key - (ciphertext.len() % self.key)) % self.key;
        let rows = (ciphertext.len() + self.key - 1) / self.key;

        for row in 0..rows {
            let mut columns = self.key;

            // If the last row is incomplete, we need to fetch only the columns that are filled
            if (row + 1) == rows {
                columns -= incomplete_columns;
            }

            for column in 0..columns {
                let mut index = row + (column * rows);

                // Handling incomplete columns, now we need to calculate the
                // proper offset of the next item since we can't skip characters
                // based on the number of rows.
                if incomplete_columns > (self.key - column)   {
                    index -= incomplete_columns - (self.key - column);
                }

                if let Some(c) = chars.get(index) {
                    plaintext.push(*c);
                }
            }
        }

        plaintext
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_encrypts_for_single_transposition() {
        let cipher = ColumnarTransposition::new(2);
        assert_eq!(cipher.encrypt("abcd"), "acbd");

        let cipher = ColumnarTransposition::new(6);
        assert_eq!(cipher.encrypt("allworkandnoplaymakesjohnnyadullboy"), "akpknllalenllnasybwdyjaoonmodyroahu");
    }

    #[test]
    fn it_encrypts_for_multiple_transpositions() {
        let cipher = ColumnarTransposition::new(6);
        let ciphertext = cipher.encrypt("allworkandnoplaymakesjohnnyadullboy");
        assert_eq!(ciphertext, "akpknllalenllnasybwdyjaoonmodyroahu");

        let cipher = ColumnarTransposition::new(8);
        assert_eq!(cipher.encrypt(&ciphertext), "alyoakebnhpnwmukldonlydlnjylaarasoo");
    }

    #[test]
    fn it_decrypts_for_single_transposition() {
        let cipher = ColumnarTransposition::new(2);
        assert_eq!(cipher.decrypt("acbd"), "abcd");

        let cipher = ColumnarTransposition::new(6);
        assert_eq!(cipher.decrypt("akpknllalenllnasybwdyjaoonmodyroahu"), "allworkandnoplaymakesjohnnyadullboy");
    }

    #[test]
    fn it_decrypts_for_multiple_transpositions() {
        let cipher = ColumnarTransposition::new(8);
        let c1 = cipher.decrypt("alyoakebnhpnwmukldonlydlnjylaarasoo");
        assert_eq!(c1, "akpknllalenllnasybwdyjaoonmodyroahu");

        let cipher = ColumnarTransposition::new(6);
        assert_eq!(cipher.decrypt(&c1), "allworkandnoplaymakesjohnnyadullboy");
    }
}
