const std = @import("std");
const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const bigIntFromFloat = @import("int_from_float.zig").bigIntFromFloat;

comptime {
    symbol(&__fixxfei, "__fixxfei");
}

pub fn __fixxfei(r: [*]u8, bits: usize, a: f80) callconv(.c) void {
    const byte_size = std.zig.target.intByteSize(&builtin.target, @intCast(bits));
    return bigIntFromFloat(.signed, @ptrCast(@alignCast(r[0..byte_size])), a);
}
