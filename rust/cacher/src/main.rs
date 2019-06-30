use std::cmp::Eq;
use std::collections::HashMap;
use std::hash::Hash;

struct Cache<T, U> where
    U: Eq + Hash + Copy,
    T: Fn(U) -> U
{
    algorithm: T,
    cache: HashMap<U, U>,
}

impl<T, U> Cache<T, U> where
    U: Eq + Hash + Copy,
    T: Fn(U) -> U
{
    fn new(algorithm: T) -> Cache<T, U> {
        Cache {
            algorithm,
            cache: HashMap::new()
        }
    }

    fn value(&mut self, arg: U) -> U {
        let algorithm = &self.algorithm;

        *self.cache.entry(arg).or_insert_with(|| algorithm(arg))
    }
}

fn main() {
    let factorial_algo = |initial_number| {
        let mut total = initial_number;
        let mut current_number = initial_number;
        println!("Calculating factorial for: {}", initial_number);

        while current_number > 0 {
            total *= match current_number {
                0 | 1 => 1,
                _ => current_number - 1
            };

            current_number -= 1;
        }

        total
    };

    let mut factorial = Cache::new(factorial_algo);

    println!("5! is: {}", factorial.value(5));
    println!("5! is: {}", factorial.value(5));
}