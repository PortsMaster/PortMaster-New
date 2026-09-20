const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;
const floatFromInt = @import("./float_from_int.zig").floatFromInt;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__floattitf_windows_x86_64, "__floattitf");
    } else {
        if (compiler_rt.want_ppc_abi)
            symbol(&__floattitf, "__floattikf");
        symbol(&__floattitf, "__floattitf");
    }
}

pub fn __floattitf(a: i128) callconv(.c) f128 {
    return floatFromInt(f128, a);
}

fn __floattitf_windows_x86_64(a: @Vector(2, u64)) callconv(.c) f128 {
    return floatFromInt(f128, @as(i128, @bitCast(a)));
}
