const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const mulf3 = @import("./mulf3.zig").mulf3;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_fmul, "__aeabi_fmul");
    } else {
        symbol(&__mulsf3, "__mulsf3");
    }
}

pub fn __mulsf3(a: f32, b: f32) callconv(.c) f32 {
    return mulf3(f32, a, b);
}

fn __aeabi_fmul(a: f32, b: f32) callconv(.{ .arm_aapcs = .{} }) f32 {
    return mulf3(f32, a, b);
}
