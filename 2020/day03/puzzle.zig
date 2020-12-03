const std = @import("std");
const Allocator = std.mem.Allocator;

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() anyerror!void {
    const gpa = if (std.builtin.link_libc) std.heap.raw_c_allocator else &general_purpose_allocator.allocator;
    defer if (!std.builtin.link_libc) {
        _ = general_purpose_allocator.deinit();
    };
    var arena_instance = std.heap.ArenaAllocator.init(gpa);
    defer arena_instance.deinit();
    const arena = &arena_instance.allocator;

    const args = try std.process.argsAlloc(arena);
    return mainArgs(gpa, arena, args);
}

fn mainArgs(gpa: *Allocator, arena: *Allocator, args: []const []const u8) !void {
    if (args.len != 2) {
        std.log.err("Incorrect number of arguments", .{});
        std.log.info("Usage: {} <input_file>", .{args[0]});
        std.process.exit(1);
    }

    const input = try std.fs.cwd().readFileAlloc(arena, args[1], 1024 * 1024);
    const stdout = std.io.getStdOut().writer();

    const answer1 = try findAnswer1(input);
    try stdout.print("Answer 1: {}\n", .{answer1});

    //const answer2 = try findAnswer2(input);
    //try stdout.print("Answer 2: {}\n", .{answer2});
}

fn findAnswer1(input: []const u8) !u32 {
    var trees_encountered: u32 = 0;

    var lines = std.mem.tokenize(input, "\n");
    var x: u32 = 0;
    while (lines.next()) |line| {
        if (x >= line.len) return error.ParseError;
        if (line[x] == '#') trees_encountered += 1;
        x = (x + 3) % @intCast(u32, line.len);
    }

    return trees_encountered;
}

const test_input =
    \\..##.......
    \\#...#...#..
    \\.#....#..#.
    \\..#.#...#.#
    \\.#...##..#.
    \\..#.##.....
    \\.#.#.#....#
    \\.#........#
    \\#.##...#...
    \\#...##....#
    \\.#..#...#.#
;

test "findAnswer1" {
    std.testing.expectEqual(@as(u32, 7), try findAnswer1(test_input));
    std.testing.expectEqual(@as(u32, 171), try findAnswer1(@embedFile("input.txt")));
}
