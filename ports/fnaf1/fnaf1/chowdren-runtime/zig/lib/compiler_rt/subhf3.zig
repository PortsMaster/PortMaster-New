const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const addf3 = @import("./addf3.zig").addf3;

comptime {
    symbol(&__subhf3, "__subhf3");
}

fn __subhf3(a: f16, b: f16) callconv(.c) f16 {
    const neg_b = @as(f16, @bitCast(@as(u16, @bitCast(b)) ^ (@as(u16, 1) << 15)));
    return addf3(f16, a, neg_b);
}
