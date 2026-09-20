const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__fixunstfsi, "__fixunskfsi");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_qtoui, "_Qp_qtoui");
    }
    symbol(&__fixunstfsi, "__fixunstfsi");
}

pub fn __fixunstfsi(a: f128) callconv(.c) u32 {
    return intFromFloat(u32, a);
}

fn _Qp_qtoui(a: *const f128) callconv(.c) u32 {
    return intFromFloat(u32, a.*);
}
