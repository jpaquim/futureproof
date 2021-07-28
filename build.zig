const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("futureproof", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    // Libraries!
    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("freetype2");
    exe.linkSystemLibrary("stdc++"); // needed for shaderc

    exe.addLibPath("vendor/wgpu");
    exe.linkSystemLibrary("wgpu_native");
    exe.addIncludeDir("vendor"); // "wgpu/wgpu.h" is the wgpu header

    exe.addLibPath("vendor/shaderc/lib");
    exe.linkSystemLibrary("shaderc_combined");
    exe.addIncludeDir("vendor/shaderc/include/");

    exe.addIncludeDir("."); // for "extern/futureproof.h"

    // This must come before the install_name_tool call below
    exe.install();

    if (exe.target.isDarwin()) {
        exe.addFrameworkDir("/System/Library/Frameworks");
        exe.linkFramework("Foundation");
        exe.linkFramework("AppKit");
        // not needed, ended up symlinking OpenGL headers to /usr/local/include
        // ln -s /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/OpenGL.framework/Headers/ /usr/local/include/OpenGL
        // exe.addFrameworkDir("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks");
        // exe.linkFramework("OpenGL");
    }

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
