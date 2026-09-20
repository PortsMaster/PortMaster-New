const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__floatuntixf_windows_x86_64, "__floatuntixf");
    } else {
        symbol(&__floatuntixf, "__floatuntixf");
    }
}

pub fn __floatuntixf(a: u128) callconv(.c) f80 {
    return floatFromInt(f80, a);
}

fn __floatuntixf_windows_x86_64(a: @Vector(2, u64)) callconv(.c) f80 {
    return floatFromInt(f80, @as(u128, @bitCast(a)));
}
