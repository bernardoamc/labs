#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/input.txt").unwrap();
}

fn part1(depths: &[i32]) -> usize {
    depths.windows(2).filter(|d| d[1] > d[0]).count()
}

fn part2(depths: &[i32]) -> usize {
    depths.windows(4).filter(|d| d[3] > d[0]).count()
}

fn main() {
    let lines = FILE_CONTENTS.lines();
    let measurements = lines
        .map(|line| line.parse::<i32>().unwrap())
        .collect::<Vec<i32>>();

    println!("Part 1: {}", part1(&measurements));
    println!("Part 2: {}", part2(&measurements));
}
