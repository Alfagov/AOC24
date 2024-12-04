const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn benchmark(iterations: usize, f: *const fn() anyerror!void) !void {
    const start_time = std.time.microTimestamp();
    for (0..iterations) |_| {
        try f();
    }
    const end_time = std.time.microTimestamp();

    const elapsed_time_ms = @as(f64, @floatFromInt(end_time - start_time)) / 1000.0;
    const average_time_per_iteration = elapsed_time_ms / @as(f64, @floatFromInt(iterations));
    const iterations_per_second = 1000.0 / average_time_per_iteration;

    std.debug.print("\n", .{});
    std.debug.print("=====================================\n", .{});
    std.debug.print("         Benchmark Report            \n", .{});
    std.debug.print("=====================================\n", .{});
    std.debug.print("Iterations: {}\n", .{iterations});
    std.debug.print("Total Time: {d:.3} ms\n", .{elapsed_time_ms});
    std.debug.print("Avg Time/It: {d:.6} ms\n", .{average_time_per_iteration});
    std.debug.print("Iterations/s: {d:.2} it/s\n", .{iterations_per_second});
    std.debug.print("=====================================\n", .{});

}