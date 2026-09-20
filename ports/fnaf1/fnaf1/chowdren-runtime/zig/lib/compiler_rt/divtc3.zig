const compiler_rt = @import("../compiler_rt.zig");
const divc3 = @import("./divc3.zig");
const Complex = @import("./mulc3.zig").Complex;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (@import("builtin").zig_backend != .stage2_c) {
        if (compiler_rt.want_ppc_abi)
            symbol(&__divtc3, "__divkc3");
        symbol(&__divtc3, "__divtc3");
    }
}

pub fn __divtc3(a: f128, b: f128, c: f128, d: f128) callconv(.c) Complex(f128) {
    return divc3.divc3(f128, a, b, c, d);
}
