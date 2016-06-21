struct Circle {
  x: f64,
  y: f64,
  radius: f64,
}

trait HasArea {
  fn area(&self) -> f64;
}

impl HasArea for Circle {
  fn area(&self) -> f64 {
    std::f64::consts::PI * (self.radius * self.radius)
  }
}

struct Square {
  x: f64,
  y: f64,
  side: f64,
}

impl HasArea for Square {
  fn area(&self) -> f64 {
    self.side * self.side
  }
}

fn main() {
  let mut x: Vec<i32> = vec![1, 2, 3];

  add_4(&mut x);

  for v in &x {
    println!("Value: {}", v);
  }

  static FOO: i32 = 5;
  let x: &'static i32 = &FOO;

  println!("Value of x is: {}", x);
  println!("Value of *x is: {}", *x);

  // TRAITS --------------

  let c = Circle {
    x: 0.0f64,
    y: 0.0f64,
    radius: 1.0f64,
  };

  let s = Square {
    x: 0.0f64,
    y: 0.0f64,
    side: 1.0f64,
  };

  print_area(c);
  print_area(s);
}

fn add_4(v: &mut Vec<i32>) {
  v.push(4)
}

fn print_area<T: HasArea>(shape: T) {
  println!("This shape has an area of {}", shape.area());
}
