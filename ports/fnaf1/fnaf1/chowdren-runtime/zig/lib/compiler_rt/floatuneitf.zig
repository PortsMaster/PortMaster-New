const builtin = @import("builtin");

const std = @import("std");

const symbol = @import("../compiler_rt.zig").symbol;
const floatFromBigInt = @import("float_from_int.zig").floatFromBigInt;

comptime {
    symbol(&__floatuneitf, "__floatuneitf");
}

pub fn __floatuneitf(a: [*]const u8, bits: usize) callconv(.c) f128 {
    const byte_size = std.zig.target.intByteSize(&builtin.target, @intCast(bits));
    return floatFromBigInt(f128, .unsigned, @ptrCast(@alignCast(a[0..byte_size])));
}
