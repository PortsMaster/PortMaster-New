const compiler_rt = @import("../compiler_rt.zig");
const truncf = @import("./truncf.zig").truncf;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_d2h, "__aeabi_d2h");
    }
    symbol(&__truncdfhf2, "__truncdfhf2");
}

pub fn __truncdfhf2(a: f64) callconv(.c) compiler_rt.F16T(f64) {
    return @bitCast(truncf(f16, f64, a));
}

fn __aeabi_d2h(a: f64) callconv(.{ .arm_aapcs = .{} }) u16 {
    return @bitCast(truncf(f16, f64, a));
}
