#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref FILE_CONTENTS: String = std::fs::read_to_string("data/example.txt").unwrap();
}

#[derive(Debug)]
struct Target {
    min_x: i64,
    max_x: i64,
    min_y: i64,
    max_y: i64,
}

impl Target {
    fn new(x_bounds: (i64, i64), y_bounds: (i64, i64)) -> Self {
        Self {
            min_x: x_bounds.0,
            max_x: x_bounds.1,
            min_y: y_bounds.0,
            max_y: y_bounds.1,
        }
    }

    // When y is at its highest point it means that:
    //   * vy = 0
    // When y reaches 0 again it means that:
    //   * vy = -v0y; (negative initial velocity)
    // We need a velocity that when vy = (-v0y - 1) then y will reach the lower end of our target.
    // Hence, the maximum height will be: V+V-1+..2+1, which is equivalent to (V+1)*(V/2)
    // Assuming the target has a negative y in relation to the starting point.
    fn find_highest_point(&self) -> i64 {
        let maximum_velocity: i64 = (-self.min_y - 1).abs();
        maximum_velocity * (maximum_velocity + 1) / 2
    }

    fn compute_possible_velocities(&self) -> u32 {
        let maximum_y_velocity: i64 = (-self.min_y - 1).abs();
        let mut valid_velocities = 0;

        for y_velocity in self.min_y..=maximum_y_velocity {
            for x_velocity in 0..=self.max_x {
                if self.hits_target(x_velocity, y_velocity) {
                    valid_velocities += 1;
                }
            }
        }

        valid_velocities
    }

    fn hits_target(&self, mut x_velocity: i64, mut y_velocity: i64) -> bool {
        let mut x = 0;
        let mut y = 0;

        loop {
            x += x_velocity;
            y += y_velocity;
            x_velocity -= x_velocity.signum();
            y_velocity -= 1;

            match (
                self.min_x <= x && x <= self.max_x,
                self.min_y <= y && y <= self.max_y,
            ) {
                (true, true) => {
                    return true;
                }
                (false, _) if x_velocity == 0 => return false,
                (_, false) if y_velocity < 0 && y < self.min_y => return false,
                _ => {}
            }
        }
    }
}

fn main() {
    let coordinates: Vec<(i64, i64)> = FILE_CONTENTS
        .trim()
        .split(':')
        .skip(1)
        .flat_map(|target| {
            target.trim().split(',').map(|coordinate| {
                let coordinate = coordinate.trim();
                let (c0, c1) = &coordinate[2..].trim().split_once("..").unwrap();
                (c0.parse::<i64>().unwrap(), c1.parse::<i64>().unwrap())
            })
        })
        .collect();

    if let [x, y] = &coordinates[..] {
        let target = Target::new(*x, *y);
        println!("Part 1: {}", target.find_highest_point());
        println!("Part 2: {}", target.compute_possible_velocities());
    };
}
