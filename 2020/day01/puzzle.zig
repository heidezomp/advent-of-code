const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");

    var lines = std.mem.tokenize(input, "\n");
    const answer = outer: while (lines.next()) |line1| {
        const number1 = try std.fmt.parseUnsigned(u32, line1, 10);

        var remaining_lines = std.mem.tokenize(lines.rest(), "\n");
        while (remaining_lines.next()) |line2| {
            const number2 = try std.fmt.parseUnsigned(u32, line2, 10);
            if (number1 + number2 == 2020) {
                break :outer number1 * number2;
            }
        }
    } else return error.AnswerNotFound;

    try std.io.getStdOut().writer().print("Answer: {}\n", .{answer});
}
