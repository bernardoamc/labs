use std::collections::HashSet;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

fn part1(input: &str) -> i32 {
    input
        .lines()
        .map(|line| line.split('|').last().unwrap().trim())
        .map(|output| {
            output
                .split_ascii_whitespace()
                .fold(0, |acc, digit_code| match digit_code.len() {
                    2 | 3 | 4 | 7 => acc + 1,
                    _ => acc,
                })
        })
        .sum()
}

fn common_with(pattern: &HashSet<char>, s: &str) -> usize {
    s.chars()
        .fold(0, |acc, c| if pattern.contains(&c) { acc + 1 } else { acc })
}

fn decode(digit: &str, one_pattern: &HashSet<char>, four_pattern: &HashSet<char>) -> i32 {
    match (
        digit.len(),
        common_with(one_pattern, digit),
        common_with(four_pattern, digit),
    ) {
        (2, 2, 2) => 1,
        (5, 1, 2) => 2,
        (5, 2, 3) => 3,
        (4, 2, 4) => 4,
        (5, 1, 3) => 5,
        (6, 1, 3) => 6,
        (3, 2, 2) => 7,
        (7, 2, 4) => 8,
        (6, 2, 4) => 9,
        (6, 2, 3) => 0,
        (_, _, _) => panic!("Invalid digit segment"),
    }
}

fn part2(input: &str) -> i32 {
    let lines: Vec<(&str, &str)> = input
        .lines()
        .map(|l| {
            let s = l.split("|").map(|s| s.trim()).collect::<Vec<_>>();
            (s[0], s[1])
        })
        .collect();

    let mut total = 0;

    for (segments, digits) in lines {
        let mut one_pattern = HashSet::new();
        let mut four_pattern = HashSet::new();

        for segment in segments.split_ascii_whitespace() {
            let segment = segment.trim();

            match segment.len() {
                2 => one_pattern = segment.chars().collect::<HashSet<_>>(),
                4 => four_pattern = segment.chars().collect::<HashSet<_>>(),
                _ => (),
            }
        }

        let decoded_value = digits
            .split_ascii_whitespace()
            .map(|digit| decode(digit, &one_pattern, &four_pattern))
            .fold(0, |acc, value| acc * 10 + value);

        total += decoded_value;
    }

    total
}

fn main() {
    println!("Part 1: {}", part1(&FILE_CONTENTS));
    println!("Part 2: {}", part2(&FILE_CONTENTS));
}
