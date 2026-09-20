const compiler_rt = @import("../compiler_rt.zig");
const intFromFloat = @import("./int_from_float.zig").intFromFloat;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__fixunshfti_windows_x86_64, "__fixunshfti");
    } else {
        symbol(&__fixunshfti, "__fixunshfti");
    }
}

pub fn __fixunshfti(a: f16) callconv(.c) u128 {
    return intFromFloat(u128, a);
}

const v2u64 = @Vector(2, u64);

fn __fixunshfti_windows_x86_64(a: f16) callconv(.c) v2u64 {
    return @bitCast(intFromFloat(u128, a));
}
