const symbol = @import("../compiler_rt.zig").symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    symbol(&__fixunshfdi, "__fixunshfdi");
}

fn __fixunshfdi(a: f16) callconv(.c) u64 {
    return intFromFloat(u64, a);
}
