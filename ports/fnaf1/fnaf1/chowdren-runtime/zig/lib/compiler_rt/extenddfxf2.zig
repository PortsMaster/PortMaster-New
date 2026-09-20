const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const extend_f80 = @import("./extendf.zig").extend_f80;

comptime {
    symbol(&__extenddfxf2, "__extenddfxf2");
}

pub fn __extenddfxf2(a: f64) callconv(.c) f80 {
    return extend_f80(f64, @as(u64, @bitCast(a)));
}
