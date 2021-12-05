use regex::Regex;
use std::collections::HashMap;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

lazy_static! {
    static ref LINE_RE: Regex = Regex::new(
        r"(?x)          # Ignore regex whitespace + enable comments
        (?P<x1>\d+)     # Digit
        ,               # Literal comma
        (?P<y1>\d+)     # Digit
        \s+             # One or more whitespace
        ->              # Literal arrow
        \s+             # One or more whitespace
        (?P<x2>\d+)     # Digit
        ,               # Literal comma
        (?P<y2>\d+)     # Digit
    "
    )
    .unwrap();
}

#[derive(Debug)]
struct Line {
    x1: i32,
    y1: i32,
    x2: i32,
    y2: i32,
}

struct Grid<'l> {
    lines: &'l [Line],
}

impl<'l> Grid<'l> {
    fn overlapping_lines<F: Fn(&'l Line) -> bool>(&self, criteria: F) -> usize {
        let mut points = HashMap::new();

        for line in self.lines {
            if !criteria(&line) {
                continue;
            }

            let Line { x1, y1, x2, y2 } = line;

            let dx = (x2 - x1).signum();
            let dy = (y2 - y1).signum();
            let (mut x, mut y) = (*x1, *y1);

            while (x, y) != (x2 + dx, y2 + dy) {
                *points.entry((x, y)).or_insert(0) += 1;
                x += dx;
                y += dy;
            }
        }

        points.values().filter(|&&n| n > 1).count()
    }
}

fn main() {
    let mut coordinates = vec![];

    for line in FILE_CONTENTS.lines() {
        let caps = LINE_RE.captures(line);

        if caps.is_some() {
            let caps = caps.unwrap();
            let x1: i32 = caps["x1"].parse().unwrap();
            let y1: i32 = caps["y1"].parse().unwrap();
            let x2: i32 = caps["x2"].parse().unwrap();
            let y2: i32 = caps["y2"].parse().unwrap();

            coordinates.push(Line { x1, x2, y1, y2 });
        }
    }

    let grid = Grid {
        lines: &coordinates,
    };

    let p1_total = grid.overlapping_lines(|line| line.x1 == line.x2 || line.y1 == line.y2);
    let p2_total = grid.overlapping_lines(|_line| true);

    println!("Part 1: {}", p1_total);
    println!("Part 2: {}", p2_total);
}
