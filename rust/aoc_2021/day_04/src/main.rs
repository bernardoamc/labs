use itertools::Itertools;
use std::collections::HashMap;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/input.txt").unwrap();
}

static GRID_SIZE: usize = 5;
static GRID_POSITIONS: usize = 25;

#[derive(Clone, Debug)]
struct GridPos {
    value: u32,
    marked: bool,
}

impl GridPos {
    fn new(value: u32) -> Self {
        Self {
            value,
            marked: false,
        }
    }

    fn mark(&mut self) {
        self.marked = true;
    }
}

#[derive(Clone, Debug)]
struct Grid {
    cache: HashMap<u32, usize>,
    positions: Vec<GridPos>,
    winner: bool,
}

impl Grid {
    fn mark(&mut self, number: u32) {
        match self.cache.get(&number) {
            Some(position) => self.positions[*position].mark(),
            None => (),
        }
    }

    fn row_completed(&self, row: usize) -> bool {
        (0..GRID_SIZE).all(|column| self.positions[(row * GRID_SIZE) + column].marked)
    }

    fn column_completed(&self, column: usize) -> bool {
        (0..GRID_SIZE).all(|row| self.positions[(row * GRID_SIZE) + column].marked)
    }

    fn win(&mut self) -> Option<u32> {
        for x in 0..GRID_SIZE {
            if self.row_completed(x) || self.column_completed(x) {
                self.winner = true;

                return Some(
                    self.positions
                        .iter()
                        .filter(|pos| !pos.marked)
                        .map(|pos| pos.value)
                        .sum(),
                );
            }
        }

        None
    }
}

fn parse(lines: &[&str]) -> (Vec<u32>, Vec<Grid>) {
    let numbers: Vec<u32> = lines[0]
        .split(',')
        .map(|n| n.parse::<u32>().unwrap())
        .collect();

    let mut grids: Vec<Grid> = Vec::new();

    for grid_lines in &lines.iter().skip(1).chunks(GRID_SIZE) {
        let mut positions = Vec::with_capacity(GRID_POSITIONS);
        let mut grid_numbers = HashMap::new();

        for (row, grid_line) in grid_lines.enumerate() {
            let grid_line = grid_line.clone().trim();

            grid_line
                .split_whitespace()
                .map(|n| n.parse::<u32>().unwrap())
                .enumerate()
                .for_each(|(index, n)| {
                    positions.push(GridPos::new(n));
                    grid_numbers.insert(n, (row * GRID_SIZE) + index);
                });
        }

        grids.push(Grid {
            cache: grid_numbers,
            positions: positions,
            winner: false,
        });
    }

    (numbers, grids)
}

fn pick_winner(numbers: &mut Vec<u32>, grids: &mut Vec<Grid>, nth_winner: usize) -> Option<u32> {
    let mut winners: usize = 0;

    for number in numbers {
        for grid in grids.iter_mut() {
            if grid.winner {
                continue;
            }

            grid.mark(*number);

            if let Some(total) = grid.win() {
                winners += 1;

                if winners == nth_winner {
                    return Some(total * *number);
                }
            }
        }
    }

    None
}

fn main() {
    let lines = FILE_CONTENTS
        .lines()
        .filter(|line| !line.is_empty())
        .collect::<Vec<&str>>();

    let (mut numbers, mut grids) = parse(&lines);
    let participants = grids.len() - 1;

    println!(
        "Part 1: {}",
        pick_winner(&mut numbers, &mut grids, 1).unwrap()
    );

    println!(
        "Part 2: {}",
        pick_winner(&mut numbers, &mut grids, participants).unwrap()
    );
}
