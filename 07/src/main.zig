const std = @import("std");

const input_file = "data/input";

fn Pow(b: usize, e: usize) usize {
    var x: usize = 1;
    for (0..e) |_| {
        x *= b;
    }
    return x;
}

fn Combinations(allocator: *std.mem.Allocator, nops: usize, nunique: usize) !struct {
    combos: [][]i2,
    combos_m: []i2,
} {
    var combos_m = try allocator.alloc(i2, nunique * nops);
    var combos = try allocator.alloc([]i2, nunique);

    for (0..nunique) |i| {
        combos[i] = combos_m[i * nops .. i * nops + nops];
        var x = i;
        for (0..nops) |j| {
            combos_m[i * nops + j] = @intCast(x & 1);
            x >>= 1;
        }
    }

    return .{ .combos = combos, .combos_m = combos_m };
}

pub fn main() !void {
    var res: i64 = 0;

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

        var k: i64 = 0;
        var p: usize = 0;
        var v = std.ArrayList(i64).init(allocator);
        defer v.deinit();

        if (sl.next()) |x| {
            k = try std.fmt.parseInt(i64, x, 10);
        }

        if (sl.next()) |x| {
            var sn = std.mem.split(u8, x, " ");
            while (sn.next()) |num| {
                if (num.len == 0) {
                    continue;
                }
                const pnum = try std.fmt.parseInt(i64, num, 10);
                try v.append(pnum);

                p += 1;
            }
        }
        p -= 1;

        const c = try Combinations(&allocator, p, Pow(2, p));
        defer allocator.free(c.combos_m);
        defer allocator.free(c.combos);

        for (c.combos) |combo| {
            var x: i64 = v.items[0];

            var xi: usize = 1;
            for (0..combo.len) |i| {
                if (combo[i] == 0) {
                    x += v.items[xi];
                } else {
                    x *= v.items[xi];
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
