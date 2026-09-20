const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__floattidf_windows_x86_64, "__floattidf");
    } else {
        symbol(&__floattidf, "__floattidf");
    }
}

pub fn __floattidf(a: i128) callconv(.c) f64 {
    return floatFromInt(f64, a);
}

fn __floattidf_windows_x86_64(a: @Vector(2, u64)) callconv(.c) f64 {
    return floatFromInt(f64, @as(i128, @bitCast(a)));
}
