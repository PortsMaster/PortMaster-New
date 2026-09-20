const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const intFromFloat = @import("./int_from_float.zig").intFromFloat;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__fixunssfti_windows_x86_64, "__fixunssfti");
    } else {
        symbol(&__fixunssfti, "__fixunssfti");
    }
}

pub fn __fixunssfti(a: f32) callconv(.c) u128 {
    return intFromFloat(u128, a);
}

const v2u64 = @Vector(2, u64);

fn __fixunssfti_windows_x86_64(a: f32) callconv(.c) v2u64 {
    return @bitCast(intFromFloat(u128, a));
}
