const std = @import("std");
const builtin = @import("builtin");
const symbol = @import("../compiler_rt.zig").symbol;
const bigIntFromFloat = @import("int_from_float.zig").bigIntFromFloat;

comptime {
    symbol(&__fixunsxfei, "__fixunsxfei");
}

pub fn __fixunsxfei(r: [*]u8, bits: usize, a: f80) callconv(.c) void {
    const byte_size = std.zig.target.intByteSize(&builtin.target, @intCast(bits));
    return bigIntFromFloat(.unsigned, @ptrCast(@alignCast(r[0..byte_size])), a);
}
