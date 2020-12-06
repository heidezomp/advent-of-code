const std = @import("std");

pub fn findAnswer1(input: []const u8) !u32 {
    var sum_of_answers: u32 = 0;

    var group_answers: u26 = 0;
    var lines = std.mem.split(input, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) {
            sum_of_answers += @popCount(u26, group_answers);
            group_answers = 0;
            continue;
        }

        for (line) |char| {
            group_answers |= @shlExact(@as(u26, 1), @intCast(u5, char - 'a'));
        }
    }
    sum_of_answers += @popCount(u26, group_answers);

    return sum_of_answers;
}

pub fn findAnswer2(input: []const u8) !u32 {
    var sum_of_answers: u32 = 0;

    var group_answers: u27 = std.math.maxInt(u27);
    var lines = std.mem.split(input, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) {
            sum_of_answers += @popCount(u27, group_answers);
            group_answers = std.math.maxInt(u27);
            continue;
        }

        var person_answers: u27 = 0;
        for (line) |char| {
            person_answers |= @shlExact(@as(u27, 1), @intCast(u5, char - 'a'));
        }
        group_answers &= person_answers;
    }
    if (group_answers != std.math.maxInt(u27)) {
        sum_of_answers += @popCount(u27, group_answers);
    }

    return sum_of_answers;
}

const test_input =
    \\abc
    \\
    \\a
    \\b
    \\c
    \\
    \\ab
    \\ac
    \\
    \\a
    \\a
    \\a
    \\a
    \\
    \\b
;

test "findAnswer1" {
    std.testing.expectEqual(@as(u32, 11), try findAnswer1(test_input));
    std.testing.expectEqual(@as(u32, 6551), try findAnswer1(@embedFile("input.txt")));
}

test "findAnswer2" {
    std.testing.expectEqual(@as(u32, 6), try findAnswer2(test_input));
    std.testing.expectEqual(@as(u32, 3358), try findAnswer2(@embedFile("input.txt")));
}
