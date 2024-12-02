const std = @import("std");
const Utils = @import("utils.zig");

pub fn part2() !void {
    const start_time = std.time.microTimestamp();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const file = try std.fs.cwd().openFile("data/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var left = std.AutoArrayHashMap(u32, u32).init(gpa.allocator());
    defer left.deinit();
    var right = std.AutoArrayHashMap(u32, u32).init(gpa.allocator());
    defer right.deinit();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var line_stream = std.io.fixedBufferStream(line);
        var line_reader = line_stream.reader();

        var left_num_buf: [10]u8 = undefined;
        var right_num_buf: [10]u8 = undefined;

        const left_num = try line_reader.readUntilDelimiter(&left_num_buf, ' ');
        _ = try line_reader.readByte();
        _ = try line_reader.readByte();
        const right_num = try line_reader.readUntilDelimiterOrEof(&right_num_buf, ' ');
        const l = try std.fmt.parseInt(u32, left_num, 10);
        const r = try std.fmt.parseInt(u32, right_num.?, 10);

        if (left.get(l)) |l_v| {
            try left.put(l, l_v + 1);
        } else {
            try left.put(l, 1);
        }

        if (right.get(r)) |r_v| {
            try right.put(r, r_v + 1);
        } else {
            try right.put(r, 1);
        }
    }

    var acc: u32 = 0;
    var l_iterator = left.iterator();

    while (l_iterator.next()) |l_value| {
        if (right.get(l_value.key_ptr.*)) |r_v| {
            acc += l_value.key_ptr.* * l_value.value_ptr.* * r_v;
        }
    }

    const end_time = std.time.microTimestamp();
    std.debug.print("Elapsed time: {d:.3} ms\n", .{@as(f64, @floatFromInt(end_time - start_time)) / 1000.0});
    std.debug.print("RESULT {}\n", .{acc});
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

pub fn part1() !void {
    const start_time = std.time.microTimestamp();
    var processor = Part1Processor{};
    var file_reader = try Utils.FileLineReaderAccumulator.init("data/input.txt");

    try file_reader.readFile(processor.getCallback());
    const distance = processor.calculateDistance();

    const end_time = std.time.microTimestamp();
    std.debug.print("Elapsed time: {d:.3} ms\n", .{@as(f64, @floatFromInt(end_time - start_time)) / 1000.0});
    std.debug.print("Total safe sequences: {}\n", .{distance});
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
