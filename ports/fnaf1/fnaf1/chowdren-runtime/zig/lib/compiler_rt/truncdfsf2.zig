const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const truncf = @import("./truncf.zig").truncf;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_d2f, "__aeabi_d2f");
    } else {
        symbol(&__truncdfsf2, "__truncdfsf2");
    }
}

pub fn __truncdfsf2(a: f64) callconv(.c) f32 {
    return truncf(f32, f64, a);
}

fn __aeabi_d2f(a: f64) callconv(.{ .arm_aapcs = .{} }) f32 {
    return truncf(f32, f64, a);
}
