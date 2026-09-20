const symbol = @import("../compiler_rt.zig").symbol;
const trunc_f80 = @import("./truncf.zig").trunc_f80;

comptime {
    symbol(&__truncxfdf2, "__truncxfdf2");
}

fn __truncxfdf2(a: f80) callconv(.c) f64 {
    return trunc_f80(f64, a);
}
