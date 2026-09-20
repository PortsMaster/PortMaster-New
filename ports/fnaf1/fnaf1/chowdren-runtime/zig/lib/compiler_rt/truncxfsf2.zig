const trunc_f80 = @import("./truncf.zig").trunc_f80;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    symbol(&__truncxfsf2, "__truncxfsf2");
}

fn __truncxfsf2(a: f80) callconv(.c) f32 {
    return trunc_f80(f32, a);
}
