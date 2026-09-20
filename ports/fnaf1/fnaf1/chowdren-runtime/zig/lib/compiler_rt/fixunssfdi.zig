const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_f2ulz, "__aeabi_f2ulz");
    } else {
        if (compiler_rt.want_windows_arm_abi) {
            symbol(&__fixunssfdi, "__stou64");
        }
        symbol(&__fixunssfdi, "__fixunssfdi");
    }
}

pub fn __fixunssfdi(a: f32) callconv(.c) u64 {
    return intFromFloat(u64, a);
}

fn __aeabi_f2ulz(a: f32) callconv(.{ .arm_aapcs = .{} }) u64 {
    return intFromFloat(u64, a);
}
