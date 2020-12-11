const std = @import("std");
const Allocator = std.mem.Allocator;

fn parseBagName(it: *std.mem.TokenIterator) ![]const u8 {
    const adjective = it.next() orelse return error.ParseError;
    const color = it.next() orelse return error.ParseError;
    var bag_name = adjective;
    bag_name.len += 1 + color.len;
    return bag_name;
}

fn constructIsContainedWithin(arena: *Allocator, input: []const u8) !std.StringHashMap(std.StringHashMap(void)) {
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
            if (std.mem.eql(u8, amount_str, "no")) // "no other bags"
                break;

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

    return is_contained_within;
}

pub fn findAnswer1(arena: *Allocator, input: []const u8) !u32 {
    const is_contained_within = try constructIsContainedWithin(arena, input);

    // Construct set of all bags that can (in)directly contain a shiny gold bag
    var query_set = std.StringHashMap(void).init(arena);
    try query_set.putNoClobber("shiny gold", {});
    var answer_set = std.StringHashMap(void).init(arena);

    // Restart the iterator each time to prevent iterator invalidation, since
    // we are going to modify the query set inside the loop
    while (query_set.iterator().next()) |entry| {
        const query_bag = entry.key;
        std.log.debug("processing query bag {}", .{query_bag});
        query_set.removeAssertDiscard(query_bag);
        if (is_contained_within.get(query_bag)) |containing_set| {
            // Add the containing set's members to both the query set and the answer set
            var containing_iter = containing_set.iterator();
            while (containing_iter.next()) |containing_entry| {
                std.log.debug("adding containing bag {}", .{containing_entry.key});
                try query_set.put(containing_entry.key, {});
                try answer_set.put(containing_entry.key, {});
            }
        }
    }
    return answer_set.count();
}

pub fn findAnswer2(input: []const u8) !u32 {
    return error.Unimplemented;
}

test "findAnswer1" {
    var arena_instance = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_instance.deinit();
    const arena = &arena_instance.allocator;
    std.testing.expectEqual(@as(u32, 179), try findAnswer1(arena, @embedFile("input.txt")));
}
