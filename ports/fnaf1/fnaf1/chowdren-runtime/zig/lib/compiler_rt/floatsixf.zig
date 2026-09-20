const compiler_rt = @import("../compiler_rt.zig");
const floatFromInt = @import("./float_from_int.zig").floatFromInt;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    symbol(&__floatsixf, "__floatsixf");
}

fn __floatsixf(a: i32) callconv(.c) f80 {
    return floatFromInt(f80, a);
}
