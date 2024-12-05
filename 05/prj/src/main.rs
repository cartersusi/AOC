use std::fs::File;
use std::io::{self, BufReader, BufRead};
use std::path::Path;

const FILE_PATH: &str = "data/input";

fn main() -> io::Result<()> {
    if !Path::new(FILE_PATH).exists() {
        eprintln!("File not found: {}", FILE_PATH);
        return Ok(());
    }

    let file = File::open(FILE_PATH)?;
    let reader = BufReader::new(file);

    for (line_number, line) in reader.lines().enumerate() {
        let line = line?;
        println!("Line {}: {}", line_number + 1, line);
    }

    Ok(())
}
