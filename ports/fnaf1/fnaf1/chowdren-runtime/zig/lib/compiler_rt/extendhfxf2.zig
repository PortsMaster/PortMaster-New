const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const extend_f80 = @import("./extendf.zig").extend_f80;

comptime {
    symbol(&__extendhfxf2, "__extendhfxf2");
}

fn __extendhfxf2(a: compiler_rt.F16T(f80)) callconv(.c) f80 {
    return extend_f80(f16, @as(u16, @bitCast(a)));
}
