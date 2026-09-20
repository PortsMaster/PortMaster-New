const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_i2f, "__aeabi_i2f");
    } else {
        symbol(&__floatsisf, "__floatsisf");
    }
}

pub fn __floatsisf(a: i32) callconv(.c) f32 {
    return floatFromInt(f32, a);
}

fn __aeabi_i2f(a: i32) callconv(.{ .arm_aapcs = .{} }) f32 {
    return floatFromInt(f32, a);
}
