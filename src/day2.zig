const std = @import("std");
const Utils = @import("utils.zig");

// So much bad code here, but it works
//
const SequenceDirection = enum {
    Incresing,
    Decreasing,
};

fn isSequenceSafe(
    split_iter: *std.mem.SplitIterator(u8, .sequence),
    skip_index: ?usize,
) !bool {
    var direction: ?SequenceDirection = null;

    var previous_value = brk: {
        if (skip_index != null and skip_index.? == 0) {
            _ = split_iter.first();
            break :brk try Utils.parseInt(i16, split_iter.next().?);
        }
        break :brk try Utils.parseInt(i16, split_iter.first());
    };

    var index: usize = 1;
    while (split_iter.next()) |value| {
        if (skip_index != null and index == skip_index) {
            index += 1;
            continue;
        }

        const current_value = try Utils.parseInt(i16, value);
        const difference = current_value - previous_value;
        if (@abs(difference) > 3 or difference == 0) return false;

        if (direction) |dir| {
            if ((difference > 0 and dir == .Decreasing) or (difference < 0 and dir == .Incresing)) return false;
        } else {
            direction = if (difference > 0) .Incresing else .Decreasing;
        }

        previous_value = current_value;
        index += 1;
    }

    return true;
}

fn checkSequence(
    primary_iter: *std.mem.SplitIterator(u8, .sequence),
    secondary_iter: *std.mem.SplitIterator(u8, .sequence),
) !bool {
    if (try isSequenceSafe(secondary_iter, null)) return true;
    secondary_iter.reset();

    var index: usize = 0;
    while (primary_iter.next()) |_| {
        if (try isSequenceSafe(secondary_iter, index)) return true;
        secondary_iter.reset();
        index += 1;
    }

    return false;
}

fn checkSequence_part1(
    primary_iter: *std.mem.SplitIterator(u8, .sequence),
) !bool {
    if (try isSequenceSafe(primary_iter, null)) return true;
    primary_iter.reset();

    return false;
}

const Part1Processor = struct {
    count: usize = 0,

    const Self = @This();

    pub fn getCallback(self: *Self) Utils.AccumulatorCallback {
        return .{
            .ptr = self,
            .callbackFn = callback,
        };
    }

    pub fn callback(ptr: *anyopaque, line: []const u8) !void {
        var self: *Self = @ptrCast(@alignCast(ptr));

        var split_iterator = std.mem.split(u8, line, " ");

        const safe = try checkSequence_part1(&split_iterator);
        if (safe) self.count += 1;
    }
};

const Part2Processor = struct {
    count: usize = 0,

    const Self = @This();

    pub fn getCallback(self: *Self) Utils.AccumulatorCallback {
        return .{
            .ptr = self,
            .callbackFn = callback,
        };
    }

    pub fn callback(ptr: *anyopaque, line: []const u8) !void {
        var self: *Self = @ptrCast(@alignCast(ptr));

        var split_iterator = std.mem.split(u8, line, " ");
        var second_split = std.mem.split(u8, line, " ");

        const safe = try checkSequence(&split_iterator, &second_split);
        if (safe) self.count += 1;
    }
};

pub fn part2() !i64 {
    var processor = Part2Processor{ .count = 0 };
    var file_reader = try Utils.FileLineReaderAccumulator.init("data/input2.txt");

    try file_reader.readFile(processor.getCallback());

    return @intCast(processor.count);
}

pub fn part1() !i64 {
    var processor = Part1Processor{ .count = 0 };
    var file_reader = try Utils.FileLineReaderAccumulator.init("data/input2.txt");

    try file_reader.readFile(processor.getCallback());

    return @intCast(processor.count);
}

pub fn main() !void {
    std.debug.print("------- DAY 2 -- PART 1 -------\n", .{});
    try part1();
    std.debug.print("------- DAY 2 -- PART 2 -------\n", .{});
    try part2();
}