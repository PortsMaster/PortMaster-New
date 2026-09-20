const divc3 = @import("./divc3.zig");
const Complex = @import("./mulc3.zig").Complex;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (@import("builtin").zig_backend != .stage2_c) {
        symbol(&__divsc3, "__divsc3");
    }
}

pub fn __divsc3(a: f32, b: f32, c: f32, d: f32) callconv(.c) Complex(f32) {
    return divc3.divc3(f32, a, b, c, d);
}
