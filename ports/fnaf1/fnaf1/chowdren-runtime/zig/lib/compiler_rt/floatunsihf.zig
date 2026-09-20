const symbol = @import("../compiler_rt.zig").symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    symbol(&__floatunsihf, "__floatunsihf");
}

pub fn __floatunsihf(a: u32) callconv(.c) f16 {
    return floatFromInt(f16, a);
}
