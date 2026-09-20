const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;
const mulf3 = @import("./mulf3.zig").mulf3;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_dmul, "__aeabi_dmul");
    } else {
        symbol(&__muldf3, "__muldf3");
    }
}

pub fn __muldf3(a: f64, b: f64) callconv(.c) f64 {
    return mulf3(f64, a, b);
}

fn __aeabi_dmul(a: f64, b: f64) callconv(.{ .arm_aapcs = .{} }) f64 {
    return mulf3(f64, a, b);
}
