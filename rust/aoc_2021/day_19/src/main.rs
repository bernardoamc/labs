use itertools::Itertools;
use std::hash::{Hash, Hasher};
use std::{
    collections::HashSet,
    ops::{Add, Sub},
};

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

#[derive(Clone, Copy, Eq, PartialEq)]
struct Point {
    x: i32,
    y: i32,
    z: i32,
}

impl Point {
    fn new(x: i32, y: i32, z: i32) -> Self {
        Self { x, y, z }
    }

    fn rotate(&self, rot: u8) -> Self {
        match rot {
            0 => Self::new(self.x, self.y, self.z),
            1 => Self::new(self.x, self.z, -self.y),
            2 => Self::new(self.x, -self.y, -self.z),
            3 => Self::new(self.x, -self.z, self.y),
            4 => Self::new(self.y, self.x, -self.z),
            5 => Self::new(self.y, self.z, self.x),
            6 => Self::new(self.y, -self.x, self.z),
            7 => Self::new(self.y, -self.z, -self.x),
            8 => Self::new(self.z, self.x, self.y),
            9 => Self::new(self.z, self.y, -self.x),
            10 => Self::new(self.z, -self.x, -self.y),
            11 => Self::new(self.z, -self.y, self.x),
            12 => Self::new(-self.x, self.y, -self.z),
            13 => Self::new(-self.x, self.z, self.y),
            14 => Self::new(-self.x, -self.y, self.z),
            15 => Self::new(-self.x, -self.z, -self.y),
            16 => Self::new(-self.y, self.x, self.z),
            17 => Self::new(-self.y, self.z, -self.x),
            18 => Self::new(-self.y, -self.x, -self.z),
            19 => Self::new(-self.y, -self.z, self.x),
            20 => Self::new(-self.z, self.x, -self.y),
            21 => Self::new(-self.z, self.y, self.x),
            22 => Self::new(-self.z, -self.x, self.y),
            23 => Self::new(-self.z, -self.y, -self.x),
            _ => unreachable!(),
        }
    }

    fn manhattan_distance(&self, other: &Point) -> i32 {
        (self.x - other.x).abs() + (self.y - other.y).abs() + (self.z - other.z).abs()
    }
}

impl Add for Point {
    type Output = Self;

    fn add(self, other: Self) -> Self {
        Self {
            x: self.x + other.x,
            y: self.y + other.y,
            z: self.z + other.z,
        }
    }
}

impl Sub for Point {
    type Output = Self;

    fn sub(self, other: Self) -> Self {
        Self {
            x: self.x - other.x,
            y: self.y - other.y,
            z: self.z - other.z,
        }
    }
}

impl Hash for Point {
    fn hash<H: Hasher>(&self, state: &mut H) {
        state.write_i32(self.x ^ self.y ^ self.z);
    }
}

fn merge_scanner(total_scan: &mut HashSet<Point>, scan: &[Point]) -> Option<Point> {
    for rot in 0..24 {
        let rotated_scanner: Vec<Point> = scan.iter().map(|p| p.rotate(rot)).collect();
        let distances = total_scan
            .iter()
            .cartesian_product(&rotated_scanner)
            .map(|(p1, p2)| *p1 - *p2);

        for distance in distances {
            let translated: Vec<Point> = rotated_scanner.iter().map(|p| *p + distance).collect();
            let count = translated.iter().fold(0, |mut count, p| {
                if total_scan.contains(&p) {
                    count += 1;
                }

                count
            });

            if count >= 12 {
                total_scan.extend(translated);
                return Some(distance);
            }
        }
    }

    None
}

fn main() {
    let mut scanners: Vec<Vec<Point>> = FILE_CONTENTS
        .trim()
        .split("\n\n")
        .map(|scanner| {
            scanner
                .lines()
                .skip(1)
                .map(|line| line.split(',').map(|n| n.parse().unwrap()).collect())
                .map(|positions: Vec<i32>| Point {
                    x: positions[0],
                    y: positions[1],
                    z: positions[2],
                })
                .collect()
        })
        .collect();

    let mut total_scan = scanners.remove(0).into_iter().collect::<HashSet<_>>();
    let mut distances = Vec::new();

    while !scanners.is_empty() {
        for i in (0..scanners.len()).rev() {
            if let Some(d) = merge_scanner(&mut total_scan, &scanners[i]) {
                distances.push(d);
                scanners.swap_remove(i);
            }
        }
    }

    println!("Part 1: {}", total_scan.len());

    let max_distance = distances
        .iter()
        .tuple_combinations()
        .map(|(p1, p2)| p1.manhattan_distance(p2))
        .max()
        .unwrap();

    println!("Part 2: {}", max_distance);
}
