use std::collections::HashMap;

struct Cache<T>
    where T: Fn(u32) -> u32
{
    algorithm: T,
    cache: HashMap<u32, u32>,
}

impl<T> Cache<T>
    where T: Fn(u32) -> u32
{
    fn new(algorithm: T) -> Cache<T> {
        Cache {
            algorithm,
            cache: HashMap::new()
        }
    }

    fn value(&mut self, arg: u32) -> u32 {
        let algorithm = &self.algorithm;

        *self.cache.entry(arg).or_insert_with(|| match arg {
            0 | 1 => 1,
            _ => algorithm(arg)
        })
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