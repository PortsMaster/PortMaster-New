const compiler_rt = @import("../compiler_rt.zig");
const addf3 = @import("./addf3.zig").addf3;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_dsub, "__aeabi_dsub");
    } else {
        symbol(&__subdf3, "__subdf3");
    }
}

fn __subdf3(a: f64, b: f64) callconv(.c) f64 {
    return sub(a, b);
}

fn __aeabi_dsub(a: f64, b: f64) callconv(.{ .arm_aapcs = .{} }) f64 {
    return sub(a, b);
}

inline fn sub(a: f64, b: f64) f64 {
    const neg_b = @as(f64, @bitCast(@as(u64, @bitCast(b)) ^ (@as(u64, 1) << 63)));
    return addf3(f64, a, neg_b);
}
