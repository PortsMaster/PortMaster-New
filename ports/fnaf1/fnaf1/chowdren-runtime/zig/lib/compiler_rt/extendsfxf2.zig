const symbol = @import("../compiler_rt.zig").symbol;
const extend_f80 = @import("./extendf.zig").extend_f80;

comptime {
    symbol(&__extendsfxf2, "__extendsfxf2");
}

fn __extendsfxf2(a: f32) callconv(.c) f80 {
    return extend_f80(f32, @as(u32, @bitCast(a)));
}
