use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashMap, HashSet};
use std::fmt::Display;
use std::hash::Hash;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

const COLUMNS: i64 = 11;
const VALID_HALLWAY_COLUMNS: [i64; 7] = [1, 2, 4, 6, 8, 10, 11];

type Coordinate = (i64, i64);

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
enum Amphipod {
    A,
    B,
    C,
    D,
}

impl Display for Amphipod {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let s = match self {
            Self::A => "A",
            Self::B => "B",
            Self::C => "C",
            Self::D => "D",
        };
        write!(f, "{}", s)
    }
}

impl Amphipod {
    fn cost(&self) -> i64 {
        match self {
            Self::A => 1,
            Self::B => 10,
            Self::C => 100,
            Self::D => 1000,
        }
    }

    fn destination_column(&self) -> i64 {
        match self {
            Self::A => 3,
            Self::B => 5,
            Self::C => 7,
            Self::D => 9,
        }
    }

    fn in_destination(&self, (row, column): Coordinate) -> bool {
        if row < 2 {
            return false;
        }

        match self {
            Self::A => column == 3,
            Self::B => column == 5,
            Self::C => column == 7,
            Self::D => column == 9,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct Game {
    cost: i64,
    amphipods: Vec<(Amphipod, Coordinate)>,
    map: HashMap<Coordinate, Amphipod>,
    room_depth: i64,
}

// Inverting since we want a min heap
impl Ord for Game {
    fn cmp(&self, other: &Self) -> Ordering {
        other.cost.cmp(&self.cost)
    }
}

impl PartialOrd for Game {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Display for Game {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        writeln!(f, "----------------")?;
        writeln!(f, "Cost: {}", self.cost)?;
        for i in 0..self.amphipods.len() {
            let (amphipod, (row, col)) = &self.amphipods[i];
            write!(f, "{}: ({},{}), ", amphipod, row, col)?;
        }
        writeln!(f)?;
        writeln!(f, "----------------")?;
        Ok(())
    }
}

impl Game {
    fn new(amphipods: Vec<(Amphipod, Coordinate)>, room_depth: i64) -> Self {
        let mut map = HashMap::new();

        for (amphipod, coordinate) in amphipods.iter() {
            map.insert(*coordinate, amphipod.clone());
        }

        Self {
            cost: 0,
            amphipods,
            map,
            room_depth,
        }
    }

    fn clone_from(&self, from: Coordinate, to: Coordinate) -> Self {
        let mut new_game = self.clone();

        for i in 0..new_game.amphipods.len() {
            let (_amphipod, coordinate) = &new_game.amphipods[i];

            if from == *coordinate {
                let amphipod = new_game.amphipods[i].0.clone();
                let cost = ((from.0 + to.0 - 2).abs() + (from.1 - to.1).abs()) * amphipod.cost();

                new_game.amphipods[i] = (amphipod.clone(), to);
                new_game.map.remove(&from);
                new_game.map.insert(to, amphipod);
                new_game.cost += cost;
                break;
            }
        }

        new_game
    }

    fn serialize(&self) -> Vec<(Amphipod, Coordinate)> {
        self.amphipods.clone()
    }

    fn in_hallway(&self, (row, _column): Coordinate) -> bool {
        row == 1
    }

    fn valid_hallway_coordinates(
        &self,
        (origin_row, origin_column): Coordinate,
    ) -> Vec<(Coordinate, Coordinate)> {
        let mut valid_positions = Vec::new();

        for step in (0..origin_column).rev() {
            if !VALID_HALLWAY_COLUMNS.contains(&step) {
                continue;
            }

            if self.map.contains_key(&(1, step)) {
                break;
            }

            valid_positions.push(((origin_row, origin_column), (1, step)));
        }

        for step in (origin_column + 1)..=COLUMNS {
            if !VALID_HALLWAY_COLUMNS.contains(&step) {
                continue;
            }

            if self.map.contains_key(&(1, step)) {
                break;
            }

            valid_positions.push(((origin_row, origin_column), (1, step)));
        }

        valid_positions
    }

    fn is_win(&self) -> bool {
        self.amphipods
            .iter()
            .all(|(amphipod, coordinate)| amphipod.in_destination(*coordinate))
    }

    fn are_amphipods_below_the_same(
        &self,
        amphipod_type: Amphipod,
        (current_row, current_column): Coordinate,
    ) -> bool {
        self.amphipods
            .iter()
            .filter(|(_, (_, column))| *column == current_column)
            .all(|(amphipod, (row, _column))| {
                *row >= current_row && amphipod_type == amphipod.clone()
            })
    }

    fn any_amphipods_above(&self, (current_row, current_column): Coordinate) -> bool {
        if self.in_hallway((current_row, current_column)) {
            return false;
        }

        self.map.contains_key(&((current_row - 1), current_column))
    }

    fn can_reach_destination_from_hallway(
        &self,
        amphipod_type: Amphipod,
        (current_row, current_column): Coordinate,
    ) -> Option<Coordinate> {
        let destination_column = amphipod_type.destination_column();

        let (start_column, end_column) = if current_column > destination_column {
            (destination_column, current_column - 1)
        } else {
            (current_column + 1, destination_column)
        };

        // No other amphipod blocking the hallway path
        for column in start_column..=end_column {
            if self.map.contains_key(&(current_row, column)) {
                return None;
            }
        }

        // No other amphipod of any other type in the destination room
        if !self.are_amphipods_below_the_same(amphipod_type, (current_row + 1, destination_column))
        {
            return None;
        }

        // Moving is possible, calculate the cost of movement (horizontal + vertical)
        let mut vertical_steps = 0;

        for depth in (1..=self.room_depth).rev() {
            if self
                .map
                .contains_key(&(current_row + depth, destination_column))
            {
                continue;
            }

            vertical_steps = depth;
            break;
        }

        Some((current_row + vertical_steps, destination_column))
    }

    fn generate_possible_states(&self) -> Vec<(Coordinate, Coordinate)> {
        let mut possible_states: Vec<(Coordinate, Coordinate)> = Vec::new();

        for (amphipod, current_coordinate) in self.amphipods.iter() {
            if self.any_amphipods_above(*current_coordinate) {
                continue;
            }

            if amphipod.in_destination(*current_coordinate)
                && self.are_amphipods_below_the_same(amphipod.clone(), *current_coordinate)
            {
                continue;
            }

            // We are ready to move
            if self.in_hallway(*current_coordinate) {
                let result =
                    self.can_reach_destination_from_hallway(amphipod.clone(), *current_coordinate);

                if result.is_none() {
                    continue;
                }

                // We can reach the destination from the hallway
                let new_coordinate = result.unwrap();
                possible_states.push((*current_coordinate, new_coordinate));
            } else {
                // From room to hallway
                possible_states.append(&mut self.valid_hallway_coordinates(*current_coordinate));
            }
        }

        possible_states
    }
}

fn compute(amphipods: Vec<(Amphipod, Coordinate)>, room_depth: i64) -> i64 {
    let mut queue = BinaryHeap::new();
    let mut seen: HashSet<Vec<(Amphipod, Coordinate)>> = HashSet::new();
    let start = Game::new(amphipods, room_depth);
    seen.insert(start.serialize());
    queue.push(start);

    while !queue.is_empty() {
        let game = queue.pop().unwrap();

        if game.is_win() {
            return game.cost;
        }

        let possible_states = game.generate_possible_states();

        for (from, to) in &possible_states {
            let new_game = game.clone_from(*from, *to);

            let serialized_state = new_game.serialize();
            if seen.contains(&serialized_state) {
                continue;
            }

            seen.insert(serialized_state);
            queue.push(new_game);
        }
    }

    unreachable!("Impossibru!");
}
fn main() {
    let amphipods = vec![
        (Amphipod::A, (2, 5)),
        (Amphipod::A, (3, 9)),
        (Amphipod::A, (4, 7)),
        (Amphipod::A, (5, 5)),
        (Amphipod::B, (3, 7)),
        (Amphipod::B, (4, 5)),
        (Amphipod::B, (5, 7)),
        (Amphipod::B, (5, 9)),
        (Amphipod::C, (2, 7)),
        (Amphipod::C, (3, 5)),
        (Amphipod::C, (4, 9)),
        (Amphipod::C, (5, 3)),
        (Amphipod::D, (2, 3)),
        (Amphipod::D, (3, 3)),
        (Amphipod::D, (4, 3)),
        (Amphipod::D, (2, 9)),
    ];

    println!("Result: {}", compute(amphipods, 4));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn part_1() {
        let amphipods = vec![
            (Amphipod::A, (2, 5)),
            (Amphipod::A, (3, 5)),
            (Amphipod::B, (3, 7)),
            (Amphipod::B, (3, 9)),
            (Amphipod::C, (2, 7)),
            (Amphipod::C, (3, 3)),
            (Amphipod::D, (2, 3)),
            (Amphipod::D, (2, 9)),
        ];

        let result = compute(amphipods, 2);
        assert_eq!(14346, result);
    }

    #[test]
    fn part_2() {
        let amphipods = vec![
            (Amphipod::A, (2, 5)),
            (Amphipod::A, (3, 9)),
            (Amphipod::A, (4, 7)),
            (Amphipod::A, (5, 5)),
            (Amphipod::B, (3, 7)),
            (Amphipod::B, (4, 5)),
            (Amphipod::B, (5, 7)),
            (Amphipod::B, (5, 9)),
            (Amphipod::C, (2, 7)),
            (Amphipod::C, (3, 5)),
            (Amphipod::C, (4, 9)),
            (Amphipod::C, (5, 3)),
            (Amphipod::D, (2, 3)),
            (Amphipod::D, (3, 3)),
            (Amphipod::D, (4, 3)),
            (Amphipod::D, (2, 9)),
        ];

        let result = compute(amphipods, 4);
        assert_eq!(48984, result);
    }
}
