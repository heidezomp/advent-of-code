const std = @import("std");

const target_sum = 2020;

pub fn findAnswer1(input: []const u8) !u32 {
    var lines = std.mem.tokenize(input, "\n");
    while (lines.next()) |line1| {
        const number1 = try std.fmt.parseUnsigned(u32, line1, 10);

        var remaining_lines = std.mem.tokenize(lines.rest(), "\n");
        while (remaining_lines.next()) |line2| {
            const number2 = try std.fmt.parseUnsigned(u32, line2, 10);
            if (number1 + number2 == target_sum)
                return number1 * number2;
        }
    }
    return error.AnswerNotFound;
}

pub fn findAnswer2(input: []const u8) !u32 {
    var lines = std.mem.tokenize(input, "\n");
    while (lines.next()) |line1| {
        const number1 = try std.fmt.parseUnsigned(u32, line1, 10);

        var remaining_lines = std.mem.tokenize(lines.rest(), "\n");
        while (remaining_lines.next()) |line2| {
            const number2 = try std.fmt.parseUnsigned(u32, line2, 10);

            var further_remaining_lines = std.mem.tokenize(remaining_lines.rest(), "\n");
            while (further_remaining_lines.next()) |line3| {
                const number3 = try std.fmt.parseUnsigned(u32, line3, 10);
                if (number1 + number2 + number3 == target_sum)
                    return number1 * number2 * number3;
            }
        }
    }
    return error.AnswerNotFound;
}

const test_input =
    \\1721
    \\979
    \\366
    \\299
    \\675
    \\1456
;

test "findAnswer1" {
    std.testing.expectEqual(@as(u32, 514579), try findAnswer1(test_input));
    std.testing.expectEqual(@as(u32, 1007331), try findAnswer1(@embedFile("input.txt")));
}

test "findAnswer2" {
    std.testing.expectEqual(@as(u32, 241861950), try findAnswer2(test_input));
    std.testing.expectEqual(@as(u32, 48914340), try findAnswer2(@embedFile("input.txt")));
}
