use std::fs::File;
use std::io::{self, BufReader, BufRead};
use std::path::Path;
use std::collections::{HashSet, VecDeque};

const FILE_PATH: &str = "data/input";

fn file2matrix(fpath: &str) -> io::Result<Vec<Vec<char>>> {
    if !Path::new(fpath).exists() {
        return Err(io::Error::new(io::ErrorKind::NotFound, "File not found"));
    }
    let file = File::open(fpath)?;
    let reader = BufReader::new(file);

    let mut matrix: Vec<Vec<char>> = Vec::new();
    for line in reader.lines() {
        let line = line?;
        let row: Vec<char> = line.chars().collect();
        matrix.push(row);
    }

    Ok(matrix)
}

struct Garden {
    state: Vec<Vec<char>>,
    unique: HashSet<char>,
}

impl Garden {
    fn new(fpath: &str) -> Self {
        let matrix = file2matrix(fpath).unwrap();
        let unique_chars: HashSet<char> = matrix.iter().flatten().cloned().collect();
        Self {
            state: matrix,
            unique: unique_chars,
        }
    }
}

trait PrintMatrix {
    fn print(&self);
}

impl PrintMatrix for Vec<Vec<char>> {
    fn print(&self) {
        print!("[\n");
        for row in self.iter() {
            print!("  [ ");
            for c in row.iter() {
                print!("{} ", c);
            }
            print!("],\n");
        }
        print!("]\n");
    }
}

trait PrintBoolMatrix {
    fn print(&self);
}

impl PrintBoolMatrix for Vec<Vec<bool>> {
    fn print(&self) {
        print!("[\n");
        for row in self.iter() {
            print!("  [ ");
            for c in row.iter() {
                print!("{} ", if *c { 1 } else { 0 });
            }
            print!("],\n");
        }
        print!("]\n");
    }
}

fn mask(matrix: &Vec<Vec<char>>, value: char) -> Vec<Vec<char>> {
    matrix.iter().map(|row| {
        row.iter().map(|&c| if c == value { '#' } else { '.' }).collect()
    }).collect()
}

fn perimeter(masked: &Vec<Vec<bool>>) -> usize {
    let rows = masked.len();
    let cols = if rows > 0 { masked[0].len() } else { 0 };

    let mut perimeter = 0;
    for r in 0..rows {
        for c in 0..cols {
            if masked[r][c] {
                let directions = [(1,0),(-1,0),(0,1),(0,-1)];
                for (dx, dy) in directions.iter() {
                    let nx = (r as isize + dx) as usize;
                    let ny = (c as isize + dy) as usize;
                    if nx >= rows || ny >= cols || !masked[nx][ny] {
                        perimeter += 1;
                    }
                }
            }
        }
    }

    perimeter
}

fn sections(masked: &Vec<Vec<char>>) -> usize {
    let mut res = 0;
    let rows = masked.len();
    let cols = if rows > 0 { masked[0].len() } else { 0 };

    let mut visited = vec![vec![false; cols]; rows];
    let mut section_count = 0;

    for r in 0..rows {
        for c in 0..cols {
            if masked[r][c] == '#' && !visited[r][c] {
                section_count += 1;
                let mut tmp = vec![vec![false; cols]; rows];
                
                let mut queue = VecDeque::new();
                queue.push_back((r, c));
                visited[r][c] = true;
                tmp[r][c] = true;

                while let Some((cx, cy)) = queue.pop_front() {
                    let directions = [(1,0),(-1,0),(0,1),(0,-1)];
                    for (dx, dy) in directions.iter() {
                        let nx = (cx as isize + dx) as usize;
                        let ny = (cy as isize + dy) as usize;
                        if nx < rows && ny < cols && masked[nx][ny] == '#' && !visited[nx][ny] {
                            visited[nx][ny] = true;
                            tmp[nx][ny] = true;
                            queue.push_back((nx, ny));
                        }
                    }
                }

                //println!("Section {}: ", section_count);
                //tmp.print();
                let perimeter = perimeter(&tmp);
                let count = tmp.iter().flatten().filter(|&&v| v).count();
                res += count * perimeter;
            }
        }
    }

    res
}

fn main() {
    let g = Garden::new(FILE_PATH);
    //g.state.print();
    //println!("{:?}", g.unique);

    
    let mut res = 0;
    for unique in g.unique.iter() {
        //println!("Masking: {}", unique);
        let masked = mask(&g.state, *unique);
        res += sections(&masked);
        //println!("\n----------------------------------\n");
    }

    println!("Result: {}", res);
}