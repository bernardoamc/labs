#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32
}

impl Rectangle {
    fn square(size: u32) -> Rectangle {
        Rectangle { width: size, height: size }
    }

    fn area(&self) -> u32 {
        self.width * self.height
    }

    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}

fn main() {
    let rec = Rectangle {
        width: 30,
        height: 30
    };

    let other = Rectangle::square(10);

    println!("The area is: {}", area(&rec));
    println!("The area is: {}", rec.width * rec.height);
    println!("The area is: {}", rec.area());
    println!("The rectangle is: {:?}", rec);
    println!("The rectangle is: {:#?}", rec);
    println!("Can rec hold other? {}", rec.can_hold(&other));
}

fn area(rec: &Rectangle) -> u32 {
    rec.width * rec.height
}
