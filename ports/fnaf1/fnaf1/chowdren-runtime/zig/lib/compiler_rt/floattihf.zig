const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__floattihf_windows_x86_64, "__floattihf");
    } else {
        symbol(&__floattihf, "__floattihf");
    }
}

pub fn __floattihf(a: i128) callconv(.c) f16 {
    return floatFromInt(f16, a);
}

fn __floattihf_windows_x86_64(a: @Vector(2, u64)) callconv(.c) f16 {
    return floatFromInt(f16, @as(i128, @bitCast(a)));
}
