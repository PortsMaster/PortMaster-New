const symbol = @import("../compiler_rt.zig").symbol;
const divc3 = @import("./divc3.zig");
const Complex = @import("./mulc3.zig").Complex;

comptime {
    if (@import("builtin").zig_backend != .stage2_c) {
        symbol(&__divdc3, "__divdc3");
    }
}

pub fn __divdc3(a: f64, b: f64, c: f64, d: f64) callconv(.c) Complex(f64) {
    return divc3.divc3(f64, a, b, c, d);
}
