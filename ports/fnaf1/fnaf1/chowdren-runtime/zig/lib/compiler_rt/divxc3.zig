const symbol = @import("../compiler_rt.zig").symbol;
const divc3 = @import("./divc3.zig");
const Complex = @import("./mulc3.zig").Complex;

comptime {
    if (@import("builtin").zig_backend != .stage2_c) {
        symbol(&__divxc3, "__divxc3");
    }
}

pub fn __divxc3(a: f80, b: f80, c: f80, d: f80) callconv(.c) Complex(f80) {
    return divc3.divc3(f80, a, b, c, d);
}
