const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    if (compiler_rt.want_windows_v2u64_abi) {
        symbol(&__fixunsdfti_windows_x86_64, "__fixunsdfti");
    } else {
        symbol(&__fixunsdfti, "__fixunsdfti");
    }
}

pub fn __fixunsdfti(a: f64) callconv(.c) u128 {
    return intFromFloat(u128, a);
}

const v2u64 = @Vector(2, u64);

fn __fixunsdfti_windows_x86_64(a: f64) callconv(.c) v2u64 {
    return @bitCast(intFromFloat(u128, a));
}
