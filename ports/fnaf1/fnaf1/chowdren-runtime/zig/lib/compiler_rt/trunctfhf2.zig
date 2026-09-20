const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;
const truncf = @import("./truncf.zig").truncf;

comptime {
    symbol(&__trunctfhf2, "__trunctfhf2");
}

pub fn __trunctfhf2(a: f128) callconv(.c) compiler_rt.F16T(f128) {
    return @bitCast(truncf(f16, f128, a));
}
