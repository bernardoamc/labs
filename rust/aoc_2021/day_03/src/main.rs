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

fn part1_bits(numbers: &[u32], bits: u32) -> u32 {
    let count = numbers.len();

    let gamma = (0..bits).rev().fold(0, |acc, bit| {
        let mask = 2u32.pow(bit);
        let ones = numbers.iter().filter(|n| *n & mask > 0).count();

        if ones > count / 2 {
            acc + mask
        } else {
            acc
        }
    });

    let epsilon = !gamma & (2u32.pow(bits) - 1);

    gamma * epsilon
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

// Really cool solution from @rabuf (GitHub). In his words:
// I sort numbers and then I keep track of the boundaries for both oxygen and CO2, and do a binary search
// to find which section (1s or 0s) for a particular bit is larger, changing the corresponding
// upper or lower bound.
fn part2_bits(numbers: &mut [u32], bits: u32) -> u32 {
    numbers.sort();

    let count = numbers.len();
    let mut o_lower = 0;
    let mut o_upper = count;
    let mut c_lower = 0;
    let mut c_upper = count;

    for bit in (0..bits).rev() {
        let mask = 2_u32.pow(bit);

        if o_upper - o_lower > 1 {
            let mid = binary_search(&numbers, o_lower, o_upper, mask);
            if mid - o_lower <= o_upper - mid {
                o_lower = mid;
            } else {
                o_upper = mid;
            }
        }
        if c_upper - c_lower > 1 {
            let mid = binary_search(&numbers, c_lower, c_upper, mask);
            if mid - c_lower > c_upper - mid {
                c_lower = mid;
            } else {
                c_upper = mid;
            }
        }
    }

    numbers[c_lower] * numbers[o_lower]
}

fn binary_search(codes: &[u32], lower: usize, upper: usize, mask: u32) -> usize {
    let mut mid = (upper - lower) / 2 + lower;
    let mut lower = lower;
    let mut upper = upper;

    while lower + 1 != upper {
        if codes[mid] & mask > 0 {
            upper = mid;
            mid = (lower + mid) / 2;
        } else {
            lower = mid;
            mid = (upper + mid) / 2;
        }
    }

    mid + 1
}

fn main() {
    let lines = FILE_CONTENTS.lines().collect::<Vec<&str>>();
    let bits = lines[0].len();
    let mut numbers = FILE_CONTENTS
        .lines()
        .map(|line| u32::from_str_radix(line, 2).unwrap())
        .collect::<Vec<u32>>();

    println!("Part 1: {}", part1(&lines));
    println!("Part 1 bits: {}", part1_bits(&numbers, bits as u32));
    println!("Part 2: {}", part2(&lines));
    println!("Part 2 bits: {}", part2_bits(&mut numbers, bits as u32));
}
