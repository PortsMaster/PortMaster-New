const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;
const mulc3 = @import("./mulc3.zig");

comptime {
    if (@import("builtin").zig_backend != .stage2_c) {
        if (compiler_rt.want_ppc_abi)
            symbol(&__multc3, "__mulkc3");
        symbol(&__multc3, "__multc3");
    }
}

pub fn __multc3(a: f128, b: f128, c: f128, d: f128) callconv(.c) mulc3.Complex(f128) {
    return mulc3.mulc3(f128, a, b, c, d);
}
