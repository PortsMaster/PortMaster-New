const compiler_rt = @import("../compiler_rt.zig");
const extendf = @import("./extendf.zig").extendf;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__extenddftf2, "__extenddfkf2");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_dtoq, "_Qp_dtoq");
    }
    symbol(&__extenddftf2, "__extenddftf2");
}

pub fn __extenddftf2(a: f64) callconv(.c) f128 {
    return extendf(f128, f64, @as(u64, @bitCast(a)));
}

fn _Qp_dtoq(c: *f128, a: f64) callconv(.c) void {
    c.* = extendf(f128, f64, @as(u64, @bitCast(a)));
}
