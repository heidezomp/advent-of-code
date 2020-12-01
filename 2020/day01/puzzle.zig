const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    const sum = 2020;

    const stdout = std.io.getStdOut().writer();

    const answer1 = try findAnswer1(input, sum);
    try stdout.print("Answer 1: {}\n", .{answer1});

    const answer2 = try findAnswer2(input, sum);
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
