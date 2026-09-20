const builtin = @import("builtin");

const std = @import("std");

const symbol = @import("../compiler_rt.zig").symbol;
const bigIntFromFloat = @import("int_from_float.zig").bigIntFromFloat;

comptime {
    symbol(&__fixunsdfei, "__fixunsdfei");
}

pub fn __fixunsdfei(r: [*]u8, bits: usize, a: f64) callconv(.c) void {
    const byte_size = std.zig.target.intByteSize(&builtin.target, @intCast(bits));
    return bigIntFromFloat(.unsigned, @ptrCast(@alignCast(r[0..byte_size])), a);
}
