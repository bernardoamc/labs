use std::collections::HashMap;
use std::hash::Hash;
use std::str::FromStr;
use std::string::ParseError;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/input.txt").unwrap();
}

enum Solve {
    Min,
    Max,
}

#[derive(Clone, Copy, Debug)]
enum Value {
    Reg(usize),
    Val(i64),
}

#[derive(Clone, Copy, Debug)]
enum Op {
    Inp(usize),
    Add(usize, Value),
    Mul(usize, Value),
    Div(usize, Value),
    Mod(usize, Value),
    Eql(usize, Value),
}

impl FromStr for Op {
    type Err = ParseError;

    fn from_str(line: &str) -> Result<Self, Self::Err> {
        let parts: Vec<_> = line.split(' ').collect();
        let target = match parts[1] {
            "w" => 0,
            "x" => 1,
            "y" => 2,
            "z" => 3,
            _ => unreachable!(),
        };

        let mut value = Value::Val(0);

        if parts.len() == 3 {
            value = match parts[2] {
                "w" => Value::Reg(0),
                "x" => Value::Reg(1),
                "y" => Value::Reg(2),
                "z" => Value::Reg(3),
                _ => Value::Val(parts[2].parse::<i64>().unwrap()),
            };
        };

        match parts[0] {
            "inp" => Ok(Op::Inp(target)),
            "add" => Ok(Op::Add(target, value)),
            "mul" => Ok(Op::Mul(target, value)),
            "div" => Ok(Op::Div(target, value)),
            "mod" => Ok(Op::Mod(target, value)),
            "eql" => Ok(Op::Eql(target, value)),
            _ => unreachable!(),
        }
    }
}

#[derive(Clone, Debug, Hash)]
struct Alu {
    mem: [i64; 4],
}

impl Alu {
    fn new(mem: [i64; 4]) -> Self {
        Self { mem }
    }

    fn apply_op(&mut self, op: Op) {
        match op {
            Op::Add(target, value) => self.mem[target] += self.get_val(value),
            Op::Mul(target, value) => self.mem[target] *= self.get_val(value),
            Op::Div(target, value) => self.mem[target] /= self.get_val(value),
            Op::Mod(target, value) => self.mem[target] %= self.get_val(value),
            Op::Eql(target, value) => {
                self.mem[target] = (self.mem[target] == self.get_val(value)) as i64
            }
            Op::Inp(_) => unreachable!(),
        }
    }

    fn get_val(&self, value: Value) -> i64 {
        match value {
            Value::Reg(i) => self.mem[i],
            Value::Val(f) => f,
        }
    }
}

type Cache = HashMap<(i64, usize), Option<i64>>;

fn compute(
    memo: &mut Cache,
    functions: &[Vec<Op>],
    function_index: usize,
    z: i64,
    range: &[i64; 9],
) -> Option<i64> {
    if let Some(&answer) = memo.get(&(z, function_index)) {
        return answer;
    }

    for &digit in range {
        let mut alu = Alu::new([digit, 0, 0, z]);

        for &op in &functions[function_index] {
            alu.apply_op(op);
        }

        let z = alu.mem[3];

        if function_index + 1 == functions.len() {
            if z == 0 {
                memo.insert((z, function_index), Some(digit));
                return Some(digit);
            }

            continue;
        }

        if let Some(best) = compute(memo, functions, function_index + 1, z, range) {
            memo.insert((z, function_index), Some(best * 10 + digit));
            return Some(best * 10 + digit);
        }
    }

    memo.insert((z, function_index), None);
    None
}

fn solve(functions: &[Vec<Op>], run: Solve) -> String {
    let range = match run {
        Solve::Min => [1, 2, 3, 4, 5, 6, 7, 8, 9],
        Solve::Max => [9, 8, 7, 6, 5, 4, 3, 2, 1],
    };

    let answer = compute(&mut Cache::new(), functions, 0, 0, &range).unwrap();
    answer.to_string().chars().rev().collect()
}

fn main() {
    let ops: Vec<Op> = FILE_CONTENTS
        .trim()
        .lines()
        .map(|line| Op::from_str(line.trim()).unwrap())
        .collect();

    let functions = ops
        .chunks(18)
        .map(|c| c.iter().skip(1).copied().collect())
        .collect::<Vec<Vec<Op>>>();

    let max = solve(&functions, Solve::Max);
    let min = solve(&functions, Solve::Min);

    println!("Part 1: {}", max);
    println!("Part 2: {}", min);
}
