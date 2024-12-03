const std = @import("std");
const Day3 = @import("day3.zig");
const Day2 = @import("day2.zig");
const Day1 = @import("day1.zig");
const Utils = @import("utils.zig");

pub fn main() !void {
    //var test_array: [1000]u32 = undefined;
    //for (0..1000) |i| {
    //    test_array[i] = std.crypto.random.int(u32) % 90000 + 10000;
    //}

    //const start_time = std.time.microTimestamp();
    //std.mem.sortUnstable(u32, test_array[0..], {}, comptime std.sort.asc(u32));

    //Utils.radixSort(test_array[0..]);
    //const end_time = std.time.microTimestamp();
    //std.debug.print("Elapsed time: {d:.3} ms\n", .{@as(f64, @floatFromInt(end_time - start_time)) / 1000.0});

    std.debug.print("------- DAY 1 -- PART 1 -------\n", .{});
    try Day1.part1();
    std.debug.print("------- DAY 1 -- PART 2 -------\n", .{});
    try Day1.part2();
    std.debug.print("------- DAY 2 -- PART 1 -------\n", .{});
    try Day2.part1();
    std.debug.print("------- DAY 2 -- PART 2 -------\n", .{});
    try Day2.part2();
    std.debug.print("------- DAY 3 -- PART 1 -------\n", .{});
    try Day3.part1();
    std.debug.print("------- DAY 3 -- PART 2 -------\n", .{});
    try Day3.part2();
}
