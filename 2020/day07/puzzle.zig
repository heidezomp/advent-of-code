const std = @import("std");
const Allocator = std.mem.Allocator;

fn parseBagName(it: *std.mem.TokenIterator) ![]const u8 {
    const adjective = it.next() orelse return error.ParseError;
    const color = it.next() orelse return error.ParseError;
    var bag_name = adjective;
    bag_name.len += 1 + color.len;
    return bag_name;
}

pub fn findAnswer1(arena: *Allocator, input: []const u8) !u32 {
    // Hash map from bag name to set of bag names that directly contain it
    var is_contained_within = std.StringHashMap(std.StringHashMap(void)).init(arena);

    // Fill the hash map by parsing the input
    var lines = std.mem.tokenize(input, "\n");
    while (lines.next()) |line| {
        std.log.debug("[{}]:", .{line});

        var words = std.mem.tokenize(line, " ");
        const bag_name = try parseBagName(&words);
        std.log.debug("outer: {}", .{bag_name});
        _ = words.next(); // "bags"
        _ = words.next(); // "contain"
        while (words.next()) |amount_str| {
            const inner_bag_name = try parseBagName(&words);
            std.log.debug("inner: {}", .{inner_bag_name});
            _ = words.next(); // "bags"

            // Insert in hash map
            var result = try is_contained_within.getOrPut(inner_bag_name);
            if (!result.found_existing) {
                result.entry.value = std.StringHashMap(void).init(arena);
            }
            try result.entry.value.putNoClobber(bag_name, {});
        }
    }
    return error.Unimplemented;
}

pub fn findAnswer2(input: []const u8) !u32 {
    return error.Unimplemented;
}
