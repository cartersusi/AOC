use lru::LruCache;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::num::NonZeroUsize;

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

fn blink(stones: &[u64]) -> usize {
    let mut res = 0;
    let mut cache = LruCache::new(NonZeroUsize::new(2048 << 5).unwrap());

    fn lfn(x: u64, i: usize, lru: &mut LruCache<(u64, usize), usize>) -> usize {
        if let Some(&val) = lru.get(&(x, i)) {
            return val;
        }

        let val = if i == BLINKS {
            1
        } else if x == 0 {
            lfn(1, i + 1, lru)
        } else {
            let s = x.to_string();
            let l = s.len();
            if l % 2 == 0 {
                let left = s[..l / 2].parse::<u64>().unwrap();
                let right = s[l / 2..].parse::<u64>().unwrap();
                lfn(left, i + 1, lru) + lfn(right, i + 1, lru)
            } else {
                lfn(x * YEAR, i + 1, lru)
            }
        };

        lru.put((x, i), val);
        val
    }

    for &stone in stones {
        res += lfn(stone, 0, &mut cache);
    }
    res
}

fn main() {
    let stones = input();
    println!("{:?}", stones);

    let res = blink(&stones);
    println!("After {} blinks: {:?} stones", BLINKS, res);
}
