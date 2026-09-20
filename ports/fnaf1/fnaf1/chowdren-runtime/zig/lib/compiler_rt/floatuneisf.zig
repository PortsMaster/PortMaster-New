const std = @import("std");
const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromBigInt = @import("float_from_int.zig").floatFromBigInt;

comptime {
    symbol(&__floatuneisf, "__floatuneisf");
}

pub fn __floatuneisf(a: [*]const u8, bits: usize) callconv(.c) f32 {
    const byte_size = std.zig.target.intByteSize(&builtin.target, @intCast(bits));
    return floatFromBigInt(f32, .unsigned, @ptrCast(@alignCast(a[0..byte_size])));
}
