const Builder = @import("std").build.Builder;

const days_implemented = 2;

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
    }
}
