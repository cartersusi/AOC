const std = @import("std");

const input_file = "data/input";

fn Pow(b: usize, e: usize) usize {
    var x: usize = 1;
    for (0..e) |_| {
        x *= b;
    }
    return x;
}

fn Concat(l: i128, r: i128) i128 {
    return l * Pow(10, std.math.log10(@as(usize, @intCast(r))) + 1) + r;
}

fn Combinations(allocator: *std.mem.Allocator, nops: usize, nunique: usize, npossible: usize) !struct {
    combos: [][]i3,
    combos_m: []i3,
} {
    var combos_m = try allocator.alloc(i3, nunique * nops);
    var combos = try allocator.alloc([]i3, nunique);

    // 0 = add
    // 1 = mul
    // 2 = concat

    for (0..nunique) |i| {
        combos[i] = combos_m[i * nops .. i * nops + nops];
        var x = i;
        for (0..nops) |j| {
            combos_m[i * nops + j] = @intCast(x % npossible);
            x /= npossible;
        }
    }

    return .{ .combos = combos, .combos_m = combos_m };
}

pub fn main() !void {
    var res: i128 = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile(input_file, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var sl = std.mem.split(u8, line, ":");

        var k: i128 = 0;
        var p: usize = 0;
        var v = std.ArrayList(i128).init(allocator);
        defer v.deinit();

        if (sl.next()) |x| {
            k = try std.fmt.parseInt(i128, x, 10);
        }

        if (sl.next()) |x| {
            var sn = std.mem.split(u8, x, " ");
            while (sn.next()) |num| {
                if (num.len == 0) {
                    continue;
                }
                const pnum = try std.fmt.parseInt(i128, num, 10);
                try v.append(pnum);

                p += 1;
            }
        }
        p -= 1;

        // Part 1
        //const nunique = Pow(2, p);
        //const c = try Combinations(&allocator, p, nunique, 2);

        // Part 2
        const nunique = Pow(3, p);
        const c = try Combinations(&allocator, p, nunique, 3);

        defer allocator.free(c.combos_m);
        defer allocator.free(c.combos);

        for (c.combos) |combo| {
            var x: i128 = v.items[0];

            var xi: usize = 1;
            for (0..combo.len) |i| {
                if (combo[i] == 0) {
                    x += v.items[xi];
                } else if (combo[i] == 1) {
                    x *= v.items[xi];
                } else {
                    x = Concat(x, v.items[xi]);
                }

                xi += 1;
            }

            if (x == k) {
                res += k;
                break;
            }
        }
    }

    std.debug.print("Result {d} ", .{res});
}
