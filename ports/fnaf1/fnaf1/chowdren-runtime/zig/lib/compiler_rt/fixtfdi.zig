const compiler_rt = @import("../compiler_rt.zig");
const intFromFloat = @import("./int_from_float.zig").intFromFloat;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__fixtfdi, "__fixkfdi");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_qtox, "_Qp_qtox");
    }
    symbol(&__fixtfdi, "__fixtfdi");
}

pub fn __fixtfdi(a: f128) callconv(.c) i64 {
    return intFromFloat(i64, a);
}

fn _Qp_qtox(a: *const f128) callconv(.c) i64 {
    return intFromFloat(i64, a.*);
}
