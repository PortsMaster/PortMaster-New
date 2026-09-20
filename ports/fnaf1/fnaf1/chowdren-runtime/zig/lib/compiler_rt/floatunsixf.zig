const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    symbol(&__floatunsixf, "__floatunsixf");
}

fn __floatunsixf(a: u32) callconv(.c) f80 {
    return floatFromInt(f80, a);
}
