const std = @import("std");
const Utils = @import("utils.zig");

const dir_diag_lr = [_][2]i8{
    [_]i8{1, 1},
    [_]i8{-1, -1},
};

const dir_diag_rl = [_][2]i8{
    [_]i8{1, -1},
    [_]i8{-1, 1},
};

const directions = [_][2]i8{
    [_]i8{0, 1},
    [_]i8{1, 0},
    [_]i8{1, 1},
    [_]i8{1, -1},
    [_]i8{0, -1},
    [_]i8{-1, 0},
    [_]i8{-1, 1},
    [_]i8{-1, -1},
};

fn isValid(row: i32, col: i32, maxRow: usize, maxCol: usize) bool {
    return row >= 0 and row < maxRow and col >= 0 and col < maxCol;
}

fn checkPattern(grid: [][]const u8, row: i32, col: i32, dir: [2]i8, pattern: []const u8) bool {
    var currentRow = row;
    var currentCol = col;

    for (pattern) |char| {

        if (!isValid(currentRow, currentCol, grid.len, grid[0].len)) return false;
        if (grid[@intCast(currentRow)][@intCast(currentCol)] != char) return false;
        currentRow += dir[0];
        currentCol += dir[1];
    }

    return true;
}

pub fn part2() !i64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var line = try Utils.readFileByLine(gpa.allocator(), "data/input4.txt");
    defer line.deinit();

    const rows = line.lines.items.len;
    const columns = line.lines.items[0].len;

    var acc: usize = 0;
    for (1..rows - 1) |r| {
        for (1..columns - 1) |c| {
            var left: bool = false;
            var right: bool = false;

            const row: i32 = @intCast(r);
            const col: i32 = @intCast(c);

            for (dir_diag_lr) |direction| {
                if (checkPattern(line.lines.items, @intCast(row-direction[0]), @intCast(col-direction[1]), direction, "MAS")) {
                    left = true;
                    break;
                }
            }

            for (dir_diag_rl) |direction| {
                if (checkPattern(line.lines.items, @intCast(row-direction[0]), @intCast(col-direction[1]), direction, "MAS")) {
                    right = true;
                    break;
                }
            }

            if (left and right) {
                acc += 1;
            }
        }
    }

    return @intCast(acc);
}

pub fn part1() !i64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var line = try Utils.readFileByLine(gpa.allocator(), "data/input4.txt");
    defer line.deinit();

    const rows = line.lines.items.len;
    const columns = line.lines.items[0].len;

    var acc: usize = 0;
    for (0..rows) |r| {
        for (0..columns) |c| {
            for (directions) |dir| {
                if (checkPattern(line.lines.items, @intCast(r), @intCast(c), dir, "XMAS")) {
                    acc += 1;
                }
            }
        }
    }

    return @intCast(acc);
}