const std = @import("std");

pub fn findAnswer1(input: []const u8) !u32 {
    return validatePasswords(input, .lax);
}

pub fn findAnswer2(input: []const u8) !u32 {
    return validatePasswords(input, .strict);
}

fn validatePasswords(input: []const u8, method: enum { lax, strict }) !u32 {
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
            switch (method) {
                .lax => try passport.parseFieldLax(field),
                .strict => try passport.parseFieldStrict(field),
            }
        }
    }
    if (passport.isValid())
        valid_passports += 1;

    return valid_passports;
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

    fn parseFieldLax(self: *Passport, field: []const u8) !void {
        if (std.mem.startsWith(u8, field, "byr:"))
            self.byr = true
        else if (std.mem.startsWith(u8, field, "iyr:"))
            self.iyr = true
        else if (std.mem.startsWith(u8, field, "eyr:"))
            self.eyr = true
        else if (std.mem.startsWith(u8, field, "hgt:"))
            self.hgt = true
        else if (std.mem.startsWith(u8, field, "hcl:"))
            self.hcl = true
        else if (std.mem.startsWith(u8, field, "ecl:"))
            self.ecl = true
        else if (std.mem.startsWith(u8, field, "pid:"))
            self.pid = true
        else if (std.mem.startsWith(u8, field, "cid:"))
            self.cid = true
        else
            return error.ParseError;
    }

    fn parseFieldStrict(self: *Passport, field: []const u8) !void {
        if (std.mem.startsWith(u8, field, "byr:")) {
            const byr = try std.fmt.parseUnsigned(u32, field[4..], 10);
            if (byr >= 1920 and byr <= 2002)
                self.byr = true;
        } else if (std.mem.startsWith(u8, field, "iyr:")) {
            const iyr = try std.fmt.parseUnsigned(u32, field[4..], 10);
            if (iyr >= 2010 and iyr <= 2020)
                self.iyr = true;
        } else if (std.mem.startsWith(u8, field, "eyr:")) {
            const eyr = try std.fmt.parseUnsigned(u32, field[4..], 10);
            if (eyr >= 2020 and eyr <= 2030)
                self.eyr = true;
        } else if (std.mem.startsWith(u8, field, "hgt:")) {
            const hgt = std.fmt.parseUnsigned(u32, field[4 .. field.len - 2], 10) catch return;
            if (std.mem.endsWith(u8, field, "cm") and hgt >= 150 and hgt <= 193)
                self.hgt = true
            else if (std.mem.endsWith(u8, field, "in") and hgt >= 59 and hgt <= 76)
                self.hgt = true;
        } else if (std.mem.startsWith(u8, field, "hcl:")) {
            if (field[4] == '#') {
                _ = std.fmt.parseUnsigned(u24, field[5..], 16) catch return;
                self.hcl = true;
            }
        } else if (std.mem.startsWith(u8, field, "ecl:")) {
            if (std.mem.eql(u8, field[4..], "amb") or
                std.mem.eql(u8, field[4..], "blu") or
                std.mem.eql(u8, field[4..], "brn") or
                std.mem.eql(u8, field[4..], "gry") or
                std.mem.eql(u8, field[4..], "grn") or
                std.mem.eql(u8, field[4..], "hzl") or
                std.mem.eql(u8, field[4..], "oth"))
                self.ecl = true;
        } else if (std.mem.startsWith(u8, field, "pid:")) {
            if (field[4..].len == 9) {
                _ = std.fmt.parseUnsigned(u32, field[4..], 10) catch return;
                self.pid = true;
            }
        } else if (std.mem.startsWith(u8, field, "cid:")) {
            self.cid = true;
        } else
            return error.ParseError;
    }

    fn isValid(self: Passport) bool {
        return self.byr and self.iyr and self.eyr and self.hgt and
            self.hcl and self.ecl and self.pid;
    }
};

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

const strict_invalid_input =
    \\eyr:1972 cid:100
    \\hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926
    \\
    \\iyr:2019
    \\hcl:#602927 eyr:1967 hgt:170cm
    \\ecl:grn pid:012533040 byr:1946
    \\
    \\hcl:dab227 iyr:2012
    \\ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277
    \\
    \\hgt:59cm ecl:zzz
    \\eyr:2038 hcl:74454a iyr:2023
    \\pid:3556412378 byr:2007
;

const strict_valid_input =
    \\pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
    \\hcl:#623a2f
    \\
    \\eyr:2029 ecl:blu cid:129 byr:1989
    \\iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm
    \\
    \\hcl:#888785
    \\hgt:164cm byr:2001 iyr:2015 cid:88
    \\pid:545766238 ecl:hzl
    \\eyr:2022
    \\
    \\iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
;

test "findAnswer2" {
    std.testing.expectEqual(@as(u32, 0), try findAnswer2(strict_invalid_input));
    std.testing.expectEqual(@as(u32, 4), try findAnswer2(strict_valid_input));
    std.testing.expectEqual(@as(u32, 140), try findAnswer2(@embedFile("input.txt")));
}
