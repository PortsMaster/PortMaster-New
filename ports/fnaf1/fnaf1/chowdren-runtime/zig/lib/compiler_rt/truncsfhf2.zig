const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const truncf = @import("./truncf.zig").truncf;

comptime {
    if (compiler_rt.gnu_f16_abi) {
        symbol(&__gnu_f2h_ieee, "__gnu_f2h_ieee");
    } else if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_f2h, "__aeabi_f2h");
    }
    symbol(&__truncsfhf2, "__truncsfhf2");
}

pub fn __truncsfhf2(a: f32) callconv(.c) compiler_rt.F16T(f32) {
    return @bitCast(truncf(f16, f32, a));
}

fn __gnu_f2h_ieee(a: f32) callconv(.c) compiler_rt.F16T(f32) {
    return @bitCast(truncf(f16, f32, a));
}

fn __aeabi_f2h(a: f32) callconv(.{ .arm_aapcs = .{} }) u16 {
    return @bitCast(truncf(f16, f32, a));
}
