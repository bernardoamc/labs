#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/input.txt").unwrap();
}

#[derive(Debug)]
enum Direction {
    Forward(i64),
    Up(i64),
    Down(i64),
}

impl From<&str> for Direction {
    fn from(line: &str) -> Self {
        let mut parts = line.split_ascii_whitespace();
        let direction = parts.next().expect("No direction detected");
        let value = parts
            .next()
            .expect("No value detected")
            .parse::<i64>()
            .expect("Value could not be converted");

        match direction {
            "forward" => Direction::Forward(value),
            "up" => Direction::Up(value),
            "down" => Direction::Down(value),
            _ => panic!("Invalid direction"),
        }
    }
}

#[derive(Debug, Default)]
struct Submarine {
    horizontal: i64,
    depth: i64,
    aim: i64,
}

impl Submarine {
    fn part1(&mut self, instructions: &[Direction]) {
        for instruction in instructions {
            match instruction {
                Direction::Forward(value) => self.horizontal += value,
                Direction::Up(value) => self.depth -= value,
                Direction::Down(value) => self.depth += value,
            }
        }
    }

    fn part2(&mut self, instructions: &[Direction]) {
        for instruction in instructions {
            match instruction {
                Direction::Forward(value) => {
                    self.horizontal += value;
                    self.depth += self.aim * value;
                }
                Direction::Up(value) => self.aim -= value,
                Direction::Down(value) => self.aim += value,
            }
        }
    }

    fn total(&self) -> i64 {
        self.horizontal * self.depth
    }
}

fn main() {
    let lines = FILE_CONTENTS.lines();
    let instructions = lines.map(|line| line.into()).collect::<Vec<Direction>>();
    let mut submarine_1 = Submarine::default();
    let mut submarine_2 = Submarine::default();
    submarine_1.part1(&instructions);
    submarine_2.part2(&instructions);

    println!("Part 1: {}", submarine_1.total());
    println!("Part 2: {}", submarine_2.total());
}
