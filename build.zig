const std = @import("std");

pub fn build(b: *std.Build) void {
    const targets = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{ .root_source_file = b.path("./src//main.zig"), .target = targets, .optimize = optimize });

    const exe = b.addExecutable(.{ .name = "breakout", .root_module = exe_mod });

    // --- raylib-zig dependency ---
    const raylib_dep = b.dependency("raylib_zig", .{ .target = targets, .optimize = optimize });
    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");

    exe.root_module.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the game");
    run_step.dependOn(&run_cmd.step);
}
