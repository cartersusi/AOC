use std::fs::File;
use std::fmt::Display;
use std::io::{self, BufReader, BufRead};
use std::path::Path;
use std::collections::{HashSet, VecDeque};

const FILE_PATH: &str = "data/example";

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

trait PrintMatrix {
    fn print(&self);
}

impl<T: Display> PrintMatrix for Vec<Vec<T>> {
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

    fn mask(&self, value: char) -> Vec<Vec<char>> {
        self.state.iter().map(|row| {
            row.iter().map(|&c| if c == value { '#' } else { '.' }).collect()
        }).collect()
    }
}

fn perimeter(mask: &Vec<Vec<bool>>) -> usize {
    let rows = mask.len();
    let cols = if rows > 0 { mask[0].len() } else { 0 };

    let mut perimeter = 0;
    for r in 0..rows {
        for c in 0..cols {
            if mask[r][c] {
                let directions = [(1,0),(-1,0),(0,1),(0,-1)];
                for (dx, dy) in directions.iter() {
                    let nx = (r as isize + dx) as usize;
                    let ny = (c as isize + dy) as usize;
                    if nx >= rows || ny >= cols || !mask[nx][ny] {
                        perimeter += 1;
                    }
                }
            }
        }
    }

    perimeter
}

fn fences(mask: Vec<Vec<char>>) -> usize {
    let mut res = 0;
    let rows = mask.len();
    let cols = if rows > 0 { mask[0].len() } else { 0 };

    let mut visited = vec![vec![false; cols]; rows];

    for r in 0..rows {
        for c in 0..cols {
            if mask[r][c] == '#' && !visited[r][c] {
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
                        if nx < rows && ny < cols && mask[nx][ny] == '#' && !visited[nx][ny] {
                            visited[nx][ny] = true;
                            tmp[nx][ny] = true;
                            queue.push_back((nx, ny));
                        }
                    }
                }

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
    g.state.print();

    
    let mut res = 0;
    for unique in g.unique.iter() {
        res += fences(g.mask(*unique));
    }

    println!("Result: {}", res);
}