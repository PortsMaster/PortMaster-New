const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_ui2d, "__aeabi_ui2d");
    } else {
        symbol(&__floatunsidf, "__floatunsidf");
    }
}

pub fn __floatunsidf(a: u32) callconv(.c) f64 {
    return floatFromInt(f64, a);
}

fn __aeabi_ui2d(a: u32) callconv(.{ .arm_aapcs = .{} }) f64 {
    return floatFromInt(f64, a);
}
