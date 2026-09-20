const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__floatunditf, "__floatundikf");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_uxtoq, "_Qp_uxtoq");
    }
    symbol(&__floatunditf, "__floatunditf");
}

pub fn __floatunditf(a: u64) callconv(.c) f128 {
    return floatFromInt(f128, a);
}

fn _Qp_uxtoq(c: *f128, a: u64) callconv(.c) void {
    c.* = floatFromInt(f128, a);
}
