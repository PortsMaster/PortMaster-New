const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const mulf3 = @import("./mulf3.zig").mulf3;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__multf3, "__mulkf3");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_mul, "_Qp_mul");
    }
    symbol(&__multf3, "__multf3");
}

pub fn __multf3(a: f128, b: f128) callconv(.c) f128 {
    return mulf3(f128, a, b);
}

fn _Qp_mul(c: *f128, a: *const f128, b: *const f128) callconv(.c) void {
    c.* = mulf3(f128, a.*, b.*);
}
