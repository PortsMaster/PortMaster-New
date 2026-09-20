const compiler_rt = @import("../compiler_rt.zig");
const intFromFloat = @import("./int_from_float.zig").intFromFloat;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__fixtfti_windows_x86_64, "__fixtfti");
    } else {
        if (compiler_rt.want_ppc_abi)
            symbol(&__fixtfti, "__fixkfti");
        symbol(&__fixtfti, "__fixtfti");
    }
}

pub fn __fixtfti(a: f128) callconv(.c) i128 {
    return intFromFloat(i128, a);
}

const v2u64 = @Vector(2, u64);

fn __fixtfti_windows_x86_64(a: f128) callconv(.c) v2u64 {
    return @bitCast(intFromFloat(i128, a));
}
