const fname = "data/input";
const f = Bun.file(fname);
const data = await f.text();

function Print(...x: any) {
    console.log(x);
}

var fs: number[] = new Array();
for (let i = 0; i < parseInt(data[0], 10); i++) {
    fs.push(0);
}

let m = 1;
for (let i = 1; i < data.length; i++) {
    const n = parseInt(data[i], 10);
    if (i % 2 == 0) {
        for (let j = 0; j < n; j++) {
            fs.push(m);
        }
        m++;
    } else {
        for (let j = 0; j < n; j++) {
            fs.push(NaN);
        }
    }
}

for (let i = 1; i < fs.length; i++) {
    const x = fs[i];
    if (!Number.isNaN(x)) {
        continue;
    }
    
    for (let j = fs.length - 1; j > i; j--) {
        if (!Number.isNaN(fs[j])) {
            fs[i] = fs[j];
            fs[j] = NaN;
            break;
        }
    }

}

Print(fs);

let res = 0;
for (let i = 0; i < fs.length; i++) {
    const x = fs[i];
    if (Number.isNaN(x)) {
        continue;
    }

    res += x * i;
}

Print("Result", res)