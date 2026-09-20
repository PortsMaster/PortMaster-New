const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__fixunstfdi, "__fixunskfdi");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_qtoux, "_Qp_qtoux");
    }
    symbol(&__fixunstfdi, "__fixunstfdi");
}

pub fn __fixunstfdi(a: f128) callconv(.c) u64 {
    return intFromFloat(u64, a);
}

fn _Qp_qtoux(a: *const f128) callconv(.c) u64 {
    return intFromFloat(u64, a.*);
}
