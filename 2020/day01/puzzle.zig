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

    const sum_to_find = 2020;

    const answer1 = try findAnswer1(input, sum_to_find);
    try stdout.print("Answer 1: {}\n", .{answer1});

    const answer2 = try findAnswer2(input, sum_to_find);
    try stdout.print("Answer 2: {}\n", .{answer2});
}

fn findAnswer1(input: []const u8, sum: u32) !u32 {
    var lines = std.mem.tokenize(input, "\n");
    while (lines.next()) |line1| {
        const number1 = try std.fmt.parseUnsigned(u32, line1, 10);

        var remaining_lines = std.mem.tokenize(lines.rest(), "\n");
        while (remaining_lines.next()) |line2| {
            const number2 = try std.fmt.parseUnsigned(u32, line2, 10);
            if (number1 + number2 == sum)
                return number1 * number2;
        }
    }
    return error.AnswerNotFound;
}

fn findAnswer2(input: []const u8, sum: u32) !u32 {
    var lines = std.mem.tokenize(input, "\n");
    while (lines.next()) |line1| {
        const number1 = try std.fmt.parseUnsigned(u32, line1, 10);

        var remaining_lines = std.mem.tokenize(lines.rest(), "\n");
        while (remaining_lines.next()) |line2| {
            const number2 = try std.fmt.parseUnsigned(u32, line2, 10);

            var further_remaining_lines = std.mem.tokenize(remaining_lines.rest(), "\n");
            while (further_remaining_lines.next()) |line3| {
                const number3 = try std.fmt.parseUnsigned(u32, line3, 10);
                if (number1 + number2 + number3 == sum)
                    return number1 * number2 * number3;
            }
        }
    }
    return error.AnswerNotFound;
}

test "findAnswer1" {
    const answer1 = try findAnswer1(@embedFile("input.txt"), 2020);
    std.testing.expectEqual(answer1, 1007331);
}

test "findAnswer2" {
    const answer2 = try findAnswer2(@embedFile("input.txt"), 2020);
    std.testing.expectEqual(answer2, 48914340);
}
