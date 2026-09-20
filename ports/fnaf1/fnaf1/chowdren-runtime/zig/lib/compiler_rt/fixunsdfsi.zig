const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_d2uiz, "__aeabi_d2uiz");
    } else {
        symbol(&__fixunsdfsi, "__fixunsdfsi");
    }
}

pub fn __fixunsdfsi(a: f64) callconv(.c) u32 {
    return intFromFloat(u32, a);
}

fn __aeabi_d2uiz(a: f64) callconv(.{ .arm_aapcs = .{} }) u32 {
    return intFromFloat(u32, a);
}
