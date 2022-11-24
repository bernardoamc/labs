use std::collections::HashMap;
use crate::frequency;

pub struct NgramParser<'t> {
    text: &'t str,
}

impl<'t> NgramParser<'t> {
    pub fn new(text: &'t str) -> Self {
        NgramParser { text }
    }

    pub fn compute(&self, len: usize) -> Option<Vec<&str>> {
        let mut ngrams = Vec::new();

        for word in self.text.split_ascii_whitespace() {
            if word.len() < len {
                continue;
            }

            let word_boundary = word.len() - len + 1;

            for i in 0..word_boundary {
                ngrams.push(&word[i..i + len]);
            }
        }

        match ngrams.is_empty() {
            true => None,
            false => Some(ngrams),
        }
    }

    // The current assumption is that there are no whitespaces in the text.
    pub fn compute_common(&self, len: usize) -> Option<HashMap<&str, Vec<usize>>> {
        if self.text.len() < len {
            return None;
        }

        let mut ngrams: HashMap<&str, Vec<usize>> = HashMap::new();
        let text_boundary = self.text.len() - len + 1;

        for i in 0..text_boundary {
            ngrams
                .entry(&self.text[i..i + len])
                .and_modify(|positions| positions.push(i))
                .or_insert_with(|| vec![i]);
        }

        ngrams
            .into_iter()
            .filter(|(_, positions)| positions.len() > 1)
            .collect::<HashMap<&str, Vec<usize>>>()
            .into()
    }

    pub fn score(&self, len: usize) -> f64 {
        let ngrams = self.compute(len);

        if ngrams.is_none() {
            return 0.0;
        }

        ngrams.unwrap().iter().fold(0.0, |acc, ngram| {
            acc + frequency::fetch(ngram)
        })
    }
}
