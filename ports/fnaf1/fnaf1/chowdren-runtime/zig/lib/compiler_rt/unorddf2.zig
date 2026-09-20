const compiler_rt = @import("../compiler_rt.zig");
const comparef = @import("./comparef.zig");
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_dcmpun, "__aeabi_dcmpun");
    } else {
        symbol(&__unorddf2, "__unorddf2");
    }
}

pub fn __unorddf2(a: f64, b: f64) callconv(.c) i32 {
    return comparef.unordcmp(f64, a, b);
}

fn __aeabi_dcmpun(a: f64, b: f64) callconv(.{ .arm_aapcs = .{} }) i32 {
    return comparef.unordcmp(f64, a, b);
}
