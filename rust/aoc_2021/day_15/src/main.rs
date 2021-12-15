use pathfinding::prelude::*;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

fn successors(matrix: &Matrix<u32>, point: &(usize, usize)) -> Vec<((usize, usize), u32)> {
    matrix
        .neighbours(point, false)
        .map(|n| (n, matrix[&n]))
        .collect()
}

fn compute_path(matrix: &Matrix<u32>, start: (usize, usize), goal: (usize, usize)) -> u32 {
    let (_path, cost) = astar(
        &start,
        |n| successors(&matrix, n),
        |n| matrix[n],
        |n| n == &goal,
    )
    .unwrap();

    cost
}

fn part1(input: &str) -> u32 {
    let matrix: Matrix<u32> = input
        .lines()
        .map(|line| line.trim().chars().map(|c| c.to_digit(10).unwrap()))
        .collect();

    let start = (0, 0);
    let goal = (matrix.columns - 1, matrix.rows - 1);

    compute_path(&matrix, start, goal)
}

fn part2(input: &str) -> u32 {
    let mut matrix: Vec<Vec<u32>> = input
        .lines()
        .map(|line| {
            let mut row: Vec<u32> = line
                .trim()
                .chars()
                .map(|c| c.to_digit(10).unwrap())
                .collect();

            let columns: usize = row.len();

            (columns..(5 * columns)).for_each(|current| {
                let value = (row[current - columns] % 9) + 1;
                row.push(value);
            });

            row
        })
        .collect();

    let rows = matrix.len();

    (rows..(rows * 5)).for_each(|current| {
        let row = &matrix[current - rows];
        let new_row = row.iter().map(|value| (value % 9) + 1).collect();
        matrix.push(new_row);
    });

    let matrix = Matrix::from_rows(matrix).unwrap();
    let start = (0, 0);
    let goal = (matrix.columns - 1, matrix.rows - 1);

    compute_path(&matrix, start, goal)
}

fn main() {
    println!("Part1: {}", part1(&FILE_CONTENTS.trim()));
    println!("Part2: {}", part2(&FILE_CONTENTS.trim()));
}
