const std = @import("std");
const builtin = @import("builtin");
const arch = builtin.cpu.arch;
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;

comptime {
    symbol(&__fabsh, "__fabsh");
    symbol(&fabsf, "fabsf");
    symbol(&fabs, "fabs");
    symbol(&__fabsx, "__fabsx");
    if (compiler_rt.want_ppc_abi) {
        symbol(&fabsq, "fabsf128");
    }
    symbol(&fabsq, "fabsq");
    symbol(&fabsl, "fabsl");
}

pub fn __fabsh(a: f16) callconv(.c) f16 {
    return generic_fabs(a);
}

pub fn fabsf(a: f32) callconv(.c) f32 {
    return generic_fabs(a);
}

pub fn fabs(a: f64) callconv(.c) f64 {
    return generic_fabs(a);
}

pub fn __fabsx(a: f80) callconv(.c) f80 {
    return generic_fabs(a);
}

pub fn fabsq(a: f128) callconv(.c) f128 {
    return generic_fabs(a);
}

pub fn fabsl(x: c_longdouble) callconv(.c) c_longdouble {
    switch (@typeInfo(c_longdouble).float.bits) {
        16 => return __fabsh(x),
        32 => return fabsf(x),
        64 => return fabs(x),
        80 => return __fabsx(x),
        128 => return fabsq(x),
        else => @compileError("unreachable"),
    }
}

inline fn generic_fabs(x: anytype) @TypeOf(x) {
    const T = @TypeOf(x);
    const TBits = std.meta.Int(.unsigned, @typeInfo(T).float.bits);
    const float_bits: TBits = @bitCast(x);
    const remove_sign = ~@as(TBits, 0) >> 1;
    return @bitCast(float_bits & remove_sign);
}
