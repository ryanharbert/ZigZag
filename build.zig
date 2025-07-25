const std = @import("std");

pub fn build(b: *std.Build) void {
    // Target Windows x86_64
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86_64,
        .os_tag = .windows,
    });
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "Grapefruit",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    // Add engine module to main exe
    const engine_module = b.createModule(.{
        .root_source_file = b.path("src/engine/engine.zig"),
    });
    
    // Add include paths to engine module
    engine_module.addIncludePath(b.path("libs/glfw/glfw-3.4.bin.WIN64/include"));
    engine_module.addIncludePath(b.path("libs/glad/include"));
    engine_module.addIncludePath(b.path("libs/stb"));
    
    exe.root_module.addImport("engine", engine_module);

    // Add GLFW library for Windows
    exe.addIncludePath(b.path("libs/glfw/glfw-3.4.bin.WIN64/include"));
    exe.addObjectFile(b.path("libs/glfw/glfw-3.4.bin.WIN64/lib-mingw-w64/libglfw3.a"));
    exe.linkSystemLibrary("opengl32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("kernel32");

    // Add GLAD
    exe.addIncludePath(b.path("libs/glad/include"));
    exe.addCSourceFile(.{ 
        .file = b.path("libs/glad/src/glad.c"),
        .flags = &.{"-std=c99"}
    });

    // Add STB Image and TrueType
    exe.addIncludePath(b.path("libs/stb"));
    exe.addCSourceFile(.{ 
        .file = b.path("libs/stb/stb_image.c"),
        .flags = &.{"-std=c99"}
    });
    exe.addCSourceFile(.{ 
        .file = b.path("libs/stb/stb_truetype.c"),
        .flags = &.{"-std=c99"}
    });

    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Gameplay Test
    const gameplay_test_exe = b.addExecutable(.{
        .name = "gameplay-test",
        .root_source_file = b.path("src/gameplay-test/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    // Add engine module to gameplay test
    gameplay_test_exe.root_module.addImport("engine", engine_module);

    // Add same libraries as main exe
    gameplay_test_exe.addIncludePath(b.path("libs/glfw/glfw-3.4.bin.WIN64/include"));
    gameplay_test_exe.addObjectFile(b.path("libs/glfw/glfw-3.4.bin.WIN64/lib-mingw-w64/libglfw3.a"));
    gameplay_test_exe.linkSystemLibrary("opengl32");
    gameplay_test_exe.linkSystemLibrary("gdi32");
    gameplay_test_exe.linkSystemLibrary("user32");
    gameplay_test_exe.linkSystemLibrary("kernel32");

    gameplay_test_exe.addIncludePath(b.path("libs/glad/include"));
    gameplay_test_exe.addCSourceFile(.{ 
        .file = b.path("libs/glad/src/glad.c"),
        .flags = &.{"-std=c99"}
    });

    gameplay_test_exe.addIncludePath(b.path("libs/stb"));
    gameplay_test_exe.addCSourceFile(.{ 
        .file = b.path("libs/stb/stb_image.c"),
        .flags = &.{"-std=c99"}
    });
    gameplay_test_exe.addCSourceFile(.{ 
        .file = b.path("libs/stb/stb_truetype.c"),
        .flags = &.{"-std=c99"}
    });

    gameplay_test_exe.linkLibC();

    const gameplay_test_run_cmd = b.addRunArtifact(gameplay_test_exe);
    gameplay_test_run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        gameplay_test_run_cmd.addArgs(args);
    }

    const gameplay_test_run_step = b.step("gameplay", "Run the gameplay test");
    gameplay_test_run_step.dependOn(&gameplay_test_run_cmd.step);

    // Render Test
    const render_test_exe = b.addExecutable(.{
        .name = "render-test",
        .root_source_file = b.path("src/render-test/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    // Add engine module to render test
    render_test_exe.root_module.addImport("engine", engine_module);

    // Add same libraries as main exe
    render_test_exe.addIncludePath(b.path("libs/glfw/glfw-3.4.bin.WIN64/include"));
    render_test_exe.addObjectFile(b.path("libs/glfw/glfw-3.4.bin.WIN64/lib-mingw-w64/libglfw3.a"));
    render_test_exe.linkSystemLibrary("opengl32");
    render_test_exe.linkSystemLibrary("gdi32");
    render_test_exe.linkSystemLibrary("user32");
    render_test_exe.linkSystemLibrary("kernel32");

    render_test_exe.addIncludePath(b.path("libs/glad/include"));
    render_test_exe.addCSourceFile(.{ 
        .file = b.path("libs/glad/src/glad.c"),
        .flags = &.{"-std=c99"}
    });

    render_test_exe.addIncludePath(b.path("libs/stb"));
    render_test_exe.addCSourceFile(.{ 
        .file = b.path("libs/stb/stb_image.c"),
        .flags = &.{"-std=c99"}
    });
    render_test_exe.addCSourceFile(.{ 
        .file = b.path("libs/stb/stb_truetype.c"),
        .flags = &.{"-std=c99"}
    });

    render_test_exe.linkLibC();

    const render_test_run_cmd = b.addRunArtifact(render_test_exe);
    render_test_run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        render_test_run_cmd.addArgs(args);
    }

    const render_test_run_step = b.step("render-test", "Run the render test");
    render_test_run_step.dependOn(&render_test_run_cmd.step);

    // ECS Test
    const use_bitset_ecs = b.option(bool, "bitset-ecs", "Use bitset ECS instead of sparse set ECS") orelse true;
    
    const build_options = b.addOptions();
    build_options.addOption(bool, "use_bitset_ecs", use_bitset_ecs);
    
    const ecs_test_exe = b.addExecutable(.{
        .name = "ecs-test",
        .root_source_file = b.path("src/ecs-test/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    // Add ECS module to ecs-test exe
    const ecs_module = b.createModule(.{
        .root_source_file = b.path("src/ecs/world.zig"),
    });
    ecs_module.addOptions("build_options", build_options);
    ecs_test_exe.root_module.addImport("ecs", ecs_module);
    ecs_test_exe.root_module.addOptions("build_options", build_options);
    ecs_test_exe.linkLibC();
    
    const ecs_test_run_cmd = b.addRunArtifact(ecs_test_exe);
    ecs_test_run_cmd.step.dependOn(b.getInstallStep());
    
    if (b.args) |args| {
        ecs_test_run_cmd.addArgs(args);
    }
    
    const ecs_test_run_step = b.step("ecs-test", "Run ECS implementation tests");
    ecs_test_run_step.dependOn(&ecs_test_run_cmd.step);

    // Gameplay Test 2 - ECS Systems Demo
    const gameplay_test2_exe = b.addExecutable(.{
        .name = "gameplay-test-2",
        .root_source_file = b.path("src/gameplay-test-2/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    // Create dedicated build options for gameplay-test-2 (always use sparse set ECS)
    const gameplay_test2_build_options = b.addOptions();
    gameplay_test2_build_options.addOption(bool, "use_bitset_ecs", false); // Always false for gameplay-test-2
    
    // Create dedicated ECS module for gameplay-test-2 - use new generic ECS
    const gameplay_test2_ecs_module = b.createModule(.{
        .root_source_file = b.path("src/ecs/mod.zig"),
    });
    
    // Add engine and ECS modules to gameplay-test-2
    gameplay_test2_exe.root_module.addImport("engine", engine_module);
    gameplay_test2_exe.root_module.addImport("ecs", gameplay_test2_ecs_module);

    // Add same libraries as main exe
    gameplay_test2_exe.addIncludePath(b.path("libs/glfw/glfw-3.4.bin.WIN64/include"));
    gameplay_test2_exe.addObjectFile(b.path("libs/glfw/glfw-3.4.bin.WIN64/lib-mingw-w64/libglfw3.a"));
    gameplay_test2_exe.linkSystemLibrary("opengl32");
    gameplay_test2_exe.linkSystemLibrary("gdi32");
    gameplay_test2_exe.linkSystemLibrary("user32");
    gameplay_test2_exe.linkSystemLibrary("kernel32");

    gameplay_test2_exe.addIncludePath(b.path("libs/glad/include"));
    gameplay_test2_exe.addCSourceFile(.{ 
        .file = b.path("libs/glad/src/glad.c"),
        .flags = &.{"-std=c99"}
    });

    gameplay_test2_exe.addIncludePath(b.path("libs/stb"));
    gameplay_test2_exe.addCSourceFile(.{ 
        .file = b.path("libs/stb/stb_image.c"),
        .flags = &.{"-std=c99"}
    });
    gameplay_test2_exe.addCSourceFile(.{ 
        .file = b.path("libs/stb/stb_truetype.c"),
        .flags = &.{"-std=c99"}
    });

    gameplay_test2_exe.linkLibC();

    const gameplay_test2_run_cmd = b.addRunArtifact(gameplay_test2_exe);
    gameplay_test2_run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        gameplay_test2_run_cmd.addArgs(args);
    }

    const gameplay_test2_run_step = b.step("gameplay-test-2", "Run ECS systems gameplay demo");
    gameplay_test2_run_step.dependOn(&gameplay_test2_run_cmd.step);

    // Tests
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/engine/math_test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
