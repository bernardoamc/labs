use std::io;

fn main() {
    println!("Please input your sentence.");

    let mut sentence = String::new();

    io::stdin().read_line(&mut sentence)
      .expect("Failed to read sentence");

    let first_space = first_space(&sentence);

    println!("{}", &sentence[0..first_space]);
}

fn first_space(sentence: &String) -> usize {
    for (i, c) in sentence.chars().enumerate() {
        if c == ' ' {
            return i;
        }
    }

    sentence.len()
}
