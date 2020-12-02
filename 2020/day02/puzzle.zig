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
    var valid_passwords: u32 = 0;

    var lines = std.mem.tokenize(input, "\n");
    while (lines.next()) |line| {
        var fields = std.mem.tokenize(line, " -:");

        const min_field = fields.next() orelse return error.ParseError;
        const max_field = fields.next() orelse return error.ParseError;
        const char_field = fields.next() orelse return error.ParseError;
        const password_field = fields.next() orelse return error.ParseError;

        const min = try std.fmt.parseUnsigned(u32, min_field, 10);
        const max = try std.fmt.parseUnsigned(u32, max_field, 10);
        if (min > max) return error.ParseError;
        if (char_field.len != 1) return error.ParseError;
        const char = char_field[0];

        var found_chars: u32 = 0;
        for (password_field) |password_char| {
            if (password_char == char)
                found_chars += 1;
        }
        if (found_chars >= min and found_chars <= max)
            valid_passwords += 1;
    }

    return valid_passwords;
}

const test_input =
    \\1-3 a: abcde
    \\1-3 b: cdefg
    \\2-9 c: ccccccccc
;

test "findAnswer1" {
    std.testing.expectEqual(@as(u32, 2), try findAnswer1(test_input));
    std.testing.expectEqual(@as(u32, 506), try findAnswer1(@embedFile("input.txt")));
}
