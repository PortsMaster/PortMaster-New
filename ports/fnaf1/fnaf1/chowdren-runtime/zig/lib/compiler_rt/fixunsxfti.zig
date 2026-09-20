const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__fixunsxfti_windows_x86_64, "__fixunsxfti");
    } else {
        symbol(&__fixunsxfti, "__fixunsxfti");
    }
}

pub fn __fixunsxfti(a: f80) callconv(.c) u128 {
    return intFromFloat(u128, a);
}

const v2u64 = @Vector(2, u64);

fn __fixunsxfti_windows_x86_64(a: f80) callconv(.c) v2u64 {
    return @bitCast(intFromFloat(u128, a));
}
