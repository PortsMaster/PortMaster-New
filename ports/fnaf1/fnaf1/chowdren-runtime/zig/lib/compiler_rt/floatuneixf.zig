const std = @import("std");
const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromBigInt = @import("float_from_int.zig").floatFromBigInt;

comptime {
    symbol(&__floatuneixf, "__floatuneixf");
}

pub fn __floatuneixf(a: [*]const u8, bits: usize) callconv(.c) f80 {
    const byte_size = std.zig.target.intByteSize(&builtin.target, @intCast(bits));
    return floatFromBigInt(f80, .unsigned, @ptrCast(@alignCast(a[0..byte_size])));
}
