#[derive(Debug)]
struct Rectangle {
  width: u32,
  height: u32,
}

impl Rectangle {
  // Associate functions are function within an "impl" that doesn't
  // receive an instance of the type. They are called like: type::function
  // In this case: Rectangle::square(value);
  fn square(size: u32) -> Rectangle {
    Rectangle { length: size, width: size }
  }

  fn area(&self) -> u32 {
    self.width * self.height
  }

  fn can_hold(&self, other: &Rectangle) -> bool {
    self.height > other.height && self.width > other.width
  }
}

fn main() {
  let rect1 = Rectangle { height: 50, width: 30 };
  let rect2 = Rectangle { height: 40, width: 10 };
  let rect3 = Rectangle { height: 45, width: 60 };

  println!(
    "The area of the rectangle is {} square pixels.",
    rect1.area()
  );

  println!(
    "Rec1 is {:?}",
    rect1
  );

  println!(
    "Rec1 is {:#?}",
    rect1
  );

  println!("Can rect1 hold rect2? {}", rect1.can_hold(&rect2));
  println!("Can rect1 hold rect3? {}", rect1.can_hold(&rect3));

}
