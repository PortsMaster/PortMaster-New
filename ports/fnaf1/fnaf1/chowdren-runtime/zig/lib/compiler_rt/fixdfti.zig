const compiler_rt = @import("../compiler_rt.zig");
const intFromFloat = @import("./int_from_float.zig").intFromFloat;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__fixdfti_windows_x86_64, "__fixdfti");
    } else {
        symbol(&__fixdfti, "__fixdfti");
    }
}

pub fn __fixdfti(a: f64) callconv(.c) i128 {
    return intFromFloat(i128, a);
}

const v2u64 = @Vector(2, u64);

fn __fixdfti_windows_x86_64(a: f64) callconv(.c) v2u64 {
    return @bitCast(intFromFloat(i128, a));
}
