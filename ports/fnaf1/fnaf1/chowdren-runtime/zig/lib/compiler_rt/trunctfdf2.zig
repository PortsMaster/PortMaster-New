const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const truncf = @import("./truncf.zig").truncf;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__trunctfdf2, "__trunckfdf2");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_qtod, "_Qp_qtod");
    }
    symbol(&__trunctfdf2, "__trunctfdf2");
}

pub fn __trunctfdf2(a: f128) callconv(.c) f64 {
    return truncf(f64, f128, a);
}

fn _Qp_qtod(a: *const f128) callconv(.c) f64 {
    return truncf(f64, f128, a.*);
}
