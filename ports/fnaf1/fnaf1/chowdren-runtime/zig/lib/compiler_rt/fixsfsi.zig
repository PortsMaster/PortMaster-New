const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_f2iz, "__aeabi_f2iz");
    } else {
        symbol(&__fixsfsi, "__fixsfsi");
    }
}

pub fn __fixsfsi(a: f32) callconv(.c) i32 {
    return intFromFloat(i32, a);
}

fn __aeabi_f2iz(a: f32) callconv(.{ .arm_aapcs = .{} }) i32 {
    return intFromFloat(i32, a);
}
