use std::fs::File;
use std::io::{self, BufReader, BufRead};
use std::path::Path;
use std::collections::HashMap;

const FILE_PATH: &str = "data/input";

fn str_to_int(s: &str) -> i32 {
    match s.parse::<i32>() {
        Ok(n) => n,
        Err(_) => {
            eprintln!("Error: {} is not a number", s);
            0
        }
    }
}

fn contains(x: &Vec<i32>, y: i32) -> i32 {
    for (i, z) in x.iter().enumerate() {
        if *z == y {
            return i as i32;
        }
    }
    -1
}

fn main() -> io::Result<()> {
    if !Path::new(FILE_PATH).exists() {
        eprintln!("File not found: {}", FILE_PATH);
        return Ok(());
    }
    let mut page_order_rules: HashMap<i32, Vec<i32>> = HashMap::new();
    let mut page_order: Vec<Vec<i32>> = Vec::new();
    
    let file = File::open(FILE_PATH)?;
    let reader = BufReader::new(file);
    let mut ln: usize = 0;
    for line in reader.lines() {
        let line = line?;
        
        let nums: Vec<&str> = line.split('|').collect();
        if nums.len() < 2 {
            let nums: Vec<&str> = line.split(',').collect();
            if nums.len() < 2 { // spacer line
                continue;
            }

            page_order.push(Vec::new());
            for x in &nums {
                page_order[ln].push(str_to_int(x));
            }
            ln += 1;
            continue;
        }

        let x = str_to_int(nums[0]);
        let y = str_to_int(nums[1]);
        if let Some(q) = page_order_rules.get_mut(&x) {
            q.push(y);
        } else {
            page_order_rules.insert(x, vec![y]);
        }
    }

    let mut res: i64 = 0;
    for x in &mut page_order {
        let len = x.len();
        let mut valid = true;

        let reversed_x = x.iter().rev().collect::<Vec<_>>();
        for (i, y) in reversed_x.iter().enumerate() {
            println!("Checking for x[{}] = {:?}", len-i, y);
            let rules = page_order_rules.get(y);
            if rules.is_none() {
                continue;
            }

            let trailing: &Vec<i32> = &x[0..len-i].to_vec();
            for (j, t) in trailing.iter().enumerate() { // j should always be within range of 0..x.len()
                if let Some(r) = rules {
                    let failure = contains(r, *t);
                    if failure != -1 {
                        println!("Failure detected at {} for {:?}", x[j], x[len-i-1]);
                        //vec.swap(1, 3);
                        x.swap(j, len-i-1);
                        valid = false;
                    }
                }
            }
        }
        if !valid {
            let median = len / 2;
            res += x[median] as i64;
        }

        println!();
    }

    println!("Result: {}", res);

    Ok(())
}
