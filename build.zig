const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    //const zenolith_mod = b.addModule("zenolith", .{
    //    .source_file = .{ .path = "../zenolith/src/main.zig" },
    //    .dependencies = &.{.{
    //        .name = "statspatch",
    //        .module = b.dependency("statspatch", .{
    //            .target = target,
    //            .optimize = optimize,
    //        }).module("statspatch"),
    //    }},
    //});

    const zenolith_mod = b.dependency("zenolith", .{
        .target = target,
        .optimize = optimize,
    }).module("zenolith");

    const mod = b.addModule("zenolith-sdl2", .{
        .source_file = .{ .path = "src/main.zig" },
        .dependencies = &.{.{ .name = "zenolith", .module = zenolith_mod }},
    });

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    main_tests.addModule("zenolith", zenolith_mod);
    addPlatformDeps(main_tests);

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);

    const example_exe = b.addExecutable(.{
        .name = "zenolith-sdl2-example",
        .root_source_file = .{ .path = "example/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    example_exe.addModule("zenolith", zenolith_mod);
    example_exe.addModule("zenolith-sdl2", mod);
    addPlatformDeps(example_exe);

    b.installArtifact(example_exe);

    const run_example = b.addRunArtifact(example_exe);

    const run_example_step = b.step("run-example", "Runs the example");
    run_example_step.dependOn(&run_example.step);
}

fn addPlatformDeps(artifact: *std.Build.Step.Compile) void {
    artifact.linkLibC();
    artifact.linkSystemLibrary("SDL2");
    artifact.linkSystemLibrary("freetype2");
}
