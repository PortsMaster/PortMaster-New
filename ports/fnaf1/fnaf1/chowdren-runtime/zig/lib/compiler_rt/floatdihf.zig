const symbol = @import("../compiler_rt.zig").symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    symbol(&__floatdihf, "__floatdihf");
}

fn __floatdihf(a: i64) callconv(.c) f16 {
    return floatFromInt(f16, a);
}
