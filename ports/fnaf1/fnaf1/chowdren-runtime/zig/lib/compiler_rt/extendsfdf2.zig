const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const extendf = @import("./extendf.zig").extendf;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_f2d, "__aeabi_f2d");
    } else {
        symbol(&__extendsfdf2, "__extendsfdf2");
    }
}

fn __extendsfdf2(a: f32) callconv(.c) f64 {
    return extendf(f64, f32, @as(u32, @bitCast(a)));
}

fn __aeabi_f2d(a: f32) callconv(.{ .arm_aapcs = .{} }) f64 {
    return extendf(f64, f32, @as(u32, @bitCast(a)));
}
