const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__floattixf_windows_x86_64, "__floattixf");
    } else {
        symbol(&__floattixf, "__floattixf");
    }
}

pub fn __floattixf(a: i128) callconv(.c) f80 {
    return floatFromInt(f80, a);
}

fn __floattixf_windows_x86_64(a: @Vector(2, u64)) callconv(.c) f80 {
    return floatFromInt(f80, @as(i128, @bitCast(a)));
}
