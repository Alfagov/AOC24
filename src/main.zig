const std = @import("std");
const Day3 = @import("day3.zig");
const Day2 = @import("day2.zig");
const Day1 = @import("day1.zig");
const Utils = @import("utils.zig");
const Benchmark = @import("benchmark.zig").benchmark;
const CLI = @import("cli.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(gpa.allocator());
    defer std.process.argsFree(gpa.allocator(), args);

    try CLI.run(args);
}
