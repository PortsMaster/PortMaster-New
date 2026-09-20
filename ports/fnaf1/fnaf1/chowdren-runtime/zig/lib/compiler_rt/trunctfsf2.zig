const compiler_rt = @import("../compiler_rt.zig");
const truncf = @import("./truncf.zig").truncf;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__trunctfsf2, "__trunckfsf2");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_qtos, "_Qp_qtos");
    }
    symbol(&__trunctfsf2, "__trunctfsf2");
}

pub fn __trunctfsf2(a: f128) callconv(.c) f32 {
    return truncf(f32, f128, a);
}

fn _Qp_qtos(a: *const f128) callconv(.c) f32 {
    return truncf(f32, f128, a.*);
}
