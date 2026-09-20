const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;
const extendf = @import("./extendf.zig").extendf;

comptime {
    symbol(&__extendhfdf2, "__extendhfdf2");
}

pub fn __extendhfdf2(a: compiler_rt.F16T(f64)) callconv(.c) f64 {
    return extendf(f64, f16, @as(u16, @bitCast(a)));
}
