const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_l2d, "__aeabi_l2d");
    } else {
        if (compiler_rt.want_windows_arm_abi) {
            symbol(&__floatdidf, "__i64tod");
        }
        symbol(&__floatdidf, "__floatdidf");
    }
}

pub fn __floatdidf(a: i64) callconv(.c) f64 {
    return floatFromInt(f64, a);
}

fn __aeabi_l2d(a: i64) callconv(.{ .arm_aapcs = .{} }) f64 {
    return floatFromInt(f64, a);
}
