const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const mulf3 = @import("./mulf3.zig").mulf3;

comptime {
    symbol(&__mulhf3, "__mulhf3");
}

pub fn __mulhf3(a: f16, b: f16) callconv(.c) f16 {
    return mulf3(f16, a, b);
}
