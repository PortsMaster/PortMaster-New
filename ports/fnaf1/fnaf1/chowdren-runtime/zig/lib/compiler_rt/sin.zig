//! Ported from musl, which is licensed under the MIT license:
//! https://git.musl-libc.org/cgit/musl/tree/COPYRIGHT
//!
//! https://git.musl-libc.org/cgit/musl/tree/src/math/sinf.c
//! https://git.musl-libc.org/cgit/musl/tree/src/math/sin.c
//! https://git.musl-libc.org/cgit/musl/tree/src/math/sinl.c

const std = @import("std");
const math = std.math;
const mem = std.mem;
const expect = std.testing.expect;
const expectApproxEqAbs = std.testing.expectApproxEqAbs;

const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;
const trig = @import("trig.zig");
const rem_pio2 = @import("rem_pio2.zig").rem_pio2;
const rem_pio2f = @import("rem_pio2f.zig").rem_pio2f;
const rem_pio2l = @import("rem_pio2l.zig").rem_pio2l;
const ld = @import("long_double.zig");

comptime {
    symbol(&sinh, "__sinh");
    symbol(&sinl, "__sinl");
    symbol(&sinf, "sinf");
    symbol(&sin, "sin");
    symbol(&sinx, "__sinx");
    if (compiler_rt.want_ppc_abi) {
        symbol(&sinq, "sinf128");
    }
    symbol(&sinq, "sinq");
    symbol(&sinl, "sinl");
}

pub fn sinh(x: f16) callconv(.c) f16 {
    // TODO: more efficient implementation
    return @floatCast(sinf(x));
}

pub fn sinf(x: f32) callconv(.c) f32 {
    // Small multiples of pi/2 rounded to double precision.
    const s1pio2: f64 = 1.0 * math.pi / 2.0; // 0x3FF921FB, 0x54442D18
    const s2pio2: f64 = 2.0 * math.pi / 2.0; // 0x400921FB, 0x54442D18
    const s3pio2: f64 = 3.0 * math.pi / 2.0; // 0x4012D97C, 0x7F3321D2
    const s4pio2: f64 = 4.0 * math.pi / 2.0; // 0x401921FB, 0x54442D18

    var ix: u32 = @bitCast(x);
    const sign = ix >> 31 != 0;
    ix &= 0x7fffffff;

    if (ix <= 0x3f490fda) { // |x| ~<= pi/4
        if (ix < 0x39800000) { // |x| < 2**-12
            // raise inexact if x!=0 and underflow if subnormal
            if (compiler_rt.want_float_exceptions) {
                if (ix < 0x00800000) {
                    mem.doNotOptimizeAway(x / 0x1p120);
                } else {
                    mem.doNotOptimizeAway(x + 0x1p120);
                }
            }
            return x;
        }
        return trig.sindf(x);
    }
    if (ix <= 0x407b53d1) { // |x| ~<= 5*pi/4
        if (ix <= 0x4016cbe3) { // |x| ~<= 3pi/4
            if (sign) {
                return -trig.cosdf(x + s1pio2);
            } else {
                return trig.cosdf(x - s1pio2);
            }
        }
        return trig.sindf(if (sign) -(x + s2pio2) else -(x - s2pio2));
    }
    if (ix <= 0x40e231d5) { // |x| ~<= 9*pi/4
        if (ix <= 0x40afeddf) { // |x| ~<= 7*pi/4
            if (sign) {
                return trig.cosdf(x + s3pio2);
            } else {
                return -trig.cosdf(x - s3pio2);
            }
        }
        return trig.sindf(if (sign) x + s4pio2 else x - s4pio2);
    }

    // sin(Inf or NaN) is NaN
    if (ix >= 0x7f800000) {
        return x - x;
    }

    var y: f64 = undefined;
    const n = rem_pio2f(x, &y);
    return switch (n & 3) {
        0 => trig.sindf(y),
        1 => trig.cosdf(y),
        2 => trig.sindf(-y),
        else => -trig.cosdf(y),
    };
}

pub fn sin(x: f64) callconv(.c) f64 {
    var ix = @as(u64, @bitCast(x)) >> 32;
    ix &= 0x7fffffff;

    // |x| ~< pi/4
    if (ix <= 0x3fe921fb) {
        if (ix < 0x3e500000) { // |x| < 2**-26
            // raise inexact if x != 0 and underflow if subnormal
            if (compiler_rt.want_float_exceptions) {
                if (ix < 0x00100000) {
                    mem.doNotOptimizeAway(x / 0x1p120);
                } else {
                    mem.doNotOptimizeAway(x + 0x1p120);
                }
            }
            return x;
        }
        return trig.sin(x, 0.0, 0);
    }

    // sin(Inf or NaN) is NaN
    if (ix >= 0x7ff00000) {
        return x - x;
    }

    var y: [2]f64 = undefined;
    const n = rem_pio2(x, &y);
    return switch (n & 3) {
        0 => trig.sin(y[0], y[1], 1),
        1 => trig.cos(y[0], y[1]),
        2 => -trig.sin(y[0], y[1], 1),
        else => -trig.cos(y[0], y[1]),
    };
}

fn sinx(x: f80) callconv(.c) f80 {
    const se = ld.signExponent(x) & 0x7fff;
    if (se == 0x7fff) {
        return x - x;
    }

    if (@abs(x) < trig.pi_4) {
        if (se < 0x3fff - (math.floatMantissaBits(f80) / 2)) {
            // raise inexact if x!=0 and underflow if subnormal
            if (compiler_rt.want_float_exceptions) {
                mem.doNotOptimizeAway(if (se == 0) x * 0x1p-120 else x + 0x1p120);
            }
            return x;
        }
        return trig.sinx(x, 0.0, 0);
    }

    var y: [2]f80 = undefined;
    const n = rem_pio2l(f80, x, &y);
    return switch (n & 3) {
        0 => trig.sinx(y[0], y[1], 1),
        1 => trig.cosx(y[0], y[1]),
        2 => -trig.sinx(y[0], y[1], 1),
        else => -trig.cosx(y[0], y[1]),
    };
}

pub fn sinq(x: f128) callconv(.c) f128 {
    const se = ld.signExponent(x) & 0x7fff;
    if (se == 0x7fff) {
        return x - x;
    }

    if (@abs(x) < trig.pi_4) {
        if (se < 0x3fff - (math.floatMantissaBits(f128) / 2)) {
            // raise inexact if x!=0 and underflow if subnormal
            if (compiler_rt.want_float_exceptions) {
                mem.doNotOptimizeAway(if (se == 0) x * 0x1p-120 else x + 0x1p120);
            }
            return x;
        }
        return trig.sinq(x, 0.0, 0);
    }

    var y: [2]f128 = undefined;
    const n = rem_pio2l(f128, x, &y);
    return switch (n & 3) {
        0 => trig.sinq(y[0], y[1], 1),
        1 => trig.cosq(y[0], y[1]),
        2 => -trig.sinq(y[0], y[1], 1),
        else => -trig.cosq(y[0], y[1]),
    };
}

pub fn sinl(x: c_longdouble) callconv(.c) c_longdouble {
    switch (@typeInfo(c_longdouble).float.bits) {
        16 => return sinh(x),
        32 => return sinf(x),
        64 => return sin(x),
        80 => return sinx(x),
        128 => return sinq(x),
        else => @compileError("unreachable"),
    }
}

fn testSinSpecial(comptime T: type) !void {
    const f = switch (T) {
        f32 => sinf,
        f64 => sin,
        f80 => sinx,
        f128 => sinq,
        else => @compileError("unimplemented"),
    };

    try expect(math.isPositiveZero(f(0.0)));
    try expect(math.isNegativeZero(f(-0.0)));
    try expect(math.isNan(f(math.inf(T))));
    try expect(math.isNan(f(-math.inf(T))));
    try expect(math.isNan(f(math.nan(T))));
}

test "sin32.normal" {
    const epsilon = math.floatEps(f32);
    try expectApproxEqAbs(@as(f32, 0.0), sinf(0.0), epsilon);
    try expectApproxEqAbs(@as(f32, 0.19866933), sinf(0.2), epsilon);
    try expectApproxEqAbs(@as(f32, 0.77851737), sinf(0.8923), epsilon);
    try expectApproxEqAbs(@as(f32, 0.997495), sinf(1.5), epsilon);
    try expectApproxEqAbs(@as(f32, -0.997495), sinf(-1.5), epsilon);
    try expectApproxEqAbs(@as(f32, -0.24654257), sinf(37.45), epsilon);
    try expectApproxEqAbs(@as(f32, 0.9161657), sinf(89.123), epsilon);
}

test "sin32.special" {
    try testSinSpecial(f32);
}

test "sin64.normal" {
    const epsilon = math.floatEps(f64);
    try expectApproxEqAbs(@as(f64, 0.0), sin(0.0), epsilon);
    try expectApproxEqAbs(@as(f64, 0.19866933079506122), sin(0.2), epsilon);
    try expectApproxEqAbs(@as(f64, 0.7785173385577349), sin(0.8923), epsilon);
    try expectApproxEqAbs(@as(f64, 0.9974949866040544), sin(1.5), epsilon);
    try expectApproxEqAbs(@as(f64, -0.9974949866040544), sin(-1.5), epsilon);
    try expectApproxEqAbs(@as(f64, -0.24654331551411082), sin(37.45), epsilon);
    try expectApproxEqAbs(@as(f64, 0.9161652766622714), sin(89.123), epsilon);
}

test "sin64.special" {
    try testSinSpecial(f64);
}

test "sin80.normal" {
    const epsilon = math.floatEps(f80);
    try expectApproxEqAbs(@as(f80, 0.0), sinx(0.0), epsilon);
    try expectApproxEqAbs(@as(f80, 0.19866933079506121545941262711838975), sinx(0.2), epsilon);
    try expectApproxEqAbs(@as(f80, 0.77851733855773487830689285621486050), sinx(0.8923), epsilon);
    try expectApproxEqAbs(@as(f80, 0.99749498660405443094172337114148732), sinx(1.5), epsilon);
    try expectApproxEqAbs(@as(f80, -0.99749498660405443094172337114148732), sinx(-1.5), epsilon);
    try expectApproxEqAbs(@as(f80, -0.24654331551411356504), sinx(37.45), epsilon);
    try expectApproxEqAbs(@as(f80, 0.91616527666226951006), sinx(89.123), epsilon);
}

test "sin80.special" {
    try testSinSpecial(f80);
}

test "sin128.normal" {
    const epsilon = math.floatEps(f128);
    try expectApproxEqAbs(@as(f128, 0.0), sinq(0.0), epsilon);
    try expectApproxEqAbs(@as(f128, 0.19866933079506121545941262711838975), sinq(0.2), epsilon);
    try expectApproxEqAbs(@as(f128, 0.77851733855773487830689285621486050), sinq(0.8923), epsilon);
    try expectApproxEqAbs(@as(f128, 0.99749498660405443094172337114148732), sinq(1.5), epsilon);
    try expectApproxEqAbs(@as(f128, -0.99749498660405443094172337114148732), sinq(-1.5), epsilon);
    try expectApproxEqAbs(@as(f128, -0.24654331551411356571238581321661085), sinq(37.45), epsilon);
    try expectApproxEqAbs(@as(f128, 0.91616527666226951075019849560482170), sinq(89.123), epsilon);
}

test "sin128.special" {
    try testSinSpecial(f128);
}

test "sin32 #9901" {
    const float: f32 = @bitCast(@as(u32, 0b11100011111111110000000000000000));
    _ = sinf(float);
}

test "sin64 #9901" {
    const float: f64 = @bitCast(@as(u64, 0b1111111101000001000000001111110111111111100000000000000000000001));
    _ = sin(float);
}
