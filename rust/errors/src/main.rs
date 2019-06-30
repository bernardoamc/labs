// Investigating how to deal with functions that return Result<T, E>

use std::io;
use std::io::Read;
use std::fs::File;

fn read_file_1() -> Result<String, io::Error> {
    let f = File::open("i_do_not_exist.txt");

    let mut f = match f {
        Ok(file) => file,
        Err(e) => return Err(e),
    };

    let mut s = String::new();

    match f.read_to_string(&mut s) {
        Ok(_) => Ok(s),
        Err(e) => Err(e),
    }
}

// This function does exactly the same as the function above.
// The `?` will return in case of error after passing the error to
// From::from that will convert the exception to our return type
// and return from the function.
// In the case of success the flow continues.
fn read_file_2() -> Result<String, io::Error> {
    let mut f = File::open("i_do_not_exist.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}

// Same thing as the function above!
fn read_file_3() -> Result<String, io::Error> {
    let mut s = String::new();
    File::open("i_do_not_exist.txt")?.read_to_string(&mut s)?;
    Ok(s)
}

// Same thing as function above!
fn read_file_4() -> Result<String, io::Error> {
    std::fs::read_to_string("i_do_not_exist.txt")
}

fn main() {
    read_file_1().unwrap();

    read_file_2().expect("Things went wrong");

    let result = match read_file_3() {
        Ok(s) => s,
        Err(e) => panic!("Adios!"),
    };

    read_file_4().unwrap_or_else(|error| {
        panic!("Crash and burn");
    });
}
