const symbol = @import("../compiler_rt.zig").symbol;
const divsf3 = @import("./divsf3.zig");

comptime {
    symbol(&__divhf3, "__divhf3");
}

pub fn __divhf3(a: f16, b: f16) callconv(.c) f16 {
    // TODO: more efficient implementation
    return @floatCast(divsf3.__divsf3(a, b));
}
