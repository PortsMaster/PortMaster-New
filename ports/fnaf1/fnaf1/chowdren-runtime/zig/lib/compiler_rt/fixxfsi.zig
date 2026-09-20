const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    symbol(&__fixxfsi, "__fixxfsi");
}

fn __fixxfsi(a: f80) callconv(.c) i32 {
    return intFromFloat(i32, a);
}
