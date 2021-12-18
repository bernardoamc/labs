use itertools::Itertools;
use std::iter;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

static MAXIMUM_DEPTH: u32 = 4;

#[derive(Debug, Clone, Copy, PartialEq)]
enum Token {
    Open,
    Close,
    Value(u32),
}

fn parse(line: &str) -> Vec<Token> {
    line.chars()
        .filter_map(|c| match c {
            '[' => Some(Token::Open),
            ']' => Some(Token::Close),
            _ => c.to_digit(10).map(Token::Value),
        })
        .collect()
}

fn reduce_expression(tokens: &mut Vec<Token>) -> bool {
    let mut depth = 0;

    for i in 0..tokens.len() {
        let token = tokens[i];

        match token {
            Token::Open => depth += 1,
            Token::Close => depth -= 1,
            _ => {}
        }

        if depth > MAXIMUM_DEPTH && token == Token::Open {
            if let [Token::Open, Token::Value(left), Token::Value(right), Token::Close] =
                tokens[i..i + 4]
            {
                return explode_expression(tokens, i, left, right);
            }
        }
    }

    for i in 0..tokens.len() {
        let token = tokens[i];

        if let Token::Value(value) = token {
            if value >= 10 {
                return split_expression(tokens, i, value);
            }
        }
    }

    false
}

fn explode_expression(tokens: &mut Vec<Token>, pos: usize, left: u32, right: u32) -> bool {
    tokens.splice(pos..pos + 4, iter::once(Token::Value(0)));

    let target = tokens[..pos].iter_mut().rev().find(|t| match t {
        Token::Value(_) => true,
        _ => false,
    });

    if let Some(Token::Value(left_target)) = target {
        *left_target += left;
    }

    let target = tokens[pos + 1..].iter_mut().find(|t| match t {
        Token::Value(_) => true,
        _ => false,
    });

    if let Some(Token::Value(right_target)) = target {
        *right_target += right;
    }

    true
}

fn split_expression(tokens: &mut Vec<Token>, pos: usize, value: u32) -> bool {
    tokens.splice(
        pos..=pos,
        [
            Token::Open,
            Token::Value(value / 2),
            Token::Value((value + 1) / 2),
            Token::Close,
        ],
    );

    true
}

fn add<L, R>(left: L, right: R) -> Vec<Token>
where
    L: Iterator<Item = Token>,
    R: Iterator<Item = Token>,
{
    let mut tokens: Vec<Token> = iter::once(Token::Open)
        .chain(left)
        .chain(right)
        .chain(iter::once(Token::Close))
        .collect();

    while reduce_expression(&mut tokens) {}

    tokens
}

fn calculate_magnitude<I>(tokens: &mut I) -> Option<u32>
where
    I: Iterator<Item = Token>,
{
    match tokens.next()? {
        Token::Open => {
            let left = calculate_magnitude(tokens)?;
            let right = calculate_magnitude(tokens)?;

            match tokens.next()? {
                Token::Close => Some(3 * left + 2 * right),
                _ => None,
            }
        }
        Token::Value(value) => Some(value),
        _ => None,
    }
}

fn main() {
    let snailfish_numbers = FILE_CONTENTS.trim().lines().map(parse);

    let magnitude = snailfish_numbers
        .clone()
        .reduce(|left, right| add(left.into_iter(), right.into_iter()))
        .and_then(|tokens| calculate_magnitude(&mut tokens.into_iter()));

    let maximum_magnitude = snailfish_numbers
        .permutations(2)
        .map(|tuple| {
            let sn1 = tuple[0].clone();
            let sn2 = tuple[1].clone();

            calculate_magnitude(&mut add(sn1.into_iter(), sn2.into_iter()).into_iter()).unwrap_or(0)
        })
        .max();

    println!("Part 1: {}", magnitude.unwrap());
    println!("Part 2: {}", maximum_magnitude.unwrap());
}
