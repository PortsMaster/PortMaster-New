//! Ported from musl, which is licensed under the MIT license:
//! https://git.musl-libc.org/cgit/musl/tree/COPYRIGHT
//!
//! https://git.musl-libc.org/cgit/musl/tree/src/math/cosf.c
//! https://git.musl-libc.org/cgit/musl/tree/src/math/cos.c
//! https://git.musl-libc.org/cgit/musl/tree/src/math/cosl.c

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
    symbol(&cosh, "__cosh");
    symbol(&cosl, "__cosl");
    symbol(&cosf, "cosf");
    symbol(&cos, "cos");
    symbol(&cosx, "__cosx");
    if (compiler_rt.want_ppc_abi) {
        symbol(&cosq, "cosf128");
    }
    symbol(&cosq, "cosq");
    symbol(&cosl, "cosl");
}

pub fn cosh(a: f16) callconv(.c) f16 {
    // TODO: more efficient implementation
    return @floatCast(cosf(a));
}

pub fn cosf(x: f32) callconv(.c) f32 {
    // Small multiples of pi/2 rounded to double precision.
    const c1pio2: f64 = 1.0 * math.pi / 2.0; // 0x3FF921FB, 0x54442D18
    const c2pio2: f64 = 2.0 * math.pi / 2.0; // 0x400921FB, 0x54442D18
    const c3pio2: f64 = 3.0 * math.pi / 2.0; // 0x4012D97C, 0x7F3321D2
    const c4pio2: f64 = 4.0 * math.pi / 2.0; // 0x401921FB, 0x54442D18

    var ix: u32 = @bitCast(x);
    const sign = ix >> 31 != 0;
    ix &= 0x7fffffff;

    if (ix <= 0x3f490fda) { // |x| ~<= pi/4
        if (ix < 0x39800000) { // |x| < 2**-12
            // raise inexact if x != 0
            if (compiler_rt.want_float_exceptions) mem.doNotOptimizeAway(x + 0x1p120);
            return 1.0;
        }
        return trig.cosdf(x);
    }
    if (ix <= 0x407b53d1) { // |x| ~<= 5*pi/4
        if (ix > 0x4016cbe3) { // |x|  ~> 3*pi/4
            return -trig.cosdf(if (sign) x + c2pio2 else x - c2pio2);
        } else {
            if (sign) {
                return trig.sindf(x + c1pio2);
            } else {
                return trig.sindf(c1pio2 - x);
            }
        }
    }
    if (ix <= 0x40e231d5) { // |x| ~<= 9*pi/4
        if (ix > 0x40afeddf) { // |x| ~> 7*pi/4
            return trig.cosdf(if (sign) x + c4pio2 else x - c4pio2);
        } else {
            if (sign) {
                return trig.sindf(-x - c3pio2);
            } else {
                return trig.sindf(x - c3pio2);
            }
        }
    }

    // cos(Inf or NaN) is NaN
    if (ix >= 0x7f800000) {
        return x - x;
    }

    var y: f64 = undefined;
    const n = rem_pio2f(x, &y);
    return switch (n & 3) {
        0 => trig.cosdf(y),
        1 => trig.sindf(-y),
        2 => -trig.cosdf(y),
        else => trig.sindf(y),
    };
}

pub fn cos(x: f64) callconv(.c) f64 {
    var ix = @as(u64, @bitCast(x)) >> 32;
    ix &= 0x7fffffff;

    // |x| ~< pi/4
    if (ix <= 0x3fe921fb) {
        if (ix < 0x3e46a09e) { // |x| < 2**-27 * sqrt(2)
            // raise inexact if x!=0
            if (compiler_rt.want_float_exceptions) mem.doNotOptimizeAway(x + 0x1p120);
            return 1.0;
        }
        return trig.cos(x, 0);
    }

    // cos(Inf or NaN) is NaN
    if (ix >= 0x7ff00000) {
        return x - x;
    }

    var y: [2]f64 = undefined;
    const n = rem_pio2(x, &y);
    return switch (n & 3) {
        0 => trig.cos(y[0], y[1]),
        1 => -trig.sin(y[0], y[1], 1),
        2 => -trig.cos(y[0], y[1]),
        else => trig.sin(y[0], y[1], 1),
    };
}

pub fn cosx(x: f80) callconv(.c) f80 {
    const se = ld.signExponent(x) & 0x7fff;
    if (se == 0x7fff) {
        return x - x;
    }

    if (@abs(x) < trig.pi_4) {
        if (se < 0x3fff - math.floatMantissaBits(f80)) {
            // raise inexact if x!=0
            return 1.0 + x;
        }
        return trig.cosx(x, 0.0);
    }

    var y: [2]f80 = undefined;
    const n = rem_pio2l(f80, x, &y);
    return switch (n & 3) {
        0 => trig.cosx(y[0], y[1]),
        1 => -trig.sinx(y[0], y[1], 1),
        2 => -trig.cosx(y[0], y[1]),
        else => trig.sinx(y[0], y[1], 1),
    };
}

pub fn cosq(x: f128) callconv(.c) f128 {
    const se = ld.signExponent(x) & 0x7fff;
    if (se == 0x7fff) {
        return x - x;
    }

    if (@abs(x) < trig.pi_4) {
        if (se < 0x3fff - math.floatMantissaBits(f128)) {
            // raise inexact if x!=0
            return 1.0 + x;
        }
        return trig.cosq(x, 0.0);
    }

    var y: [2]f128 = undefined;
    const n = rem_pio2l(f128, x, &y);
    return switch (n & 3) {
        0 => trig.cosq(y[0], y[1]),
        1 => -trig.sinq(y[0], y[1], 1),
        2 => -trig.cosq(y[0], y[1]),
        else => trig.sinq(y[0], y[1], 1),
    };
}

pub fn cosl(x: c_longdouble) callconv(.c) c_longdouble {
    switch (@typeInfo(c_longdouble).float.bits) {
        16 => return cosh(x),
        32 => return cosf(x),
        64 => return cos(x),
        80 => return cosx(x),
        128 => return cosq(x),
        else => @compileError("unreachable"),
    }
}

fn testCosSpecial(comptime T: type) !void {
    const f = switch (T) {
        f32 => cosf,
        f64 => cos,
        f80 => cosx,
        f128 => cosq,
        else => @compileError("unimplemented"),
    };

    try expect(f(0.0) == 1.0);
    try expect(f(-0.0) == 1.0);
    try expect(math.isNan(f(math.inf(T))));
    try expect(math.isNan(f(-math.inf(T))));
    try expect(math.isNan(f(math.nan(T))));
}

test "cos32.normal" {
    const epsilon = math.floatEps(f32);
    try expectApproxEqAbs(@as(f32, 1.0), cosf(0.0), epsilon);
    try expectApproxEqAbs(@as(f32, 0.9800666), cosf(0.2), epsilon);
    try expectApproxEqAbs(@as(f32, 0.6276231), cosf(0.8923), epsilon);
    try expectApproxEqAbs(@as(f32, 0.0707372), cosf(1.5), epsilon);
    try expectApproxEqAbs(@as(f32, 0.0707372), cosf(-1.5), epsilon);
    try expectApproxEqAbs(@as(f32, 0.96913195), cosf(37.45), epsilon);
    try expectApproxEqAbs(@as(f32, 0.40079966), cosf(89.123), epsilon);
}

test "cos32.special" {
    try testCosSpecial(f32);
}

test "cos64.normal" {
    const epsilon = math.floatEps(f64);
    try expectApproxEqAbs(@as(f64, 1.0), cos(0.0), epsilon);
    try expectApproxEqAbs(@as(f64, 0.9800665778412416), cos(0.2), epsilon);
    try expectApproxEqAbs(@as(f64, 0.6276230983360804), cos(0.8923), epsilon);
    try expectApproxEqAbs(@as(f64, 0.0707372016677029), cos(1.5), epsilon);
    try expectApproxEqAbs(@as(f64, 0.0707372016677029), cos(-1.5), epsilon);
    try expectApproxEqAbs(@as(f64, 0.9691317730707778), cos(37.45), epsilon);
    try expectApproxEqAbs(@as(f64, 0.4008006809354791), cos(89.123), epsilon);
}

test "cos64.special" {
    try testCosSpecial(f64);
}

test "cos80.normal" {
    const epsilon = math.floatEps(f80);
    try expectApproxEqAbs(@as(f80, 1.0), cosx(0.0), epsilon);
    try expectApproxEqAbs(@as(f80, 0.98006657784124163112419651674816888), cosx(0.2), epsilon);
    try expectApproxEqAbs(@as(f80, 0.62762309833608037003563995939286067), cosx(0.8923), epsilon);
    try expectApproxEqAbs(@as(f80, 0.070737201667702910088189851434268747), cosx(1.5), epsilon);
    try expectApproxEqAbs(@as(f80, 0.070737201667702910088189851434268747), cosx(-1.5), epsilon);
    try expectApproxEqAbs(@as(f80, 0.9691317730707771246), cosx(37.45), epsilon);
    try expectApproxEqAbs(@as(f80, 0.4008006809354834001), cosx(89.123), epsilon);
}

test "cos80.special" {
    try testCosSpecial(f80);
}

test "cos128.normal" {
    const epsilon = math.floatEps(f128);
    try expectApproxEqAbs(@as(f128, 1.0), cosq(0.0), epsilon);
    try expectApproxEqAbs(@as(f128, 0.98006657784124163112419651674816888), cosq(0.2), epsilon);
    try expectApproxEqAbs(@as(f128, 0.62762309833608037003563995939286067), cosq(0.8923), epsilon);
    try expectApproxEqAbs(@as(f128, 0.070737201667702910088189851434268747), cosq(1.5), epsilon);
    try expectApproxEqAbs(@as(f128, 0.070737201667702910088189851434268747), cosq(-1.5), epsilon);
    try expectApproxEqAbs(@as(f128, 0.96913177307077712443149563847233230), cosq(37.45), epsilon);
    try expectApproxEqAbs(@as(f128, 0.40080068093548339848199454493704702), cosq(89.123), epsilon);
}

test "cos128.special" {
    try testCosSpecial(f128);
}
