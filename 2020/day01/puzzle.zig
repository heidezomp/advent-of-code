const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");

    const answer1 = try findAnswer1(input, 2020);
    try std.io.getStdOut().writer().print("Answer 1: {}\n", .{answer1});
}

fn findAnswer1(input: []const u8, sum: u32) !u32 {
    var lines = std.mem.tokenize(input, "\n");
    while (lines.next()) |line1| {
        const number1 = try std.fmt.parseUnsigned(u32, line1, 10);

        var remaining_lines = std.mem.tokenize(lines.rest(), "\n");
        while (remaining_lines.next()) |line2| {
            const number2 = try std.fmt.parseUnsigned(u32, line2, 10);
            if (number1 + number2 == sum) {
                return number1 * number2;
            }
        }
    }
    return error.AnswerNotFound;
}
