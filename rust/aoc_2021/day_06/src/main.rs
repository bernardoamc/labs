use std::collections::VecDeque;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/input.txt").unwrap();
}

pub fn compute(input: &str, iterations: u64) -> u64 {
    let fish = input
        .trim()
        .split(',')
        .fold(VecDeque::from([0; 9]), |mut fish, timer| {
            fish[timer.parse::<usize>().unwrap()] += 1;
            fish
        });

    nth_iteration(fish, iterations)
}

fn nth_iteration(fish: VecDeque<u64>, iterations: u64) -> u64 {
    (0..iterations)
        .fold(fish, |mut fish, _| {
            fish.rotate_left(1);
            fish[6] += fish[8];
            fish
        })
        .iter()
        .sum()
}
fn main() {
    println!("Part 1: {}", compute(&FILE_CONTENTS, 80));
    println!("Part 2: {}", compute(&FILE_CONTENTS, 256));
}
