const std = @import("std");
const Allocator = std.mem.Allocator;

const puzzle = @import(@import("build_options").puzzle_file);

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() anyerror!void {
    const gpa = if (std.builtin.link_libc)
        std.heap.raw_c_allocator
    else
        &general_purpose_allocator.allocator;
    defer if (!std.builtin.link_libc) {
        _ = general_purpose_allocator.deinit();
    };

    var arena_instance = std.heap.ArenaAllocator.init(gpa);
    defer arena_instance.deinit();
    const arena = &arena_instance.allocator;

    const args = try std.process.argsAlloc(arena);
    if (args.len != 2) {
        std.log.err("Incorrect number of arguments", .{});
        std.log.info("Usage: {} <input_file>", .{args[0]});
        std.process.exit(1);
    }

    const input = try std.fs.cwd().readFileAlloc(arena, args[1], 1024 * 1024);
    const stdout = std.io.getStdOut().writer();

    const answer1 = switch (@typeInfo(@TypeOf(puzzle.findAnswer1)).Fn.args.len) {
        1 => try puzzle.findAnswer1(input),
        2 => try puzzle.findAnswer1(arena, input),
        else => @compileError("findAnswer1: incorrect number of arguments"),
    };
    try stdout.print("Answer 1: {}\n", .{answer1});

    const answer2 = switch (@typeInfo(@TypeOf(puzzle.findAnswer2)).Fn.args.len) {
        1 => try puzzle.findAnswer2(input),
        2 => try puzzle.findAnswer2(arena, input),
        else => @compileError("findAnswer2: incorrect number of arguments"),
    };
    try stdout.print("Answer 2: {}\n", .{answer2});
}
