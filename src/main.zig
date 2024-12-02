const std = @import("std");
const Day2 = @import("day2.zig");
const Day1 = @import("day1.zig");

pub fn main() !void {
    std.debug.print("------- DAY 1 -- PART 1 -------\n", .{});
    try Day1.part1();
    //std.debug.print("------- DAY 1 -- PART 2 -------\n", .{});
    //try Day1.part2();
    //std.debug.print("------- DAY 2 -- PART 1 -------\n", .{});
    //try Day2.part1();
    //std.debug.print("------- DAY 2 -- PART 2 -------\n", .{});
    //try Day2.part2();
}
