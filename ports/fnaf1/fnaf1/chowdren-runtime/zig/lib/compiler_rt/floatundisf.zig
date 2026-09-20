const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_ul2f, "__aeabi_ul2f");
    } else {
        if (compiler_rt.want_windows_arm_abi) {
            symbol(&__floatundisf, "__u64tos");
        }
        symbol(&__floatundisf, "__floatundisf");
    }
}

pub fn __floatundisf(a: u64) callconv(.c) f32 {
    return floatFromInt(f32, a);
}

fn __aeabi_ul2f(a: u64) callconv(.{ .arm_aapcs = .{} }) f32 {
    return floatFromInt(f32, a);
}
