const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const addf3 = @import("./addf3.zig").addf3;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__addtf3, "__addkf3");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_add, "_Qp_add");
    }
    symbol(&__addtf3, "__addtf3");
}

pub fn __addtf3(a: f128, b: f128) callconv(.c) f128 {
    return addf3(f128, a, b);
}

fn _Qp_add(c: *f128, a: *f128, b: *f128) callconv(.c) void {
    c.* = addf3(f128, a.*, b.*);
}
