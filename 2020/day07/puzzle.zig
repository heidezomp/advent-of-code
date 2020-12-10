const std = @import("std");

const BagName = struct {
    adjective: []const u8,
    color: []const u8,

    fn parse(it: *std.mem.TokenIterator) !BagName {
        const adjective = it.next() orelse return error.ParseError;
        const color = it.next() orelse return error.ParseError;
        return BagName{
            .adjective = adjective,
            .color = color,
        };
    }
};

pub fn findAnswer1(input: []const u8) !u32 {
    var lines = std.mem.tokenize(input, "\n");
    while (lines.next()) |line| {
        std.log.debug("[{}]:", .{line});

        var words = std.mem.tokenize(line, " ");
        const bag_name = BagName.parse(&words);
        std.log.debug("outer: {}", .{bag_name});
        _ = words.next(); // "bags"
        _ = words.next(); // "contain"
        while (words.next()) |amount_str| {
            const inner_bag_name = BagName.parse(&words);
            std.log.debug("inner: {}", .{inner_bag_name});
            _ = words.next(); // "bags"
        }
    }
    return error.Unimplemented;
}

pub fn findAnswer2(input: []const u8) !u32 {
    return error.Unimplemented;
}