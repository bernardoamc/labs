#[derive(PartialEq)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

#[derive(PartialEq)]
enum Axis {
    X,
    Y,
}
impl Direction {
    fn to_coordinate(&self) -> (i64, i64) {
        match self {
            Direction::Up => (0, 1),
            Direction::Down => (0, -1),
            Direction::Left => (-1, 0),
            Direction::Right => (1, 0),
        }
    }

    fn to_left(&self) -> Direction {
        match self {
            Direction::Up => Direction::Left,
            Direction::Down => Direction::Right,
            Direction::Left => Direction::Down,
            Direction::Right => Direction::Up,
        }
    }

    fn to_axis(&self) -> Axis {
        match self {
            Direction::Up | Direction::Down => Axis::Y,
            Direction::Left | Direction::Right => Axis::X,
        }
    }
}

struct SquareSpiral {
    x: i64,
    y: i64,
    steps: i64,
    direction: Direction
}

impl SquareSpiral {
    fn new() -> SquareSpiral {
        SquareSpiral { x: 0, y: 0, steps: 1, direction: Direction::Right }
    }
}

impl Iterator for SquareSpiral {
    type Item = (i64, i64);

    fn next(&mut self) -> Option<Self::Item> {
        let (dx, dy) = self.direction.to_coordinate();

        match self.direction.to_axis() {
            Axis::X => {
                self.x += dx;

                if 2 * self.x * dx > self.steps {
                    self.direction = self.direction.to_left();
                }
            }
            Axis::Y => {
                self.y += dy;
                
                if 2 * self.y * dy > self.steps {
                    self.direction = self.direction.to_left();

                    if self.direction == Direction::Right {
                        self.steps += 1;
                    }
                }
            }
        }

        Some((self.x, self.y))
    }
}

fn main() {
    let spiral = SquareSpiral::new();

    println!("{:?}", spiral.skip(9).next());
}
