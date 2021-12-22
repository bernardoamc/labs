#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

#[derive(Clone, Debug)]
struct Cuboid {
    x: (i64, i64),
    y: (i64, i64),
    z: (i64, i64),
    toggled: bool,
}

impl Cuboid {
    fn new(x: (i64, i64), y: (i64, i64), z: (i64, i64), toggle: bool) -> Self {
        Self {
            x,
            y,
            z,
            toggled: toggle,
        }
    }

    fn is_valid(&self) -> bool {
        self.x.0 < self.x.1 && self.y.0 < self.y.1 && self.z.0 < self.z.1
    }

    // Max x.0 is represented by: ^
    // Min x.1 is represented by: !
    //
    // No overlap: [...] (...)
    //                 ! ^
    // Overlap: [.....(..]...)
    //                ^  !
    fn overlap(&self, other: &Cuboid) -> Cuboid {
        Cuboid::new(
            (self.x.0.max(other.x.0), self.x.1.min(other.x.1)),
            (self.y.0.max(other.y.0), self.y.1.min(other.y.1)),
            (self.z.0.max(other.z.0), self.z.1.min(other.z.1)),
            !other.toggled,
        )
    }

    fn volume(&self) -> u64 {
        ((self.x.1 - self.x.0) * (self.y.1 - self.y.0) * (self.z.1 - self.z.0)) as u64
    }

    fn in_range(&self, lower: i64, higher: i64) -> bool {
        self.x.0 >= lower
            && self.y.0 >= lower
            && self.z.0 >= lower
            && self.x.1 <= higher
            && self.y.1 <= higher
            && self.z.1 <= higher
    }
}

fn compute<'c, I>(cuboids: I) -> u64
where
    I: Iterator<Item = &'c Cuboid>,
{
    cuboids
        .fold(Vec::new(), |mut final_cuboids, current_cuboid| {
            let mut overlaps: Vec<Cuboid> = final_cuboids
                .iter()
                .map(|previous_cuboid| current_cuboid.overlap(previous_cuboid))
                .filter(|overlap| overlap.is_valid())
                .collect();

            final_cuboids.append(&mut overlaps);

            if current_cuboid.toggled {
                final_cuboids.push(current_cuboid.clone());
            }

            final_cuboids
        })
        .iter()
        .fold(0, |sum, cuboid| match cuboid.toggled {
            true => sum + cuboid.volume(),
            false => sum - cuboid.volume(),
        })
}

fn main() {
    let cuboids: Vec<Cuboid> = FILE_CONTENTS
        .trim()
        .lines()
        .map(|line| {
            let (state, cube_str) = line.trim().split_once(' ').unwrap();
            let mut dimensions = cube_str.split(',').map(|dimension| {
                let (lower, higher) = dimension[2..].split_once("..").unwrap();
                (
                    lower.parse::<i64>().unwrap(),
                    higher.parse::<i64>().unwrap() + 1,
                )
            });

            Cuboid::new(
                dimensions.next().unwrap(),
                dimensions.next().unwrap(),
                dimensions.next().unwrap(),
                state == "on",
            )
        })
        .collect();

    println!(
        "Part 1: {}",
        compute(cuboids.iter().filter(|cuboid| cuboid.in_range(-50, 50)))
    );
    println!("Part 2: {}", compute(cuboids.iter()));
}
