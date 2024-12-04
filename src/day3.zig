const std = @import("std");
const Utils = @import("utils.zig");

const Part2Processor = struct {
    accumulator: usize = 0,
    mul_enable: bool = true,

    const Self = @This();

    pub fn getCallback(self: *Self) Utils.AccumulatorCallback {
        return .{
            .ptr = self,
            .callbackFn = callback,
        };
    }

    pub fn callback(ptr: *anyopaque, line: []const u8) !void {
        var self: *Self = @ptrCast(@alignCast(ptr));

        var line_buf: []u8 = @constCast(line[0..]);
        wh: while (line_buf.len > 0) {
            const c = line_buf[0];
            switch (c) {
                'd' => {
                    if (std.mem.indexOfDiff(u8, line_buf[0..4], "do()")) |_| {
                        if (std.mem.indexOfDiff(u8, line_buf[0..7], "don't()")) |diff_idx| {
                            line_buf = line_buf[diff_idx..];
                        } else {
                            line_buf = line_buf[7..];
                            self.mul_enable = false;
                        }
                    }  else {
                        line_buf = line_buf[4..];
                        self.mul_enable = true;
                    }
                },
                'm' => {
                    var num1: u32 = 0;
                    var num2: u32 = 0;

                    if (std.mem.indexOfDiff(u8, line_buf[0..4], "mul(")) |diff_idx| {
                        line_buf = line_buf[diff_idx..];
                    } else {
                        line_buf = line_buf[4..];
                        for (line_buf[0..], 0..) |value, idx| {
                            if (std.ascii.isDigit(value)) {
                                num1 = num1 * 10 + (value - '0');
                            } else if (value == ',') {
                                line_buf = line_buf[idx + 1 ..];
                                break;
                            } else {
                                line_buf = line_buf[idx..];
                                continue :wh;
                            }
                        }

                        for (line_buf[0..], 0..) |value, idx| {
                            if (std.ascii.isDigit(value)) {
                                num2 = num2 * 10 + (value - '0');
                            } else if (value == ')') {
                                line_buf = line_buf[idx + 1 ..];
                                break;
                            } else {
                                line_buf = line_buf[idx..];
                                continue :wh;
                            }
                        }

                        if (self.mul_enable) {
                            self.accumulator += num1 * num2;
                        }
                    }
                },
                else => line_buf = line_buf[1..],
            }
        }
    }
};

const Part1Processor = struct {
    accumulator: usize = 0,

    const Self = @This();

    pub fn getCallback(self: *Self) Utils.AccumulatorCallback {
        return .{
            .ptr = self,
            .callbackFn = callback,
        };
    }

    pub fn callback(ptr: *anyopaque, line: []const u8) !void {
        var self: *Self = @ptrCast(@alignCast(ptr));

        var line_buf: []u8 = @constCast(line[0..]);
        wh: while (line_buf.len > 0) {
            const c = line_buf[0];

            if (c == 'm') {
                if (std.mem.eql(u8, line_buf[0..4], "mul(")) {
                    var num1: u32 = 0;
                    var num2: u32 = 0;

                    for (line_buf[4..], 0..) |value, idx| {
                        if (std.ascii.isDigit(value)) {
                            num1 = num1 * 10 + (value - '0');
                        } else if (value == ',') {
                            line_buf = line_buf[5 + idx ..];
                            break;
                        } else {
                            line_buf = line_buf[4..];
                            continue :wh;
                        }
                    }

                    for (line_buf[0..], 0..) |value, idx| {
                        if (std.ascii.isDigit(value)) {
                            num2 = num2 * 10 + (value - '0');
                        } else if (value == ')') {
                            line_buf = line_buf[idx + 1 ..];
                            break;
                        } else {
                            line_buf = line_buf[1..];
                            continue :wh;
                        }
                    }

                    self.accumulator += num1 * num2;
                } else {
                    line_buf = line_buf[1..];
                }
            } else {
                line_buf = line_buf[1..];
            }
        }
    }
};

pub fn part1() !i64 {
    var processor = Part1Processor{};
    var file_reader = try Utils.FileLineReaderAccumulator.init("data/input3.txt");

    try file_reader.readFile(processor.getCallback());

    return @intCast(processor.accumulator);
}

pub fn part2() !i64 {
    var processor = Part2Processor{};
    var file_reader = try Utils.FileLineReaderAccumulator.init("data/input3.txt");

    try file_reader.readFile(processor.getCallback());

    return @intCast(processor.accumulator);
}

pub fn main() !void {
    std.debug.print("------- DAY 3 -- PART 1 -------\n", .{});
    try part1();
    std.debug.print("------- DAY 3 -- PART 2 -------\n", .{});
    try part2();
}