const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_d2lz, "__aeabi_d2lz");
    } else {
        if (compiler_rt.want_windows_arm_abi) {
            symbol(&__fixdfdi, "__dtoi64");
        }
        symbol(&__fixdfdi, "__fixdfdi");
    }
}

pub fn __fixdfdi(a: f64) callconv(.c) i64 {
    return intFromFloat(i64, a);
}

fn __aeabi_d2lz(a: f64) callconv(.{ .arm_aapcs = .{} }) i64 {
    return intFromFloat(i64, a);
}
