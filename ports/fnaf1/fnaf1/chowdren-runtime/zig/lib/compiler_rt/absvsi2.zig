const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const absv = @import("./absv.zig").absv;

comptime {
    symbol(&__absvsi2, "__absvsi2");
}

pub fn __absvsi2(a: i32) callconv(.c) i32 {
    return absv(i32, a);
}
