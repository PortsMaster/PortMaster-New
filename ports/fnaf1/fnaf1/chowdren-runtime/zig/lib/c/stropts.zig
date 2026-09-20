const builtin = @import("builtin");

const std = @import("std");
const linux = std.os.linux;

const symbol = @import("../c.zig").symbol;
const errno = @import("../c.zig").errno;

comptime {
    if (builtin.target.isMuslLibC()) {
        symbol(&isastream, "isastream");
    }
}

fn isastream(fd: c_int) callconv(.c) c_int {
    return if (errno(linux.fcntl(fd, linux.F.GETFD, 0)) < 0) -1 else 0;
}
