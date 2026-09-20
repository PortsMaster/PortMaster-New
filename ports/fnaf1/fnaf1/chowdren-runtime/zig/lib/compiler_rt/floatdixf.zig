const symbol = @import("../compiler_rt.zig").symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    symbol(&__floatdixf, "__floatdixf");
}

fn __floatdixf(a: i64) callconv(.c) f80 {
    return floatFromInt(f80, a);
}
