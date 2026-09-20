const compiler_rt = @import("../compiler_rt.zig");
const floatFromInt = @import("./float_from_int.zig").floatFromInt;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_ul2d, "__aeabi_ul2d");
    } else {
        if (compiler_rt.want_windows_arm_abi) {
            symbol(&__floatundidf, "__u64tod");
        }
        symbol(&__floatundidf, "__floatundidf");
    }
}

pub fn __floatundidf(a: u64) callconv(.c) f64 {
    return floatFromInt(f64, a);
}

fn __aeabi_ul2d(a: u64) callconv(.{ .arm_aapcs = .{} }) f64 {
    return floatFromInt(f64, a);
}
