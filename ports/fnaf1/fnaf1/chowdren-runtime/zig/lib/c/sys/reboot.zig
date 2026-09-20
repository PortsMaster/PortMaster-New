const builtin = @import("builtin");

const std = @import("std");

const symbol = @import("../../c.zig").symbol;
const errno = @import("../../c.zig").errno;

comptime {
    if (builtin.target.isMuslLibC()) {
        symbol(&rebootLinux, "reboot");
    }
}

fn rebootLinux(cmd: c_int) callconv(.c) c_int {
    return errno(std.os.linux.reboot(.MAGIC1, .MAGIC2, @enumFromInt(cmd), null));
}
