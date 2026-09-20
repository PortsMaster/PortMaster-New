const compiler_rt = @import("../compiler_rt.zig");
const floatFromInt = @import("./float_from_int.zig").floatFromInt;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__floatuntitf_windows_x86_64, "__floatuntitf");
    } else {
        if (compiler_rt.want_ppc_abi)
            symbol(&__floatuntitf, "__floatuntikf");
        symbol(&__floatuntitf, "__floatuntitf");
    }
}

pub fn __floatuntitf(a: u128) callconv(.c) f128 {
    return floatFromInt(f128, a);
}

fn __floatuntitf_windows_x86_64(a: @Vector(2, u64)) callconv(.c) f128 {
    return floatFromInt(f128, @as(u128, @bitCast(a)));
}
