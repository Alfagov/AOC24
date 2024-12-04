const std = @import("std");
const Cli = @import("cli.zig");

const Day4 = @import("day4.zig");
const Day3 = @import("day3.zig");
const Day2 = @import("day2.zig");
const Day1 = @import("day1.zig");

const solutions = std.StaticStringMap(Cli.DaySolution).initComptime(.{
    .{ "1", .{ .part1 = Day1.part1, .part2 = Day1.part2 } },
    .{ "2", .{ .part1 = Day2.part1, .part2 = Day2.part2 } },
    .{ "3", .{ .part1 = Day3.part1, .part2 = Day3.part2 } },
    .{ "4", .{ .part1 = Day4.part1, .part2 = Day4.part2 } },
});

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(gpa.allocator());
    defer std.process.argsFree(gpa.allocator(), args);

    try Cli.run(args, solutions);
}
