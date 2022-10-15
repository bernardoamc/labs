use std::env;
use rayon::prelude::*;

const BITS: usize = 26;

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

	for _ in 0..BITS {
        code <<= 1;
        code |= state & 1;
        state = (state << 1) ^ (state >> 61);
        state &= 0xFFFFFFFFFFFFFFFF;
	    state ^= 0xFFFFFFFFFFFFFFFF;

        for j in (0..64).step_by(4) {
            let mut cur = (state >> j) & 0xF;
            cur = (cur >> 3) | ((cur >> 2) & 2) | ((cur << 3) & 8) | ((cur << 2) & 4);
            state ^= cur << j;
        }
    }

	(state, code)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let first_code = args[1].parse::<u64>().expect("64bit number");
    let second_code = args[2].parse::<u64>().expect("64bit number");

    let seed = (0..=u32::MAX)
        .into_par_iter()
        .find_first(|&candidate| {
            let initial_state = setup(candidate as u64);
            let (new_state, first_result) = algorithm(initial_state);

            if first_result != first_code {
                return false;
            }

            let (_, second_result) = algorithm(new_state);
            second_result == second_code
        });

    match seed {
        Some(seed) => {
            let state = setup(seed as u64);
            println!("Seed found: {}", seed);
            println!("State after setup: {}", state);

            let (new_state, result) = algorithm(state);
            println!("Current code: {:08}", result);
            println!("Current state: {}", new_state);

            let (new_state, result) = algorithm(new_state);
            println!("Next code: {:08}", result);
            println!("Next state: {}", new_state);
        },
        None => println!("Seed not found!")
    }
}
