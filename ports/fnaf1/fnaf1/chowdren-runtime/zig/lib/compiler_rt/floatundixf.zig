const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    symbol(&__floatundixf, "__floatundixf");
}

fn __floatundixf(a: u64) callconv(.c) f80 {
    return floatFromInt(f80, a);
}
