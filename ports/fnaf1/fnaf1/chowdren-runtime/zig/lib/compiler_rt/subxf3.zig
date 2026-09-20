const std = @import("std");
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    symbol(&__subxf3, "__subxf3");
}

fn __subxf3(a: f80, b: f80) callconv(.c) f80 {
    var b_rep = std.math.F80.fromFloat(b);
    b_rep.exp ^= 0x8000;
    const neg_b = b_rep.toFloat();
    return a + neg_b;
}
