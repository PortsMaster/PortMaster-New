const symbol = @import("../compiler_rt.zig").symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    symbol(&__fixxfdi, "__fixxfdi");
}

fn __fixxfdi(a: f80) callconv(.c) i64 {
    return intFromFloat(i64, a);
}
