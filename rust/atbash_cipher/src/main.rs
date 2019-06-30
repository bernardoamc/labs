fn cipher(ch: char) -> char {
    if ch.is_digit(10) {
        ch
    } else {
        ('z' as u8 - ch as u8 + 'a' as u8) as char
    }
}

fn main() {
    let message = String::from("test");

    let cipher: String = message
        .chars()
        .filter(|&ch| ch.is_ascii())
        .filter(|&ch| ch.is_alphanumeric())
        .map(cipher)
        .collect::<Vec<char>>()
        .into_iter()
        .collect();

    println!("{}", cipher);
}
