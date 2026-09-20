const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const addf3 = @import("./addf3.zig").addf3;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__subtf3, "__subkf3");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_sub, "_Qp_sub");
    }
    symbol(&__subtf3, "__subtf3");
}

pub fn __subtf3(a: f128, b: f128) callconv(.c) f128 {
    return sub(a, b);
}

fn _Qp_sub(c: *f128, a: *const f128, b: *const f128) callconv(.c) void {
    c.* = sub(a.*, b.*);
}

inline fn sub(a: f128, b: f128) f128 {
    const neg_b = @as(f128, @bitCast(@as(u128, @bitCast(b)) ^ (@as(u128, 1) << 127)));
    return addf3(f128, a, neg_b);
}
