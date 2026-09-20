const builtin = @import("builtin");

const std = @import("std");

const symbol = @import("../../c.zig").symbol;
const errno = @import("../../c.zig").errno;

comptime {
    if (builtin.target.isMuslLibC()) {
        symbol(&flockLinux, "flock");
    }
}

fn flockLinux(fd: c_int, operation: c_int) callconv(.c) c_int {
    return errno(std.os.linux.flock(fd, operation));
}
