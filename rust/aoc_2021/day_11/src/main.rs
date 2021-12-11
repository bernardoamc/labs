use pathfinding::prelude::Matrix;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

fn flash(matrix: &mut Matrix<u32>, coordinate: &(usize, usize)) {
    matrix.neighbours(coordinate, true).for_each(|n| {
        matrix[&n] += 1;

        if matrix[&n] == 10 {
            flash(matrix, &n);
        }
    });
}

fn part1(input: &str) -> u64 {
    let mut matrix: Matrix<u32> = input
        .trim()
        .lines()
        .map(|line| line.trim().chars().map(|c| c.to_digit(10).unwrap()))
        .collect();

    let mut flashes: u64 = 0;

    for _day in 0..100 {
        matrix.indices().for_each(|coordinate| {
            matrix[&coordinate] += 1;

            if matrix[&coordinate] == 10 {
                flash(&mut matrix, &coordinate);
            }
        });

        matrix.indices().for_each(|coordinate| {
            if matrix[&coordinate] > 9 {
                flashes += 1;
                matrix[&coordinate] = 0;
            }
        });
    }

    flashes
}

fn part2(input: &str) -> u64 {
    let mut matrix: Matrix<u32> = input
        .trim()
        .lines()
        .map(|line| line.trim().chars().map(|c| c.to_digit(10).unwrap()))
        .collect();

    let mut day: u64 = 0;

    loop {
        day += 1;
        let mut flashes_in_day = 0;

        matrix.indices().for_each(|coordinate| {
            matrix[&coordinate] += 1;

            if matrix[&coordinate] == 10 {
                flash(&mut matrix, &coordinate);
            }
        });

        matrix.indices().for_each(|coordinate| {
            if matrix[&coordinate] > 9 {
                flashes_in_day += 1;
                matrix[&coordinate] = 0;
            }
        });

        if flashes_in_day == matrix.len() {
            break;
        }
    }

    day
}

fn main() {
    println!("Part 1: {}", part1(&FILE_CONTENTS));
    println!("Part 2: {}", part2(&FILE_CONTENTS));
}
