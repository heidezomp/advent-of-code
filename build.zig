const Builder = @import("std").build.Builder;

const days_implemented = 3;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    var day: u8 = 1;
    while (day <= days_implemented) : (day += 1) {
        const day_str = b.fmt("day{d:0>2}", .{day});
        const exe = b.addExecutable(
            b.fmt("advent-of-code-2020-{}", .{day_str}),
            b.fmt("2020/{}/puzzle.zig", .{day_str}),
        );
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(
            b.fmt("run-2020-{}", .{day_str}),
            b.fmt("Run solution for 2020, day {}", .{day}),
        );
        run_step.dependOn(&run_cmd.step);

        const test_cmd = b.addTest(b.fmt("2020/{}/puzzle.zig", .{day_str}));
        test_cmd.setTarget(target);
        test_cmd.setBuildMode(mode);

        const test_step = b.step(
            b.fmt("test-2020-{}", .{day_str}),
            b.fmt("Run tests for 2020, day {}", .{day}),
        );
        test_step.dependOn(&test_cmd.step);
    }
}
