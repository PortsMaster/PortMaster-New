const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    symbol(&__floatsihf, "__floatsihf");
}

fn __floatsihf(a: i32) callconv(.c) f16 {
    return floatFromInt(f16, a);
}
