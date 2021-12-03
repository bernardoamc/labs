#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/input.txt").unwrap();
}

#[derive(Clone, Debug, Default)]
struct Bits {
    ones: i32,
    zeros: i32,
}

impl Bits {
    fn aggregate_by_pos(bitstrings: &[&str]) -> Vec<Self> {
        let bits_len = bitstrings[0].len();
        let mut bits: Vec<Bits> = vec![Bits::default(); bits_len];

        for index in 0..bitstrings.len() {
            for (bit_index, bit) in bitstrings[index].char_indices() {
                match bit {
                    '0' => bits[bit_index].zeros += 1,
                    '1' => bits[bit_index].ones += 1,
                    _ => panic!("This is not a binary"),
                }
            }
        }

        bits
    }
}

fn part1(lines: &[&str]) -> u32 {
    let bits = Bits::aggregate_by_pos(lines);
    let mut gamma = String::new();
    let mut epsilon = String::new();

    for bit in bits {
        if bit.zeros > bit.ones {
            gamma.push('0');
            epsilon.push('1');
        } else {
            gamma.push('1');
            epsilon.push('0');
        }
    }

    u32::from_str_radix(&gamma, 2).unwrap() * u32::from_str_radix(&epsilon, 2).unwrap()
}

fn part2(lines: &Vec<&str>) -> u32 {
    let oxygen = find_rating_by(&lines, |a, b| if a.len() >= b.len() { a } else { b });
    let co2 = find_rating_by(&lines, |a, b| if a.len() >= b.len() { b } else { a });

    u32::from_str_radix(&oxygen, 2).unwrap() * u32::from_str_radix(&co2, 2).unwrap()
}

fn find_rating_by<'a, F: Fn(Vec<&'a str>, Vec<&'a str>) -> Vec<&'a str>>(
    bitstrings: &[&'a str],
    bit_criteria: F,
) -> &'a str {
    let mut bit_index = 0;
    let mut ratings = bitstrings.to_vec();

    while ratings.len() > 1 {
        let (ones, zeros): (Vec<&str>, Vec<&str>) = ratings
            .iter()
            .partition(|s| s.chars().nth(bit_index).unwrap() == '1');

        ratings = bit_criteria(ones, zeros);
        bit_index += 1;
    }

    match ratings.first() {
        Some(rating) => rating,
        None => panic!("Couldn't find rating"),
    }
}

fn main() {
    let lines = FILE_CONTENTS.lines().collect::<Vec<&str>>();
    println!("Part 1: {}", part1(&lines));
    println!("Part 2: {}", part2(&lines));
}
