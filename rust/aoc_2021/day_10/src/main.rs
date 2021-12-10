#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

fn parse_line(line: &str) -> (Option<char>, Vec<char>) {
    let mut stack = Vec::new();
    let mut invalid: Option<char> = None;

    for c in line.chars() {
        if c != ')' && c != ']' && c != '}' && c != '>' {
            stack.push(c);
            continue;
        }

        match (stack.last().unwrap_or(&'?'), c) {
            ('(', ')') | ('[', ']') | ('{', '}') | ('<', '>') => {
                stack.pop();
            }
            (_, ')') | (_, ']') | (_, '}') | (_, '>') => {
                invalid = Some(c);
                break;
            }
            _ => stack.push(c),
        }
    }

    (invalid, stack)
}

fn compute_incomplete_line(chars: &Vec<char>) -> u64 {
    chars.iter().rev().fold(0, |acc, c| {
        (acc * 5)
            + match c {
                '(' => 1,
                '[' => 2,
                '{' => 3,
                '<' => 4,
                _ => panic!("Unexpected character"),
            }
    })
}

fn part1(input: &str) -> u64 {
    input
        .trim()
        .lines()
        .map(|line| parse_line(line.trim()))
        .filter(|(invalid, _)| invalid.is_some())
        .fold(0, |acc, (invalid, _)| {
            acc + match invalid.unwrap() {
                ')' => 3,
                ']' => 57,
                '}' => 1197,
                '>' => 25137,
                _ => panic!("Unexpected character"),
            }
        })
}

fn part2(input: &str) -> u64 {
    let mut values: Vec<u64> = input
        .trim()
        .lines()
        .map(|line| parse_line(line.trim()))
        .filter(|(invalid, _)| invalid.is_none())
        .map(|(_, stack)| compute_incomplete_line(&stack))
        .collect();

    values.sort();
    values[(values.len() / 2)]
}

fn main() {
    println!("Part 1: {}", part1(&FILE_CONTENTS));
    println!("Part 2: {}", part2(&FILE_CONTENTS));
}
