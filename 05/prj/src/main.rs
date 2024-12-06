use std::fs::File;
use std::io::{self, BufReader, BufRead};
use std::path::Path;
use std::collections::HashSet;
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

fn contains(x: &Vec<i32>, y: i32) -> bool {
    x.iter().any(|&z| z == y)
}

fn validate_and_fix_page_order(
    new_page_order: &mut Vec<Vec<i32>>,
    page_order_rules: &HashMap<i32, Vec<i32>>,
) -> bool {
    let mut valid = true;

    for x in new_page_order {
        let len = x.len();

        let reversed_x = x.iter().rev().cloned().collect::<Vec<_>>();
        for (i, y) in reversed_x.iter().enumerate() {
            if let Some(rules) = page_order_rules.get(y) {
                let trailing: Vec<i32> = x[0..len - i].to_vec();
                for (j, &t) in trailing.iter().enumerate() {
                    if rules.contains(&t) {
                        valid = false;

                        let tmp = x.remove(len - 1 - i);
                        x.insert(j, tmp);
                        break;
                    }
                }
            }
        }
    }

    valid
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
            if nums.len() < 2 {
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
        page_order_rules.entry(x).or_insert_with(Vec::new).push(y);
    }

    let mut invalid_indices: HashSet<usize> = HashSet::new();
    let mut invalid_i: usize = 0;
    for x in &mut page_order {
        let len = x.len();

        let reversed_x = x.iter().rev().collect::<Vec<_>>();
        for (i, y) in reversed_x.iter().enumerate() {
            let rules = page_order_rules.get(y);
            if rules.is_none() {
                continue;
            }

            let trailing: &Vec<i32> = &x[0..len-i].to_vec();
            for t in trailing {
                if let Some(r) = rules {
                    if contains(r, *t) {
                        invalid_indices.insert(invalid_i);
                        break;
                    }
                }
            }
        }

        invalid_i += 1;
    }
    println!("Invalid indices: {:?}", invalid_indices);

    let mut invalid_orders: Vec<Vec<i32>> = Vec::new();
    for val in &invalid_indices {
        invalid_orders.push(page_order[*val].clone());
    }

    while !validate_and_fix_page_order(&mut invalid_orders, &page_order_rules) {
        println!("Re-validating...");
    }

    let mut res: i64 = 0;
    for (page_order_i, x) in invalid_orders.iter().enumerate() {
        println!("Page order {} is invalid", page_order_i);
        let median = x.len() / 2;
        res += x[median] as i64;
    }

    println!("Result: {}", res);

    Ok(())
}
