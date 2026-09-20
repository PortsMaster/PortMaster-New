const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;
const trunc_f80 = @import("./truncf.zig").trunc_f80;

comptime {
    symbol(&__truncxfhf2, "__truncxfhf2");
}

fn __truncxfhf2(a: f80) callconv(.c) compiler_rt.F16T(f80) {
    return @bitCast(trunc_f80(f16, a));
}
