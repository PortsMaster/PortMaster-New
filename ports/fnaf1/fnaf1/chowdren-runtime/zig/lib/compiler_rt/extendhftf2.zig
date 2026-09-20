const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const extendf = @import("./extendf.zig").extendf;

comptime {
    symbol(&__extendhftf2, "__extendhftf2");
}

pub fn __extendhftf2(a: compiler_rt.F16T(f128)) callconv(.c) f128 {
    return extendf(f128, f16, @as(u16, @bitCast(a)));
}
