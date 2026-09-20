const builtin = @import("builtin");

const std = @import("std");

const symbol = @import("../compiler_rt.zig").symbol;
const floatFromBigInt = @import("float_from_int.zig").floatFromBigInt;

comptime {
    symbol(&__floateixf, "__floateixf");
}

pub fn __floateixf(a: [*]const u8, bits: usize) callconv(.c) f80 {
    const byte_size = std.zig.target.intByteSize(&builtin.target, @intCast(bits));
    return floatFromBigInt(f80, .signed, @ptrCast(@alignCast(a[0..byte_size])));
}
