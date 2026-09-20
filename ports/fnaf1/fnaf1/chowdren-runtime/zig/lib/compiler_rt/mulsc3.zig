const symbol = @import("../compiler_rt.zig").symbol;
const mulc3 = @import("./mulc3.zig");

comptime {
    if (@import("builtin").zig_backend != .stage2_c) {
        symbol(&__mulsc3, "__mulsc3");
    }
}

pub fn __mulsc3(a: f32, b: f32, c: f32, d: f32) callconv(.c) mulc3.Complex(f32) {
    return mulc3.mulc3(f32, a, b, c, d);
}
