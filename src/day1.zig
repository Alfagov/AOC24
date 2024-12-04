const std = @import("std");
const Utils = @import("utils.zig");

const Part2Processor = struct {
    lhs: *std.AutoArrayHashMap(u32, u32),
    rhs: *std.AutoArrayHashMap(u32, u32),

    const Self = @This();

    pub fn getCallback(self: *Self) Utils.AccumulatorCallback {
        return .{
            .ptr = self,
            .callbackFn = callback,
        };
    }

    pub fn callback(ptr: *anyopaque, line: []const u8) !void {
        var self: *Self = @ptrCast(@alignCast(ptr));

        const left = parseInt(line[0..5]);
        const right = parseInt(line[8..]);

        if (self.lhs.getEntry(left)) |entry| {
            entry.value_ptr.* = entry.value_ptr.* + 1;
        } else {
            self.lhs.putAssumeCapacity(left, 1);
        }

        if (self.rhs.getEntry(right)) |entry| {
            entry.value_ptr.* = entry.value_ptr.* + 1;
        } else {
            self.rhs.putAssumeCapacity(right, 1);
        }
    }

    pub fn calculateDistance(self: *Self) usize {
        var acc: u32 = 0;
        var l_iterator = self.lhs.iterator();

        while (l_iterator.next()) |l_value| {
            if (self.rhs.get(l_value.key_ptr.*)) |r_v| {
                acc += l_value.key_ptr.* * l_value.value_ptr.* * r_v;
            }
        }

        return acc;
    }
};

pub fn part2() !i64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var left = std.AutoArrayHashMap(u32, u32).init(gpa.allocator());
    defer left.deinit();
    try left.ensureTotalCapacity(1000);
    var right = std.AutoArrayHashMap(u32, u32).init(gpa.allocator());
    defer right.deinit();
    try right.ensureTotalCapacity(1000);

    var processor = Part2Processor{ .lhs = &left, .rhs = &right};
    var file_reader = try Utils.FileLineReaderAccumulator.init("data/input.txt");
    defer file_reader.deinit();

    try file_reader.readFile(processor.getCallback());
    const distance = processor.calculateDistance();

    return @intCast(distance);
}


const Part1Processor = struct {
    head: usize = 0,
    lhs: [1000]u32 = undefined,
    rhs: [1000]u32 = undefined,

    const Self = @This();

    pub fn getCallback(self: *Self) Utils.AccumulatorCallback {
        return .{
            .ptr = self,
            .callbackFn = callback,
        };
    }

    pub fn callback(ptr: *anyopaque, line: []const u8) !void {
        var self: *Self = @ptrCast(@alignCast(ptr));

        self.lhs[self.head] = parseInt(line[0..5]);
        self.rhs[self.head] = parseInt(line[8..]);
        self.head += 1;
    }

    pub fn calculateDistance(self: *Self) usize {
        std.mem.sortUnstable(u32, &self.lhs, {}, comptime std.sort.asc(u32));
        std.mem.sortUnstable(u32, &self.rhs, {}, comptime std.sort.asc(u32));

        var count: usize = 0;
        for (self.lhs, self.rhs) |lhs, rhs| {
            if (lhs > rhs) {
                count += lhs - rhs;
            } else {
                count += rhs - lhs;
            }
        }

        return count;
    }
};

pub fn part1() !i64 {
    var processor = Part1Processor{};
    var file_reader = try Utils.FileLineReaderAccumulator.init("data/input.txt");
    defer file_reader.deinit();

    try file_reader.readFile(processor.getCallback());
    const distance = processor.calculateDistance();
    return @intCast(distance);
}

pub fn parseInt(buffer: []const u8) u32 {
    var out: u32 = 0;
    for (0..5) |index| {
        if (std.ascii.isDigit(buffer[index])) {
            out = out * 10 + (buffer[index] - '0');
        } else {
            break;
        }
    }

    return out;
}

pub fn parseNumber(buffer: []const u8) !u32 {
    var idx: usize = 0;
    for (buffer) |c| {
        if (!std.ascii.isDigit(c)) {
            break;
        }

        idx += 1;
    }

    return try std.fmt.parseInt(u32, buffer[0..idx], 10);
}