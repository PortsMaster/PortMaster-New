const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__floatsitf, "__floatsikf");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_itoq, "_Qp_itoq");
    }
    symbol(&__floatsitf, "__floatsitf");
}

pub fn __floatsitf(a: i32) callconv(.c) f128 {
    return floatFromInt(f128, a);
}

fn _Qp_itoq(c: *f128, a: i32) callconv(.c) void {
    c.* = floatFromInt(f128, a);
}
