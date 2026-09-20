const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__fixunstfti_windows_x86_64, "__fixunstfti");
    } else {
        if (compiler_rt.want_ppc_abi)
            symbol(&__fixunstfti, "__fixunskfti");
        symbol(&__fixunstfti, "__fixunstfti");
    }
}

pub fn __fixunstfti(a: f128) callconv(.c) u128 {
    return intFromFloat(u128, a);
}

const v2u64 = @Vector(2, u64);

fn __fixunstfti_windows_x86_64(a: f128) callconv(.c) v2u64 {
    return @bitCast(intFromFloat(u128, a));
}
