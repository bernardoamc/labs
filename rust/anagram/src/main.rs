
use std::collections::HashSet;
use std::iter::FromIterator;

fn anagrams_for<'a>(word: &str, possible_anagrams: &[&'a str]) -> HashSet<&'a str> {
    let sorted_word = sort_by_letter(
        &word.to_lowercase()
    );

    possible_anagrams
        .iter()
        .filter(|possibility| sort_by_letter(&possibility.to_lowercase()) == sorted_word)
        .map(|anagram| *anagram)
        .collect()
    
}

fn sort_by_letter(word: &str) -> String {
    let mut sorted: Vec<char> = word.chars().collect();
    sorted.sort();
    sorted.into_iter().collect()
}

fn main() {
    let word = "allergy";

    let inputs = [
        "gallery",
        "ballerina",
        "regally",
        "clergy",
        "largely",
        "leading",
    ];

    let output = anagrams_for(&word, &inputs);
    let correct_output = vec!["gallery", "regally", "largely"];
    let expected: HashSet<&str> = HashSet::from_iter(correct_output.iter().cloned());

    assert_eq!(output, expected);
}
