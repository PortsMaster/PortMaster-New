const std = @import("std");
const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromBigInt = @import("float_from_int.zig").floatFromBigInt;

comptime {
    symbol(&__floateitf, "__floateitf");
}

pub fn __floateitf(a: [*]const u8, bits: usize) callconv(.c) f128 {
    const byte_size = std.zig.target.intByteSize(&builtin.target, @intCast(bits));
    return floatFromBigInt(f128, .signed, @ptrCast(@alignCast(a[0..byte_size])));
}
