#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

fn part1(input: &str) -> i32 {
    let mut positions: Vec<i32> = input
        .trim()
        .split(',')
        .map(|p| p.parse::<i32>().unwrap())
        .collect();

    let middle = positions.len() / 2;
    let median = positions.select_nth_unstable(middle).1.clone();

    positions.iter().map(|n| (n - median).abs()).sum::<i32>()
}

fn part2(input: &str) -> i32 {
    let positions: Vec<i32> = input
        .trim()
        .split(',')
        .map(|p| p.parse::<i32>().unwrap())
        .collect();

    let mean = positions.iter().sum::<i32>() / positions.len() as i32;

    (mean..=mean + 1)
        .map(|candidate| {
            positions
                .iter()
                .map(|pos| {
                    let distance = (pos - candidate).abs();
                    distance * (distance + 1) / 2
                })
                .sum::<i32>()
        })
        .min()
        .unwrap()
}

fn main() {
    println!("Part 1: {}", part1(&FILE_CONTENTS));
    println!("Part 2: {}", part2(&FILE_CONTENTS));
}
