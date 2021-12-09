use pathfinding::prelude::{bfs_reach, Matrix};

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

fn find_low_points(matrix: &Matrix<u32>) -> Vec<(usize, usize)> {
    let mut low_points = Vec::new();

    for row in 0..matrix.rows {
        for col in 0..matrix.columns {
            if !matrix
                .neighbours(&(row, col), false)
                .any(|(n_row, n_col)| matrix[&(row, col)] >= matrix[&(n_row, n_col)])
            {
                low_points.push((row, col));
            }
        }
    }

    low_points
}

fn part1(matrix: &Matrix<u32>) -> u32 {
    find_low_points(matrix)
        .iter()
        .map(|coordinate| matrix[coordinate] + 1)
        .sum()
}

fn part2(matrix: &Matrix<u32>) -> usize {
    let mut candidates: Vec<usize> = find_low_points(matrix)
        .iter()
        .map(|&low_coordinate| {
            bfs_reach(low_coordinate, |coordinate| {
                matrix
                    .neighbours(coordinate, false)
                    .filter(|n| matrix[n] != 9 && matrix[n] > matrix[coordinate])
                    .collect::<Vec<_>>()
            })
            .count()
        })
        .collect();

    candidates.sort_unstable_by(|a, b| b.cmp(a));
    candidates.iter().take(3).product()
}

fn main() {
    let matrix: Matrix<u32> = FILE_CONTENTS
        .lines()
        .map(|line| line.trim().chars().map(|c| c.to_digit(10).unwrap()))
        .collect();

    println!("Part 1: {}", part1(&matrix));
    println!("Part 2: {}", part2(&matrix));
}
