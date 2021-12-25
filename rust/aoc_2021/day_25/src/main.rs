use std::collections::HashMap;
use std::str::FromStr;
use std::string::ParseError;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

type Coordinate = (usize, usize);

#[derive(Debug, PartialEq)]
enum Direction {
    East,
    South,
}

#[derive(Debug)]
struct Sea {
    map: HashMap<Coordinate, Direction>,
    rows: usize,
    columns: usize,
}

impl Sea {
    fn move_east(&mut self) -> Option<usize> {
        let mut changes = Vec::new();

        for ((row, column), direction) in self.map.iter() {
            if *direction != Direction::East {
                continue;
            }

            let new_column = (column + 1) % self.columns;

            if !self.map.contains_key(&(*row, new_column)) {
                changes.push(((*row, *column), (*row, new_column)));
            }
        }

        if changes.is_empty() {
            return None;
        }

        for (old_coordinate, new_coordinate) in changes.iter() {
            self.map.remove(old_coordinate);
            self.map.insert(*new_coordinate, Direction::East);
        }

        Some(changes.len())
    }

    fn move_south(&mut self) -> Option<usize> {
        let mut changes = Vec::new();

        for ((row, column), direction) in self.map.iter() {
            if *direction != Direction::South {
                continue;
            }

            let new_row = (row + 1) % self.rows;

            if !self.map.contains_key(&(new_row, *column)) {
                changes.push(((*row, *column), (new_row, *column)));
            }
        }

        if changes.is_empty() {
            return None;
        }

        for (old_coordinate, new_coordinate) in changes.iter() {
            self.map.remove(old_coordinate);
            self.map.insert(*new_coordinate, Direction::South);
        }

        Some(changes.len())
    }
}

impl FromStr for Sea {
    type Err = ParseError;

    fn from_str(content: &str) -> Result<Self, Self::Err> {
        let mut map: HashMap<Coordinate, Direction> = HashMap::new();
        let rows = content.trim().lines().count();
        let columns = content.trim().lines().next().unwrap().len();

        content.trim().lines().enumerate().for_each(|(row, line)| {
            line.chars()
                .enumerate()
                .for_each(|(column, char)| match char {
                    '>' => {
                        map.insert((row, column), Direction::East);
                    }
                    'v' => {
                        map.insert((row, column), Direction::South);
                    }
                    _ => (),
                });
        });

        Ok(Self { map, rows, columns })
    }
}

fn main() {
    let mut sea = Sea::from_str(FILE_CONTENTS.trim()).unwrap();
    let mut steps = 0;

    loop {
        steps += 1;

        let east = sea.move_east();
        let south = sea.move_south();

        if east.is_none() && south.is_none() {
            break;
        }
    }

    println!("Part 1: {}", steps);
}
