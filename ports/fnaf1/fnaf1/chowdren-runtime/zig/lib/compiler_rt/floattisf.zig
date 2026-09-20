const compiler_rt = @import("../compiler_rt.zig");
const floatFromInt = @import("./float_from_int.zig").floatFromInt;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__floattisf_windows_x86_64, "__floattisf");
    } else {
        symbol(&__floattisf, "__floattisf");
    }
}

pub fn __floattisf(a: i128) callconv(.c) f32 {
    return floatFromInt(f32, a);
}

fn __floattisf_windows_x86_64(a: @Vector(2, u64)) callconv(.c) f32 {
    return floatFromInt(f32, @as(i128, @bitCast(a)));
}
