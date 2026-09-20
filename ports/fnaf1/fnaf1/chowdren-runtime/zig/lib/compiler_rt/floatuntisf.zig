const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__floatuntisf_windows_x86_64, "__floatuntisf");
    } else {
        symbol(&__floatuntisf, "__floatuntisf");
    }
}

pub fn __floatuntisf(a: u128) callconv(.c) f32 {
    return floatFromInt(f32, a);
}

fn __floatuntisf_windows_x86_64(a: @Vector(2, u64)) callconv(.c) f32 {
    return floatFromInt(f32, @as(u128, @bitCast(a)));
}
