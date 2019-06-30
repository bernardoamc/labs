use std::collections::HashMap;

fn main() {
    let yo = vec![1, 2, 3];
    let mut yo_hash = HashMap::new();

    yo_hash.insert(String::from("a"), 100);
    yo_hash.insert(String::from("b"), 200);

    println!("{}", yo[0]);
    println!("{}", (*yo)[0]);
    println!("{}", &yo[0]);  // WAT, automatic dereference?
    println!("{:?}", yo.get(1));

    println!("{:?}", yo_hash.get("a"));
    println!("{:?}", yo_hash.get("b"));
}
