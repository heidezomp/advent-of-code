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

const Passport = struct {
    byr: bool = false,
    iyr: bool = false,
    eyr: bool = false,
    hgt: bool = false,
    hcl: bool = false,
    ecl: bool = false,
    pid: bool = false,
    cid: bool = false,

    fn isValid(self: Passport) bool {
        return self.byr and self.iyr and self.eyr and self.hgt and
            self.hcl and self.ecl and self.pid;
    }
};

fn findAnswer1(input: []const u8) !u32 {
    var valid_passports: u32 = 0;
    var passport: Passport = .{};

    var lines = std.mem.split(input, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) {
            if (passport.isValid())
                valid_passports += 1;
            passport = .{};
            continue;
        }

        var fields = std.mem.tokenize(line, " ");
        while (fields.next()) |field| {
            if (std.mem.startsWith(u8, field, "byr:"))
                passport.byr = true
            else if (std.mem.startsWith(u8, field, "iyr:"))
                passport.iyr = true
            else if (std.mem.startsWith(u8, field, "eyr:"))
                passport.eyr = true
            else if (std.mem.startsWith(u8, field, "hgt:"))
                passport.hgt = true
            else if (std.mem.startsWith(u8, field, "hcl:"))
                passport.hcl = true
            else if (std.mem.startsWith(u8, field, "ecl:"))
                passport.ecl = true
            else if (std.mem.startsWith(u8, field, "pid:"))
                passport.pid = true
            else if (std.mem.startsWith(u8, field, "cid:"))
                passport.cid = true
            else
                return error.ParseError;
        }
    }
    if (passport.isValid())
        valid_passports += 1;

    return valid_passports;
}

const test_input =
    \\ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
    \\byr:1937 iyr:2017 cid:147 hgt:183cm
    \\
    \\iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
    \\hcl:#cfa07d byr:1929
    \\
    \\hcl:#ae17e1 iyr:2013
    \\eyr:2024
    \\ecl:brn pid:760753108 byr:1931
    \\hgt:179cm
    \\
    \\hcl:#cfa07d eyr:2025 pid:166559648
    \\iyr:2011 ecl:brn hgt:59in
;

test "findAnswer1" {
    std.testing.expectEqual(@as(u32, 2), try findAnswer1(test_input));
    std.testing.expectEqual(@as(u32, 222), try findAnswer1(@embedFile("input.txt")));
}
