const mulc3 = @import("./mulc3.zig");
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (@import("builtin").zig_backend != .stage2_c) {
        symbol(&__muldc3, "__muldc3");
    }
}

pub fn __muldc3(a: f64, b: f64, c: f64, d: f64) callconv(.c) mulc3.Complex(f64) {
    return mulc3.mulc3(f64, a, b, c, d);
}
