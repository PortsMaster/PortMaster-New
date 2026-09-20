const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const extendf = @import("./extendf.zig").extendf;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__extendsftf2, "__extendsfkf2");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_stoq, "_Qp_stoq");
    }
    symbol(&__extendsftf2, "__extendsftf2");
}

pub fn __extendsftf2(a: f32) callconv(.c) f128 {
    return extendf(f128, f32, @as(u32, @bitCast(a)));
}

fn _Qp_stoq(c: *f128, a: f32) callconv(.c) void {
    c.* = extendf(f128, f32, @as(u32, @bitCast(a)));
}
