const std = @import("std");

// Returns the file contents, loaded from the file in debug builds and
// compiled in with release builds.  alloc must be an arena allocator,
// because otherwise there will be a leak.
pub fn file_contents(alloc: *std.mem.Allocator, comptime name: []const u8) ![]const u8 {
    switch (std.builtin.mode) {
        .Debug => {
            const file = try std.fs.cwd().openFile(name, std.fs.File.OpenFlags{ .read = true });
            const size = try file.getEndPos();
            const buf = try alloc.alloc(u8, size);
            _ = try file.readAll(buf);
            return buf;
        },
        .ReleaseSafe, .ReleaseFast, .ReleaseSmall => {
            const f = @embedFile("../" ++ name);
            return f[0..];
        },
    }
}
