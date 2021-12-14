use std::collections::HashMap;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

fn compute_polymer(
    template: HashMap<(u8, u8), usize>,
    rules: &HashMap<(u8, u8), u8>,
) -> HashMap<(u8, u8), usize> {
    let mut new_template: HashMap<(u8, u8), usize> = HashMap::new();

    for ((c1, c2), count) in template {
        if let Some(&c_mid) = rules.get(&(c1, c2)) {
            *new_template.entry((c1, c_mid)).or_insert(0) += count;
            *new_template.entry((c_mid, c2)).or_insert(0) += count;
        } else {
            *new_template.entry((c1, c2)).or_insert(0) += count;
        }
    }

    new_template
}

fn compute(
    template: HashMap<(u8, u8), usize>,
    rules: &HashMap<(u8, u8), u8>,
    iterations: u8,
) -> usize {
    let mut frequency = HashMap::new();
    let polymer = (0..iterations).fold(template, |new_template, _| {
        compute_polymer(new_template, &rules)
    });

    for ((c1, c2), count) in polymer {
        *frequency.entry(c1).or_insert(0) += count;
        *frequency.entry(c2).or_insert(0) += count;
    }

    let difference = frequency.values().max().unwrap() - frequency.values().min().unwrap();
    (difference / 2) + 1
}

fn main() {
    let (template, rules) = FILE_CONTENTS.split_once("\n\n").unwrap();
    let template: HashMap<(u8, u8), usize> = template
        .trim()
        .bytes()
        .collect::<Vec<u8>>()
        .windows(2)
        .fold(HashMap::new(), |mut map, tuple| {
            let key = (tuple[0], tuple[1]);
            *map.entry(key).or_insert(0) += 1;
            map
        });
    let rules: HashMap<(u8, u8), u8> = rules
        .trim()
        .lines()
        .map(|line| {
            let (pair, replacement) = line.trim().split_once(" -> ").unwrap();

            (
                (pair.as_bytes()[0], pair.as_bytes()[1]),
                replacement.as_bytes()[0],
            )
        })
        .collect();

    let mut template_copy: HashMap<(u8, u8), usize> = HashMap::new();
    template_copy.clone_from(&template);

    println!("Part 1: {}", compute(template, &rules, 10));
    println!("Part 2: {}", compute(template_copy, &rules, 40));
}
