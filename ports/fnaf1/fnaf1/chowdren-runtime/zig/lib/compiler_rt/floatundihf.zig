const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    symbol(&__floatundihf, "__floatundihf");
}

fn __floatundihf(a: u64) callconv(.c) f16 {
    return floatFromInt(f16, a);
}
