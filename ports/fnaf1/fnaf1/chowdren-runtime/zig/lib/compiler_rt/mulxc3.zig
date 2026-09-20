const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const mulc3 = @import("./mulc3.zig");

comptime {
    if (@import("builtin").zig_backend != .stage2_c) {
        symbol(&__mulxc3, "__mulxc3");
    }
}

pub fn __mulxc3(a: f80, b: f80, c: f80, d: f80) callconv(.c) mulc3.Complex(f80) {
    return mulc3.mulc3(f80, a, b, c, d);
}
