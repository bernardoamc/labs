use std::collections::HashSet;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

#[derive(Debug)]
enum Fold {
    X(u32),
    Y(u32),
}

impl From<&str> for Fold {
    fn from(line: &str) -> Self {
        let (axis, position) = line.split_once('=').unwrap();
        let position = position.parse::<u32>().unwrap();
        if axis.ends_with('x') {
            Self::X(position)
        } else {
            Self::Y(position)
        }
    }
}

#[derive(Debug, Clone)]
struct Paper {
    dots: HashSet<(u32, u32)>,
}

impl Paper {
    fn new(dots: HashSet<(u32, u32)>) -> Self {
        Self { dots }
    }

    fn fold(&mut self, fold: &Fold) {
        let new_dots = match fold {
            Fold::X(column) => self.fold_x(*column),
            Fold::Y(row) => self.fold_y(*row),
        };

        for (old_dot, new_dot) in new_dots {
            self.dots.remove(&old_dot);
            self.dots.insert(new_dot);
        }
    }

    fn fold_x(&mut self, column: u32) -> Vec<((u32, u32), (u32, u32))> {
        let mut new_dots = vec![];

        for dot in self.dots.iter() {
            let &(x, y) = dot;

            if x > column {
                let new_x = column - (x - column);
                new_dots.push(((*dot), (new_x, y)));
            }
        }

        new_dots
    }

    fn fold_y(&mut self, row: u32) -> Vec<((u32, u32), (u32, u32))> {
        let mut new_dots = vec![];

        for dot in self.dots.iter() {
            let &(x, y) = dot;

            if y > row {
                let new_y = row - (y - row);
                new_dots.push((*dot, (x, new_y)));
            }
        }

        new_dots
    }

    fn dots_count(&self) -> usize {
        self.dots.len()
    }

    fn render(&self) {
        let width = self.dots.iter().map(|dot| dot.0).max().unwrap();
        let height = self.dots.iter().map(|dot| dot.1).max().unwrap();

        for y in 0..=height {
            let mut line = String::new();
            for x in 0..=width {
                line.push(if self.dots.contains(&(x, y)) {
                    '█'
                } else {
                    ' '
                });
            }
            println!("{}", line);
        }
    }
}

fn part1(dots: HashSet<(u32, u32)>, folds: &Vec<Fold>) -> usize {
    let mut paper = Paper::new(dots);
    let first_fold = folds.first().unwrap();
    paper.fold(first_fold);

    paper.dots_count()
}

fn part2(dots: HashSet<(u32, u32)>, folds: &Vec<Fold>) {
    let mut paper = Paper::new(dots);
    folds.iter().for_each(|f| paper.fold(f));

    paper.render();
}

fn main() {
    let (dots, folds) = FILE_CONTENTS.split_once("\n\n").unwrap();
    let folds: Vec<Fold> = folds.lines().map(|line| line.trim().into()).collect();
    let dots: HashSet<(u32, u32)> = dots
        .lines()
        .map(|line| {
            let (x, y) = line.trim().split_once(',').unwrap();
            (x.parse::<u32>().unwrap(), y.parse::<u32>().unwrap())
        })
        .collect();

    println!("Part 1: {}", part1(dots.clone(), &folds));
    println!("Part 2:");
    part2(dots.clone(), &folds);
}
