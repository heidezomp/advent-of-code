const std = @import("std");

pub fn findAnswer1(input: []const u8) !u32 {
    return traverseMap(input, 3, 1);
}

pub fn findAnswer2(input: []const u8) !u32 {
    return (try traverseMap(input, 1, 1)) *
        (try traverseMap(input, 3, 1)) *
        (try traverseMap(input, 5, 1)) *
        (try traverseMap(input, 7, 1)) *
        (try traverseMap(input, 1, 2));
}

fn traverseMap(input: []const u8, dx: u32, dy: u32) !u32 {
    std.debug.assert(dy > 0);

    var trees_encountered: u32 = 0;
    var lines = std.mem.tokenize(input, "\n");
    var x: u32 = 0;
    while (lines.next()) |line| {
        if (x >= line.len) return error.ParseError;
        if (line[x] == '#') trees_encountered += 1;
        x = (x + dx) % @intCast(u32, line.len);

        // Skip line(s) if dy > 1
        var skipped_y: u32 = 0;
        while (skipped_y < dy - 1) : (skipped_y += 1)
            _ = lines.next();
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

test "findAnswer2" {
    std.testing.expectEqual(@as(u32, 336), try findAnswer2(test_input));
    std.testing.expectEqual(@as(u32, 1206576000), try findAnswer2(@embedFile("input.txt")));
}
