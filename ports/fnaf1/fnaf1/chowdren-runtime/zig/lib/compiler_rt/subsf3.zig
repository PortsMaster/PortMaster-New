const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const addf3 = @import("./addf3.zig").addf3;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_fsub, "__aeabi_fsub");
    } else {
        symbol(&__subsf3, "__subsf3");
    }
}

fn __subsf3(a: f32, b: f32) callconv(.c) f32 {
    return sub(a, b);
}

fn __aeabi_fsub(a: f32, b: f32) callconv(.{ .arm_aapcs = .{} }) f32 {
    return sub(a, b);
}

inline fn sub(a: f32, b: f32) f32 {
    const neg_b = @as(f32, @bitCast(@as(u32, @bitCast(b)) ^ (@as(u32, 1) << 31)));
    return addf3(f32, a, neg_b);
}
