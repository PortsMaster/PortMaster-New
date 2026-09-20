const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_f2uiz, "__aeabi_f2uiz");
    } else {
        symbol(&__fixunssfsi, "__fixunssfsi");
    }
}

pub fn __fixunssfsi(a: f32) callconv(.c) u32 {
    return intFromFloat(u32, a);
}

fn __aeabi_f2uiz(a: f32) callconv(.{ .arm_aapcs = .{} }) u32 {
    return intFromFloat(u32, a);
}
