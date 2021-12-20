use std::collections::HashSet;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/input.txt").unwrap();
}

static OFFSETS: [(isize, isize); 9] = [
    (-1, -1),
    (-1, 0),
    (-1, 1),
    (0, -1),
    (0, 0),
    (0, 1),
    (1, -1),
    (1, 0),
    (1, 1),
];

fn enhance(
    lit_map: &HashSet<(isize, isize)>,
    enhancement: &str,
    (min_row, max_row, min_col, max_col): (isize, isize, isize, isize),
    iteration: u8,
    iterations: u8,
) -> usize {
    if iteration == iterations {
        return lit_map.len();
    }

    let mut new_lit_map: HashSet<(isize, isize)> = HashSet::new();

    for col in (min_col - 1)..=(max_col + 1) {
        for row in (min_row - 1)..=(max_row + 1) {
            let mut value = String::from("");

            for (row_offset, col_offset) in OFFSETS {
                let row_pos = row + row_offset;
                let col_pos = col + col_offset;

                if (min_row..=max_row).contains(&row_pos) && (min_col..=max_col).contains(&col_pos)
                {
                    match lit_map.contains(&(row_pos, col_pos)) {
                        true => value.push('1'),
                        false => value.push('0'),
                    }
                } else {
                    match iteration % 2 == 1 {
                        true => value.push('1'),
                        false => value.push('0'),
                    }
                }
            }

            let value = usize::from_str_radix(&value, 2).unwrap();

            if enhancement.bytes().nth(value).unwrap() == b'#' {
                new_lit_map.insert((row, col));
            }
        }
    }

    enhance(
        &new_lit_map,
        enhancement,
        (min_row - 1, max_row + 1, min_col - 1, max_col + 1),
        iteration + 1,
        iterations,
    )
}

fn main() {
    let (enhancement, grid) = FILE_CONTENTS.trim().split_once("\n\n").unwrap();
    let (mut min_row, mut max_row, mut min_col, mut max_col) =
        (isize::MAX, isize::MIN, isize::MAX, isize::MIN);

    let lit_map: HashSet<(isize, isize)> =
        grid.lines()
            .enumerate()
            .fold(HashSet::new(), |mut lit_map, (row, line)| {
                line.trim().chars().enumerate().for_each(|(column, state)| {
                    if state == '#' {
                        min_row = min_row.min(row as isize);
                        max_row = max_row.max(row as isize);
                        min_col = min_col.min(column as isize);
                        max_col = max_col.max(column as isize);
                        lit_map.insert((row as isize, column as isize));
                    }
                });

                lit_map
            });

    println!(
        "Part1: {}",
        enhance(
            &lit_map,
            enhancement,
            (min_row, max_row, min_col, max_col),
            0,
            2
        )
    );
    println!(
        "Part2: {}",
        enhance(
            &lit_map,
            enhancement,
            (min_row, max_row, min_col, max_col),
            0,
            50
        )
    );
}
