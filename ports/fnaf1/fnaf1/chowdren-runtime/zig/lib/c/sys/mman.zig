const builtin = @import("builtin");

const std = @import("std");

const symbol = @import("../../c.zig").symbol;
const errno = @import("../../c.zig").errno;

comptime {
    if (builtin.target.isMuslLibC()) {
        symbol(&madviseLinux, "madvise");
        symbol(&madviseLinux, "__madvise");

        symbol(&mincoreLinux, "mincore");

        symbol(&mlockLinux, "mlock");
        symbol(&mlockallLinux, "mlockall");

        symbol(&mprotectLinux, "mprotect");
        symbol(&mprotectLinux, "__mprotect");

        symbol(&munlockLinux, "munlock");
        symbol(&munlockallLinux, "munlockall");

        symbol(&posix_madviseLinux, "posix_madvise");
    }
}

fn madviseLinux(addr: *anyopaque, len: usize, advice: c_int) callconv(.c) c_int {
    return errno(std.os.linux.madvise(@ptrCast(addr), len, @bitCast(advice)));
}

fn mincoreLinux(addr: *anyopaque, len: usize, vec: [*]u8) callconv(.c) c_int {
    return errno(std.os.linux.mincore(@ptrCast(addr), len, vec));
}

fn mlockLinux(addr: *const anyopaque, len: usize) callconv(.c) c_int {
    return errno(std.os.linux.mlock(@ptrCast(addr), len));
}

fn mlockallLinux(flags: c_int) callconv(.c) c_int {
    return errno(std.os.linux.mlockall(@bitCast(flags)));
}

fn mprotectLinux(addr: *anyopaque, len: usize, prot: c_int) callconv(.c) c_int {
    const page_size = std.heap.pageSize();
    const start = std.mem.alignBackward(usize, @intFromPtr(addr), page_size);
    const aligned_len = std.mem.alignForward(usize, len, page_size);
    return errno(std.os.linux.mprotect(@ptrFromInt(start), aligned_len, @bitCast(prot)));
}

fn munlockLinux(addr: *const anyopaque, len: usize) callconv(.c) c_int {
    return errno(std.os.linux.munlock(@ptrCast(addr), len));
}

fn munlockallLinux() callconv(.c) c_int {
    return errno(std.os.linux.munlockall());
}

fn posix_madviseLinux(addr: *anyopaque, len: usize, advice: c_int) callconv(.c) c_int {
    if (advice == std.os.linux.MADV.DONTNEED) return 0;
    return @intCast(-@as(isize, @bitCast(std.os.linux.madvise(@ptrCast(addr), len, @bitCast(advice)))));
}
