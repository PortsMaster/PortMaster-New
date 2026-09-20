const intFromFloat = @import("./int_from_float.zig").intFromFloat;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    symbol(&__fixunsxfdi, "__fixunsxfdi");
}

fn __fixunsxfdi(a: f80) callconv(.c) u64 {
    return intFromFloat(u64, a);
}
