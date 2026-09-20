const compiler_rt = @import("../compiler_rt.zig");
const floatFromInt = @import("./float_from_int.zig").floatFromInt;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__floatuntidf_windows_x86_64, "__floatuntidf");
    } else {
        symbol(&__floatuntidf, "__floatuntidf");
    }
}

pub fn __floatuntidf(a: u128) callconv(.c) f64 {
    return floatFromInt(f64, a);
}

fn __floatuntidf_windows_x86_64(a: @Vector(2, u64)) callconv(.c) f64 {
    return floatFromInt(f64, @as(u128, @bitCast(a)));
}
