const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zenolith_mod = b.dependency("zenolith", .{
        .target = target,
        .optimize = optimize,
    }).module("zenolith");

    const mod = b.addModule("zenolith-sdl2", .{
        .root_source_file = .{ .path = "src/main.zig" },
        .imports = &.{.{ .name = "zenolith", .module = zenolith_mod }},
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    mod.linkSystemLibrary("SDL2", .{});
    mod.linkSystemLibrary("freetype2", .{});

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    main_tests.root_module.addImport("zenolith", zenolith_mod);

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);

    const example_exe = b.addExecutable(.{
        .name = "zenolith-sdl2-example",
        .root_source_file = .{ .path = "example/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    example_exe.root_module.addImport("zenolith", zenolith_mod);
    example_exe.root_module.addImport("zenolith-sdl2", mod);

    b.installArtifact(example_exe);

    const run_example = b.addRunArtifact(example_exe);

    const run_example_step = b.step("run-example", "Runs the example");
    run_example_step.dependOn(&run_example.step);
}
