const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const static = b.option(
        bool,
        "static",
        "Statically link SDL2 and FreeType. Not supported on Linux.",
    ) orelse false;

    const zenolith_mod = b.dependency("zenolith", .{
        .target = target,
        .optimize = optimize,
    }).module("zenolith");

    const mod = b.addModule("zenolith-sdl2", .{
        .root_source_file = b.path("src/main.zig"),
        .imports = &.{.{ .name = "zenolith", .module = zenolith_mod }},
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    if (static) {
        if (mod.resolved_target.?.result.os.tag == .linux) {
            std.debug.print(
                \\Statically linking SDL2 is not currently possible on Linux targets.
                \\This is because andrew's SDL fork with the Zig build system doesn't work
                \\on Linux and is, in fact, not my fault :)
                \\
            , .{});
            return error.StaticLinkingNotSupported;
        }

        const sdl2_dep = b.dependency("sdl2", .{ .target = target, .optimize = optimize });
        const freetype_dep = b.dependency("freetype", .{ .target = target, .optimize = optimize });

        mod.linkLibrary(sdl2_dep.artifact("SDL2"));
        mod.linkLibrary(freetype_dep.artifact("freetype"));
    } else {
        mod.linkSystemLibrary("SDL2", .{});
        mod.linkSystemLibrary("freetype2", .{});
    }

    const main_tests = b.addTest(.{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/main.zig" } },
        .target = target,
        .optimize = optimize,
    });
    main_tests.root_module.addImport("zenolith", zenolith_mod);

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);

    const example_exe = b.addExecutable(.{
        .name = "zenolith-sdl2-example",
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "example/main.zig" } },
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
