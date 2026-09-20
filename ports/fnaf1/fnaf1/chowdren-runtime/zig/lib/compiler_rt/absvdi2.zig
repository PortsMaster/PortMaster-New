const symbol = @import("../compiler_rt.zig").symbol;
const absv = @import("./absv.zig").absv;

comptime {
    symbol(&__absvdi2, "__absvdi2");
}

pub fn __absvdi2(a: i64) callconv(.c) i64 {
    return absv(i64, a);
}
