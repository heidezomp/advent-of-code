const std = @import("std");
const Allocator = std.mem.Allocator;

const Operation = enum { acc, jmp, nop };

const Instruction = struct {
    op: Operation,
    arg: i32,
    executed: bool = false,
};

pub fn findAnswer1(arena: *Allocator, input: []const u8) !i32 {
    // Parse instructions
    var instr_list = std.ArrayList(Instruction).init(arena);
    var lines = std.mem.tokenize(input, "\n");
    while (lines.next()) |line| {
        const op = if (std.mem.eql(u8, line[0..3], "acc"))
            Operation.acc
        else if (std.mem.eql(u8, line[0..3], "jmp"))
            Operation.jmp
        else if (std.mem.eql(u8, line[0..3], "nop"))
            Operation.nop
        else
            return error.ParseError;

        const arg = try std.fmt.parseInt(i32, line[4..], 10);
        try instr_list.append(.{ .op = op, .arg = arg });
    }

    // Execute instructions
    const instr = instr_list.items;
    var pc: u32 = 0;
    var acc: i32 = 0;
    while (!instr[pc].executed) {
        instr[pc].executed = true;
        switch (instr[pc].op) {
            .acc => {
                acc += instr[pc].arg;
                pc += 1;
            },
            .jmp => {
                pc = @intCast(u32, @intCast(i32, pc) + instr[pc].arg);
            },
            .nop => {
                pc += 1;
            },
        }
    }

    return acc;
}

pub fn findAnswer2(input: []const u8) !i32 {
    return error.Unimplemented;
}

const test_input =
    \\nop +0
    \\acc +1
    \\jmp +4
    \\acc +3
    \\jmp -3
    \\acc -99
    \\acc +1
    \\jmp -4
    \\acc +6
;

test "findAnswer1" {
    var arena_instance = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_instance.deinit();
    const arena = &arena_instance.allocator;
    std.testing.expectEqual(@as(i32, 5), try findAnswer1(arena, test_input));
    std.testing.expectEqual(@as(i32, 1753), try findAnswer1(arena, @embedFile("input.txt")));
}
