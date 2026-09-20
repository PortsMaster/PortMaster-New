const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__fixsfti_windows_x86_64, "__fixsfti");
    } else {
        symbol(&__fixsfti, "__fixsfti");
    }
}

pub fn __fixsfti(a: f32) callconv(.c) i128 {
    return intFromFloat(i128, a);
}

const v2u64 = @Vector(2, u64);

fn __fixsfti_windows_x86_64(a: f32) callconv(.c) v2u64 {
    return @bitCast(intFromFloat(i128, a));
}
