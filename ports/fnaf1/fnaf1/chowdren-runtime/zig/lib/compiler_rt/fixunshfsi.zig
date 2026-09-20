const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const intFromFloat = @import("./int_from_float.zig").intFromFloat;

comptime {
    symbol(&__fixunshfsi, "__fixunshfsi");
}

fn __fixunshfsi(a: f16) callconv(.c) u32 {
    return intFromFloat(u32, a);
}
