const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__fixtfsi, "__fixkfsi");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_qtoi, "_Qp_qtoi");
    }
    symbol(&__fixtfsi, "__fixtfsi");
}

pub fn __fixtfsi(a: f128) callconv(.c) i32 {
    return intFromFloat(i32, a);
}

fn _Qp_qtoi(a: *const f128) callconv(.c) i32 {
    return intFromFloat(i32, a.*);
}
