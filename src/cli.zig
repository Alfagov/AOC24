const std = @import("std");
const time = std.time;
const print = std.debug.print;
const Day1 = @import("day1.zig");
const Day2 = @import("day2.zig");
const Day3 = @import("day3.zig");
const Day4 = @import("day4.zig");

// ANSI escape codes for colors and formatting
const Style = struct {
    const reset = "\x1b[0m";
    const bold = "\x1b[1m";
    const dim = "\x1b[2m";
    const italic = "\x1b[3m";
    const underline = "\x1b[4m";

    const red = "\x1b[31m";
    const green = "\x1b[32m";
    const yellow = "\x1b[33m";
    const blue = "\x1b[34m";
    const magenta = "\x1b[35m";
    const cyan = "\x1b[36m";

    const bg_red = "\x1b[41m";
    const bg_green = "\x1b[42m";
    const bg_yellow = "\x1b[43m";
    const bg_blue = "\x1b[44m";
};

fn formatDuration(ns: u64) []const u8 {
    if (ns < 1000) {
        return std.fmt.allocPrint(std.heap.page_allocator, "{d}ns", .{ns}) catch "??ns";
    } else if (ns < 1000_000) {
        return std.fmt.allocPrint(std.heap.page_allocator, "{d:.2}µs", .{@as(f64, @floatFromInt(ns)) / 1000.0}) catch "??µs";
    } else if (ns < 1000_000_000) {
        return std.fmt.allocPrint(std.heap.page_allocator, "{d:.2}ms", .{@as(f64, @floatFromInt(ns)) / 1000_000.0}) catch "??ms";
    } else {
        return std.fmt.allocPrint(std.heap.page_allocator, "{d:.2}s", .{@as(f64, @floatFromInt(ns)) / 1000_000_000.0}) catch "??s";
    }
}

fn printStrPadding(txt: []const u8, n: usize) void {
    var pad = std.heap.page_allocator.alloc(u8, n * txt.len) catch @panic("OOM");
    defer std.heap.page_allocator.free(pad);
    var stream = std.io.fixedBufferStream(pad[0..]);
    var writer = stream.writer();
    for (0..n) |_| {
        writer.writeAll(txt) catch @panic("No space left");
    }

    print("{s}", .{pad});
}

fn printHeader(text: []const u8) void {
    const total_width = 60;
    const text_width = text.len;
    const padding = @ceil(@as(f64, @floatFromInt(total_width - text_width - 2)) / 2);

    print("\n{s}╔", .{Style.cyan});
    printStrPadding("═", total_width);
    print("╗{s}\n", .{Style.reset});
    print("{s}║", .{Style.cyan});
    printStrPadding(" ", @intFromFloat(padding));
    print("{s}{s}{s}", .{
        Style.yellow ++ Style.bold,
        text,
        Style.cyan,
    });
    printStrPadding(" ", @intFromFloat(padding + 1));
    print("║{s}\n", .{Style.reset});
    print("{s}╚", .{Style.cyan});
    printStrPadding("═", total_width);
    print("╝{s}\n\n", .{Style.reset});
}

fn printResult(day: []const u8, part: []const u8, duration: ?u64, result: ?i64) void {
    const result_marker = "▶";
    print("{s}{s} Day {s}, Part {s}{s}\n", .{
        Style.blue ++ Style.bold,
        result_marker,
        day,
        part,
        Style.reset,
    });

    if (result) |res| {
        print("{s}  └─ Result: {s}{d}{s}\n", .{
            Style.dim,
            Style.green,
            res,
            Style.reset,
        });
    }

    if (duration) |d| {
        const duration_str = formatDuration(d);
        defer std.heap.page_allocator.free(duration_str);
        print("{s}  └─ Time: {s}{s}{s}\n", .{
            Style.dim,
            Style.green,
            duration_str,
            Style.reset,
        });
    }
}

fn printUsage(prog_name: []const u8) void {
    printHeader("Advent of Code Runner");

    print("{s}Usage:{s}\n", .{ Style.bold, Style.reset });
    print("  {s} {s}<command>{s} [options]\n\n", .{ prog_name, Style.green, Style.reset });

    print("{s}Commands:{s}\n", .{ Style.bold, Style.reset });
    print("  {s}day{s} <number> [part]    Run specific day's solution\n", .{ Style.green, Style.reset });
    print("  {s}all{s}                    Run all solutions\n", .{ Style.green, Style.reset });
    print("  {s}bench{s} <number> [part]  Benchmark specific day\n", .{ Style.green, Style.reset });
    print("  {s}benchall{s}               Benchmark all solutions\n", .{ Style.green, Style.reset });

    print("\n{s}Examples:{s}\n", .{ Style.bold, Style.reset });
    print("  {s}day 1{s}        Run both parts of day 1\n", .{ Style.dim, Style.reset });
    print("  {s}day 1 2{s}      Run part 2 of day 1\n", .{ Style.dim, Style.reset });
    print("  {s}bench 1{s}      Benchmark both parts of day 1\n", .{ Style.dim, Style.reset });
}

fn printError(msg: []const u8) void {
    print("\n{s}ERROR:{s} {s}\n", .{ Style.red ++ Style.bold, Style.reset, msg });
}

const SolutionFn = *const fn () anyerror!i64;

pub const DaySolution = struct {
    part1: SolutionFn,
    part2: SolutionFn,
};

pub fn timeFn(fun: *const fn() anyerror!i64) !struct { time: u64, result: i64} {
    const start_time = time.nanoTimestamp();
    const result = try fun();
    const end_time = time.nanoTimestamp();

    return .{
        .time = @intCast(end_time - start_time),
        .result = result,
    };
}

pub fn run(args: [][]u8, solutions: std.StaticStringMap(DaySolution)) !void {
    if (args.len < 2) {
        printUsage(args[0]);
        return;
    }

    const command = args[1];
    if (std.ascii.eqlIgnoreCase(command, "help") or std.ascii.eqlIgnoreCase(command, "h")) {
        printUsage(args[0]);
        return;
    }

    var header: [128]u8 = undefined;
    if (std.ascii.eqlIgnoreCase(command, "day")) {
        if (args.len < 3) {
            printError("Specify a day number");
            return;
        }
        const day = args[2];

        if (solutions.get(day)) |solution| {
            if (args.len >= 4) {
                const part = args[3];
                if (std.mem.eql(u8, part, "1")) {
                    printHeader(try std.fmt.bufPrint(&header, "Running Day {s}, Part 1", .{day}));

                    const timed_res = try timeFn(solution.part1);

                    printResult(day, "1", timed_res.time, timed_res.result);
                } else if (std.mem.eql(u8, part, "2")) {
                    printHeader(try std.fmt.bufPrint(&header, "Running Day {s}, Part 2", .{day}));

                    const timed_res = try timeFn(solution.part2);

                    printResult(day, "2", timed_res.time, timed_res.result);
                } else {
                    printError("Invalid part number. Use 1 or 2");
                }
            } else {
                printHeader(try std.fmt.bufPrint(&header, "Running Day {s}", .{day}));

                var timed_res = try timeFn(solution.part1);
                printResult(day, "1", timed_res.time, timed_res.result);
                print("\n", .{});

                timed_res = try timeFn(solution.part2);
                printResult(day, "2", timed_res.time, timed_res.result);
            }
        } else {
            printError(try std.fmt.bufPrint(&header, "Day {s} not implemented", .{day}));
        }
    } else if (std.ascii.eqlIgnoreCase(command, "all")) {
        const solution_list = solutions.values();
        const solution_days = solutions.keys();
        for (solution_list, solution_days) |entry, day| {
            printHeader(try std.fmt.bufPrint(&header, "Running Day {s}", .{day}));
            var timed_res = try timeFn(entry.part1);
            printResult(day, "1", timed_res.time, timed_res.result);
            timed_res = try timeFn(entry.part2);
            printResult(day, "2", timed_res.time, timed_res.result);
        }
    } else {
        printError("Invalid command");
    }
}
