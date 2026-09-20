const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const mulf3 = @import("./mulf3.zig").mulf3;

comptime {
    symbol(&__mulxf3, "__mulxf3");
}

pub fn __mulxf3(a: f80, b: f80) callconv(.c) f80 {
    return mulf3(f80, a, b);
}
