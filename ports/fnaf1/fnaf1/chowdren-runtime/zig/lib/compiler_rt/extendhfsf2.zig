const compiler_rt = @import("../compiler_rt.zig");
const extendf = @import("./extendf.zig").extendf;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.gnu_f16_abi) {
        symbol(&__gnu_h2f_ieee, "__gnu_h2f_ieee");
    } else if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_h2f, "__aeabi_h2f");
    }
    symbol(&__extendhfsf2, "__extendhfsf2");
}

pub fn __extendhfsf2(a: compiler_rt.F16T(f32)) callconv(.c) f32 {
    return extendf(f32, f16, @as(u16, @bitCast(a)));
}

fn __gnu_h2f_ieee(a: compiler_rt.F16T(f32)) callconv(.c) f32 {
    return extendf(f32, f16, @as(u16, @bitCast(a)));
}

fn __aeabi_h2f(a: u16) callconv(.{ .arm_aapcs = .{} }) f32 {
    return extendf(f32, f16, @as(u16, @bitCast(a)));
}
