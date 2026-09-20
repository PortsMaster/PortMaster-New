const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const divc3 = @import("./divc3.zig");
const Complex = @import("./mulc3.zig").Complex;

comptime {
    if (@import("builtin").zig_backend != .stage2_c) {
        symbol(&__divhc3, "__divhc3");
    }
}

pub fn __divhc3(a: f16, b: f16, c: f16, d: f16) callconv(.c) Complex(f16) {
    return divc3.divc3(f16, a, b, c, d);
}
