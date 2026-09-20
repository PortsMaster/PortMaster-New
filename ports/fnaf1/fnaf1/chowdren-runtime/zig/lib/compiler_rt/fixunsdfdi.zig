const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_d2ulz, "__aeabi_d2ulz");
    } else {
        if (compiler_rt.want_windows_arm_abi) {
            symbol(&__fixunsdfdi, "__dtou64");
        }
        symbol(&__fixunsdfdi, "__fixunsdfdi");
    }
}

pub fn __fixunsdfdi(a: f64) callconv(.c) u64 {
    return intFromFloat(u64, a);
}

fn __aeabi_d2ulz(a: f64) callconv(.{ .arm_aapcs = .{} }) u64 {
    return intFromFloat(u64, a);
}
