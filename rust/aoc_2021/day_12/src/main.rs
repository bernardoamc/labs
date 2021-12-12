use std::{
    collections::{hash_map::DefaultHasher, HashMap},
    hash::{Hash, Hasher},
};

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

enum Kind {
    Start,
    End,
    Big,
    Small,
}

impl From<&str> for Kind {
    fn from(node: &str) -> Self {
        match node.trim() {
            "start" => Kind::Start,
            "end" => Kind::End,
            _ => {
                if node.to_ascii_lowercase() == node {
                    Kind::Small
                } else {
                    Kind::Big
                }
            }
        }
    }
}

struct Node {
    value: u64,
    kind: Kind,
}

impl Node {
    fn new(node: &str) -> Self {
        let mut hasher = DefaultHasher::new();
        node.hash(&mut hasher);

        Self {
            value: hasher.finish(),
            kind: node.into(),
        }
    }
}

fn traverse_part1(map: &HashMap<u64, Vec<Node>>, current: u64, visited: &mut Vec<u64>) -> u64 {
    map.get(&current).unwrap().iter().fold(0, |acc, neighbour| {
        match (&neighbour.kind, visited.contains(&neighbour.value)) {
            (Kind::Start, _) => acc,
            (Kind::End, _) => acc + 1,
            (Kind::Small, true) => acc,
            _ => {
                visited.push(neighbour.value);
                let paths = traverse_part1(map, neighbour.value, visited);
                visited.pop();
                acc + paths
            }
        }
    })
}

fn traverse_part2(
    map: &HashMap<u64, Vec<Node>>,
    current: u64,
    visited: &mut Vec<u64>,
    small_cave_used: bool,
) -> u64 {
    map.get(&current).unwrap().iter().fold(0, |acc, neighbour| {
        match (
            &neighbour.kind,
            visited.contains(&neighbour.value),
            small_cave_used,
        ) {
            (Kind::Start, _, _) => acc,
            (Kind::End, _, _) => acc + 1,
            (Kind::Small, true, true) => acc,
            (Kind::Small, true, false) => {
                visited.push(neighbour.value);
                let paths = traverse_part2(map, neighbour.value, visited, true);
                visited.pop();
                acc + paths
            }
            _ => {
                visited.push(neighbour.value);
                let paths = traverse_part2(map, neighbour.value, visited, small_cave_used);
                visited.pop();
                acc + paths
            }
        }
    })
}

fn main() {
    let mut hasher = DefaultHasher::new();
    "start".hash(&mut hasher);
    let start: u64 = hasher.finish();

    let map: HashMap<u64, Vec<Node>> = FILE_CONTENTS
        .trim()
        .lines()
        .map(|line| line.trim().split_once("-").unwrap())
        .fold(HashMap::new(), |mut map, (l, r)| {
            let l_node = Node::new(l);
            let r_node = Node::new(r);
            let r_node_value = r_node.value;

            map.entry(l_node.value)
                .or_insert_with(|| vec![])
                .push(r_node);
            map.entry(r_node_value)
                .or_insert_with(|| vec![])
                .push(l_node);
            map
        });

    let mut visited = vec![start];
    println!("Part 1: {}", traverse_part1(&map, start, &mut visited));
    println!(
        "Part 2: {}",
        traverse_part2(&map, start, &mut visited, false)
    );
}
