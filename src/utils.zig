const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Lines = struct {
    allocator: Allocator,
    lines: std.ArrayList([]const u8),

    pub fn deinit(self: *Lines) void {
        for (self.lines.items) |value| {
            self.allocator.free(value);
        }

        self.lines.deinit();
    }
};

pub fn readFileByLine(allocator: Allocator, path: []const u8) !Lines {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var lines = std.ArrayList([]const u8).init(allocator);

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const line_data = try allocator.dupe(u8, line);
        try lines.append(line_data);
    }

    return Lines{
        .allocator = allocator,
        .lines = lines,
    };
}

pub fn parseInt(comptime T: type, buf: []const u8) !T {
    return std.fmt.parseInt(T, buf, 10);
}

pub const AccumulatorCallback = struct {
    ptr: *anyopaque,
    callbackFn: *const fn (ptr: *anyopaque, line: []const u8) anyerror!void,

    fn callback(self: AccumulatorCallback, line: []const u8) !void {
        return self.callbackFn(self.ptr, line);
    }
};

pub const FileLineReaderAccumulator = struct {
    file: std.fs.File,

    const Self = @This();

    pub fn init(path: []const u8) !Self {
        const file = try std.fs.cwd().openFile(path, .{});
        return Self{
            .file = file,
        };
    }

    pub fn readFile(self: *Self, cb: AccumulatorCallback) !void {
        var buf_reader = std.io.bufferedReader(self.file.reader());
        var in_stream = buf_reader.reader();

        var buf: [4192]u8 = undefined;
        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            try cb.callback(line);
        }
    }
};

pub fn digit(num: u32, exp: u32) u32 {
    return (num / exp) % 10;
}

pub fn countingSortDigit(nums: []u32, exp: u32) void {
    var counter: [10]usize = undefined;
    @memset(counter[0..], 0);
    const n = nums.len;

    for (0..n) |i| {
        const d = digit(nums[i], exp);
        counter[d] += 1;
    }

    for (1..10) |i| {
        counter[i] += counter[i - 1];
    }

    var output: [1000]u32 = undefined;
    for (0..n) |reverse_i| {
        const i = n - 1 - reverse_i;

        const d = digit(nums[i], exp);
        const j = counter[d] - 1;
        output[j] = nums[i];
        counter[d] -= 1;
    }

    for (0..n) |i| {
        nums[i] = output[i];
    }
}

pub fn radixSort(nums: []u32) void {
    var exp: usize = 1;
    while (exp <= std.mem.max(u32, nums)) {
        countingSortDigit(nums, @intCast(exp));
        exp *= 10;
    }
}

test "Radix Sort" {
    var nums: [5]u32 = .{ 55555, 62573, 18273, 59738, 59737 };
    radixSort(&nums);
    std.debug.print("{any}\n", .{nums});
}
