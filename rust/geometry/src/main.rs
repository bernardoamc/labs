#[derive(Debug)]
enum Geometry {
    Point(i32, i32, i32),
    Square { size: u32 },
    Rectangle { width: u32, height: u32 },
}

impl Geometry {
    fn area(&self) -> u32 {
       match self {
           Geometry::Point(_, _, _) => 0,
           Geometry::Square { size } => size * size,
           Geometry::Rectangle { width, height } => width * height,
       }
    }
}

fn main() {
    let point = Geometry::Point(1, 2, 3);
    let square = Geometry::Square { size: 10 };
    let rectangle = Geometry::Rectangle { width: 10, height: 20 };

    println!("Point: {:#?}", point);
    println!("Point area: {}", point.area());
    println!("Square: {:#?}", square);
    println!("Square area: {}", square.area());
    println!("Rectangle: {:#?}", rectangle);
    println!("Rectangle area: {}", rectangle.area());
}
