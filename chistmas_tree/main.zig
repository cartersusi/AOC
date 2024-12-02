const std = @import("std");
const globals = @import("compv.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const lines = comptime compTree();

    const until_cmas = 1735106400 - std.time.timestamp();
    if (until_cmas < 0) {
        try stdout.print("Christmas has already passed!\n", .{});
        return;
    }

    const days: i64 = @divFloor(until_cmas, 24 * 60 * 60) + 1;
    //const hours: i64 = @divFloor(@rem(until_cmas, 24 * 60 * 60), 60 * 60);
    //const minutes: i64 = @divFloor(@rem(@rem(until_cmas, 24 * 60 * 60), 60 * 60), 60);
    //const seconds: i64 = @rem(until_cmas, 60);

    try stdout.print("{d} Days Until Christmas\n", .{days});

    for (lines) |row| {
        for (row) |cell| {
            try stdout.print("{s}", .{cell});
        }
        try stdout.print("\n", .{});
    }

    try stdout.print("\n", .{});
    if (days < 25) {
        try stdout.print("Today's Problem: https://adventofcode.com/2024/day/{d}\n", .{25 - days});
    }
}

fn compTree() [27][54][]const u8 {
    var lines: [27][54][]const u8 = undefined;

    for (0..27) |i| {
        for (0..54) |j| {
            lines[i][j] = @ptrCast(std.fmt.comptimePrint("{s}{c}{s}", .{ globals.colors[@as(usize, @intCast(globals.color[i][j]))], globals.tree[i][j], globals.reset }));
        }
    }

    return lines;
}
