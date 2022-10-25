use std::env;
use std::collections::VecDeque;

const BITS_PER_STATE: usize = 64;
const BITS_PER_CODE: usize = 64;
const BITS_MOVED: usize = 3;
const NIBBLE: usize  = 4;

fn setup(seed: u64) -> u64 {
    let mut seed = seed;
    let mut state = 0;

    for _ in 0..16 {
        let current = seed & 3;
        seed >>= 2;

        state = (state << 4) | ((state & 3) ^ current);
		state |= current << 2;
    }

    state
}

fn algorithm(current_state: u64) -> (u64, u64) {
    let mut state = current_state;
    let mut code = 0 ;

	for _ in 0..BITS_PER_CODE {
        code <<= 1;
        code |= state & 1;

        for _ in 0..3 {
            state = (state << 1) ^ (state >> 61);
            state &= 0xFFFFFFFFFFFFFFFF;
            state ^= 0xFFFFFFFFFFFFFFFF;

            for j in (0..BITS_PER_STATE).step_by(NIBBLE) {
                let mut cur = (state >> j) & 0xF;
                cur = (cur >> 3) | ((cur >> 2) & 2) | ((cur << 3) & 8) | ((cur << 2) & 4);
                state ^= cur << j;
            }
        }
    }

	(state, code)
}

// See the README for some manual testing of the first two iterations
// We could also have solved this by calculating the first state and then performed matrix multiplication, something like:
//   first_state = generate_equations with a single loop
//   new_state = multiply_matrix(current_state, first_state)
//   equations.push(new_state[-1])
// This works since the first_state dictates how the rest of the bits will move on each step.
fn generate_equations(code: u64, operations: &mut VecDeque<u64>, equations: &mut VecDeque<u64>, results: &mut VecDeque<u64>) {
    for bit_pos in 0..BITS_PER_CODE {
        equations.push_back(operations[operations.len() - 1]);

        if (code & (1 << (BITS_PER_CODE - bit_pos - 1))) == 0 {
            results.push_back(0);
        } else {
            results.push_back(1);
        }

        for _ in 0..3 {
            operations.push_back(0);
    
            for i in 0..BITS_MOVED {
                operations[BITS_PER_STATE - i] ^= operations[BITS_MOVED - i - 1];
            }
            
            operations.pop_front();
    
            for step in (0..BITS_PER_STATE).step_by(NIBBLE) {
                let bit_order = vec![operations[step + 3], operations[step + 3], operations[step], operations[step]];
    
                for i in 0..NIBBLE {
                    operations[step + i] ^= bit_order[i];
                }
            }
        }
    }
}

// Gaussian Elimination of Quadratic Matrices
// Wikipedia reference: algorithm: https://en.wikipedia.org/wiki/Gaussian_elimination
// Adapted for XOR operations and not really optimized :P
pub fn gaussian_elimination(matrix: &mut [(u64, u64)]) -> u64 {
    matrix.sort_by(|a, b| b.0.cmp(&a.0));

    for i in 0..BITS_PER_STATE {
        echelon(matrix, i);
        matrix.sort_by(|a, b| b.0.cmp(&a.0));
    }

    for i in (1..BITS_PER_STATE).rev() {
        eliminate(matrix, i);
    }

    let mut result: u64 = 0;

    for (i, (_row_equation, row_result)) in matrix.iter().enumerate().take(BITS_PER_STATE) {
        result += row_result << (BITS_PER_STATE - i - 1);
    }

    result
}

fn echelon(matrix: &mut [(u64, u64)], row: usize) {
    let (current_equation, current_result) = matrix[row];
    let bit = 1 << (BITS_PER_STATE - row - 1);

    if current_equation & bit == 0 {
        return;
    }

    for (next_equation, next_result) in matrix.iter_mut().skip(row+1) {
        if *next_equation & bit == 0 {
            continue;
        }

        *next_equation ^= current_equation;
        *next_result ^= current_result;
    }
}

fn eliminate(matrix: &mut [(u64, u64)], last_row_with_bit: usize) {
    let (current_equation, current_result) = matrix[last_row_with_bit];
    let selected_bit = 1 << (BITS_PER_STATE - last_row_with_bit - 1);

    if current_equation & selected_bit == 0 {
        return;
    }
    
    for (previous_equation, previous_result) in matrix.iter_mut().take(last_row_with_bit) {
        if *previous_equation & selected_bit == 0 {
            continue;
        }

        *previous_equation ^=  current_equation;
        *previous_result ^=  current_result;
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let first_code = args[1].parse::<u64>().expect("64bit number");
    let second_code = args[2].parse::<u64>().expect("64bit number");

    // If we want to debug we can generate our own state and see if we can infer the same code with our algorithm
    // let initial_state = setup(123);
    // let (state1, code1) = algorithm(initial_state);
    // let (state2, code2) = algorithm(state1);
    // let (_state3, code3) = algorithm(state2);

    // println!("-------------------------------------------");
    // println!("Original code 1: {:020}", code1);
    // println!("Original code 2: {:020}", code2);
    // println!("Original code 3: {:020}", code3);

    // We know that for every 4 bits the first and the last bits are the same.
    // 9 is equivalent to b1001 in binary.
    let mut equations: VecDeque<u64> = (0..64).step_by(4).map(|step| { 9 << step }).collect();

    // We start with 16 values of 0 since for every 4 bits we know the first and the last bits are the same, so the XOR operation between them is 0.
    // Since our number is 64bits we have 64/4 = 16 values. These are the results of the first 16 equations.
    let mut results: VecDeque<u64> = (0..16).map(|_| { 0 }).collect();

    assert_eq!(equations.len(), results.len());

    // Operations aim to track how the bits are moved around.
    let mut operations: VecDeque<u64> = (0..64).rev().map(|i| (1 << i)).collect();

    generate_equations(first_code, &mut operations, &mut equations, &mut results);
    generate_equations(second_code, &mut operations, &mut equations, &mut results);
    
    let mut matrix: Vec<(u64, u64)> = (0..BITS_PER_STATE).map(|pos| (equations[pos], results[pos])).collect();
    let derived_state = gaussian_elimination(&mut matrix);

    let (ds1, dc1) = algorithm(derived_state);
    let (ds2, dc2) = algorithm(ds1);
    let (_ds3, dc3) = algorithm(ds2);

    println!("-------------------------------------------");
    println!("Derived code 1: {:020}", dc1);
    println!("Derived code 2: {:020}", dc2);
    println!("Derived code 3: {:020}", dc3);
    println!("-------------------------------------------");
}
