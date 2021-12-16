#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

use bitvec::order::Msb0;
use bitvec::prelude::BitVec;
use itertools::Itertools;

struct BitsSystem {
    bits: BitVec<Msb0, u8>,
    position: usize,
    version: usize,
}

impl BitsSystem {
    fn new(bits: BitVec<Msb0, u8>) -> Self {
        Self {
            position: 0,
            version: 0,
            bits,
        }
    }

    fn parse_packet(&mut self) -> usize {
        self.version += self.parse_bits(3);
        let id = self.parse_bits(3);

        match id {
            0 => self.parse_operator().iter().sum(),
            1 => self.parse_operator().iter().product(),
            2 => *self.parse_operator().iter().min().unwrap(),
            3 => *self.parse_operator().iter().max().unwrap(),
            4 => self.parse_literal(),
            7 => self.parse_operator().iter().all_equal() as usize,
            5 => {
                let v = self.parse_operator();
                (v[0] > v[1]) as usize
            }
            6 => {
                let v = self.parse_operator();
                (v[0] < v[1]) as usize
            }
            _ => {
                panic!("ID not recognized")
            }
        }
    }

    fn parse_operator(&mut self) -> Vec<usize> {
        let lenght_type_id = self.parse_bits(1);

        if lenght_type_id == 1 {
            let packets = self.parse_bits(11);
            return (0..packets).map(|_| self.parse_packet()).collect_vec();
        }

        let mut results = Vec::new();
        let bit_length = self.parse_bits(15);
        let final_bit = self.position + bit_length;

        while self.position != final_bit {
            results.push(self.parse_packet());
        }

        results
    }

    fn parse_bits(&mut self, bit_count: usize) -> usize {
        let value = self.bits[self.position..self.position + bit_count]
            .iter()
            .fold(0, |value, bit| (value << 1) | ((bit == true) as usize));
        self.position += bit_count;

        value
    }

    fn parse_literal(&mut self) -> usize {
        let mut value = 0;

        while self.parse_bits(1) != 0 {
            value = value << 4 | self.parse_bits(4);
        }

        value << 4 | self.parse_bits(4)
    }
}

fn main() {
    let bytestring = FILE_CONTENTS.trim().chars().chunks(2);
    let bits: BitVec<Msb0, u8> = BitVec::from_vec(
        bytestring
            .into_iter()
            .map(|pair| u8::from_str_radix(&pair.collect::<String>(), 16).unwrap())
            .collect(),
    );
    let mut bit_system = BitsSystem::new(bits);
    let result = bit_system.parse_packet();

    println!("Part 1: {}", bit_system.version);
    println!("Part 2: {}", result);
}
