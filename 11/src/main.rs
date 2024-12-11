use std::fs::File;
use std::io::{BufRead, BufReader};

const FILE_PATH: &str = "data/input";
const BLINKS: usize = 75;

const YEAR: u64 = 2024;

fn input() -> Vec<u64> {
    let file = File::open(FILE_PATH).unwrap();
    let reader = BufReader::new(file);

    let line = reader.lines().next().unwrap().unwrap();
    let split = line.split(" ");
    let split = split.collect::<Vec<&str>>();

    split
        .iter()
        .map(|x| x.parse::<u64>().unwrap())
        .collect::<Vec<u64>>()
}

fn blink(stones: &[u64]) -> Vec<u64> {
    let mut ret = Vec::with_capacity(stones.len() * 2);
    for &stone in stones {
        if stone == 0 {
            ret.push(1);
        } else {
            let mut len = 0;
            let mut temp = stone;
            while temp > 0 {
                len += 1;
                temp /= 10;
            }
            if len % 2 == 0 {
                let divisor = 10_u64.pow((len / 2) as u32);
                let left = stone / divisor;
                let right = stone % divisor;
                ret.push(left);
                ret.push(right);
            } else {
                ret.push(stone * YEAR);
            }
        }
    }
    ret
}

fn main() {
    let mut stones = input();
    println!("{:?}", stones);

    for i in 0..BLINKS {
        println!("Blink {}", i);
        stones = blink(&stones);
    }

    println!("After {} blinks: {:?} stones", BLINKS, stones.len());
}
