const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__floatuntihf_windows_x86_64, "__floatuntihf");
    } else {
        symbol(&__floatuntihf, "__floatuntihf");
    }
}

pub fn __floatuntihf(a: u128) callconv(.c) f16 {
    return floatFromInt(f16, a);
}

fn __floatuntihf_windows_x86_64(a: @Vector(2, u64)) callconv(.c) f16 {
    return floatFromInt(f16, @as(u128, @bitCast(a)));
}
