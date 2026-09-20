const std = @import("std");
const builtin = @import("builtin");
const arch = builtin.cpu.arch;
const math = std.math;
const mem = std.mem;
const expect = std.testing.expect;
const expectApproxEqAbs = std.testing.expectApproxEqAbs;
const trig = @import("trig.zig");
const rem_pio2 = @import("rem_pio2.zig").rem_pio2;
const rem_pio2f = @import("rem_pio2f.zig").rem_pio2f;
const rem_pio2l = @import("rem_pio2l.zig").rem_pio2l;
const ld = @import("long_double.zig");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;

comptime {
    symbol(&sincosh, "__sincosh");
    symbol(&sincosf, "sincosf");
    symbol(&sincos, "sincos");
    symbol(&sincosx, "__sincosx");
    if (compiler_rt.want_ppc_abi) {
        symbol(&sincosq, "sincosf128");
    }
    symbol(&sincosq, "sincosq");
    symbol(&sincosl, "sincosl");
}

pub fn sincosh(x: f16, r_sin: *f16, r_cos: *f16) callconv(.c) void {
    // TODO: more efficient implementation
    var big_sin: f32 = undefined;
    var big_cos: f32 = undefined;
    sincosf(x, &big_sin, &big_cos);
    r_sin.* = @as(f16, @floatCast(big_sin));
    r_cos.* = @as(f16, @floatCast(big_cos));
}

pub fn sincosf(x: f32, r_sin: *f32, r_cos: *f32) callconv(.c) void {
    const sc1pio2: f64 = 1.0 * math.pi / 2.0; // 0x3FF921FB, 0x54442D18
    const sc2pio2: f64 = 2.0 * math.pi / 2.0; // 0x400921FB, 0x54442D18
    const sc3pio2: f64 = 3.0 * math.pi / 2.0; // 0x4012D97C, 0x7F3321D2
    const sc4pio2: f64 = 4.0 * math.pi / 2.0; // 0x401921FB, 0x54442D18

    const pre_ix = @as(u32, @bitCast(x));
    const sign = pre_ix >> 31 != 0;
    const ix = pre_ix & 0x7fffffff;

    // |x| ~<= pi/4
    if (ix <= 0x3f490fda) {
        // |x| < 2**-12
        if (ix < 0x39800000) {
            // raise inexact if x!=0 and underflow if subnormal
            if (compiler_rt.want_float_exceptions) {
                if (ix < 0x00100000) {
                    mem.doNotOptimizeAway(x / 0x1p120);
                } else {
                    mem.doNotOptimizeAway(x + 0x1p120);
                }
            }
            r_sin.* = x;
            r_cos.* = 1.0;
            return;
        }
        r_sin.* = trig.sindf(x);
        r_cos.* = trig.cosdf(x);
        return;
    }

    // |x| ~<= 5*pi/4
    if (ix <= 0x407b53d1) {
        // |x| ~<= 3pi/4
        if (ix <= 0x4016cbe3) {
            if (sign) {
                r_sin.* = -trig.cosdf(x + sc1pio2);
                r_cos.* = trig.sindf(x + sc1pio2);
            } else {
                r_sin.* = trig.cosdf(sc1pio2 - x);
                r_cos.* = trig.sindf(sc1pio2 - x);
            }
            return;
        }
        //  -sin(x+c) is not correct if x+c could be 0: -0 vs +0
        r_sin.* = -trig.sindf(if (sign) x + sc2pio2 else x - sc2pio2);
        r_cos.* = -trig.cosdf(if (sign) x + sc2pio2 else x - sc2pio2);
        return;
    }

    // |x| ~<= 9*pi/4
    if (ix <= 0x40e231d5) {
        // |x| ~<= 7*pi/4
        if (ix <= 0x40afeddf) {
            if (sign) {
                r_sin.* = trig.cosdf(x + sc3pio2);
                r_cos.* = -trig.sindf(x + sc3pio2);
            } else {
                r_sin.* = -trig.cosdf(x - sc3pio2);
                r_cos.* = trig.sindf(x - sc3pio2);
            }
            return;
        }
        r_sin.* = trig.sindf(if (sign) x + sc4pio2 else x - sc4pio2);
        r_cos.* = trig.cosdf(if (sign) x + sc4pio2 else x - sc4pio2);
        return;
    }

    // sin(Inf or NaN) is NaN
    if (ix >= 0x7f800000) {
        const result = x - x;
        r_sin.* = result;
        r_cos.* = result;
        return;
    }

    // general argument reduction needed
    var y: f64 = undefined;
    const n = rem_pio2f(x, &y);
    const s = trig.sindf(y);
    const c = trig.cosdf(y);
    switch (n & 3) {
        0 => {
            r_sin.* = s;
            r_cos.* = c;
        },
        1 => {
            r_sin.* = c;
            r_cos.* = -s;
        },
        2 => {
            r_sin.* = -s;
            r_cos.* = -c;
        },
        else => {
            r_sin.* = -c;
            r_cos.* = s;
        },
    }
}

pub fn sincos(x: f64, r_sin: *f64, r_cos: *f64) callconv(.c) void {
    const ix = @as(u32, @truncate(@as(u64, @bitCast(x)) >> 32)) & 0x7fffffff;

    // |x| ~< pi/4
    if (ix <= 0x3fe921fb) {
        // if |x| < 2**-27 * sqrt(2)
        if (ix < 0x3e46a09e) {
            // raise inexact if x != 0 and underflow if subnormal
            if (compiler_rt.want_float_exceptions) {
                if (ix < 0x00100000) {
                    mem.doNotOptimizeAway(x / 0x1p120);
                } else {
                    mem.doNotOptimizeAway(x + 0x1p120);
                }
            }
            r_sin.* = x;
            r_cos.* = 1.0;
            return;
        }
        r_sin.* = trig.sin(x, 0.0, 0);
        r_cos.* = trig.cos(x, 0.0);
        return;
    }

    // sincos(Inf or NaN) is NaN
    if (ix >= 0x7ff00000) {
        const result = x - x;
        r_sin.* = result;
        r_cos.* = result;
        return;
    }

    // argument reduction needed
    var y: [2]f64 = undefined;
    const n = rem_pio2(x, &y);
    const s = trig.sin(y[0], y[1], 1);
    const c = trig.cos(y[0], y[1]);
    switch (n & 3) {
        0 => {
            r_sin.* = s;
            r_cos.* = c;
        },
        1 => {
            r_sin.* = c;
            r_cos.* = -s;
        },
        2 => {
            r_sin.* = -s;
            r_cos.* = -c;
        },
        else => {
            r_sin.* = -c;
            r_cos.* = s;
        },
    }
}

pub fn sincosx(x: f80, r_sin: *f80, r_cos: *f80) callconv(.c) void {
    const se = ld.signExponent(x) & 0x7fff;
    if (se == 0x7fff) {
        const result = x - x;
        r_sin.* = result;
        r_cos.* = result;
        return;
    }

    if (@abs(x) < trig.pi_4) {
        if (se < 0x3fff - math.floatMantissaBits(f80)) {
            // raise underflow if subnormal
            if (compiler_rt.want_float_exceptions and se == 0) {
                mem.doNotOptimizeAway(x * 0x1p-120);
            }
            r_sin.* = x;
            // raise inexact if x!=0
            r_cos.* = 1.0 + x;
            return;
        }
        r_sin.* = trig.sinx(x, 0.0, 0);
        r_cos.* = trig.cosx(x, 0.0);
        return;
    }

    var y: [2]f80 = undefined;
    const n = rem_pio2l(f80, x, &y);
    const s = trig.sinx(y[0], y[1], 1);
    const c = trig.cosx(y[0], y[1]);
    switch (n & 3) {
        0 => {
            r_sin.* = s;
            r_cos.* = c;
        },
        1 => {
            r_sin.* = c;
            r_cos.* = -s;
        },
        2 => {
            r_sin.* = -s;
            r_cos.* = -c;
        },
        else => {
            r_sin.* = -c;
            r_cos.* = s;
        },
    }
}

pub fn sincosq(x: f128, r_sin: *f128, r_cos: *f128) callconv(.c) void {
    const se = ld.signExponent(x) & 0x7fff;
    if (se == 0x7fff) {
        const result = x - x;
        r_sin.* = result;
        r_cos.* = result;
        return;
    }

    if (@abs(x) < trig.pi_4) {
        if (se < 0x3fff - math.floatMantissaBits(f128)) {
            // raise underflow if subnormal
            if (compiler_rt.want_float_exceptions and se == 0) {
                mem.doNotOptimizeAway(x * 0x1p-120);
            }
            r_sin.* = x;
            // raise inexact if x!=0
            r_cos.* = 1.0 + x;
            return;
        }
        r_sin.* = trig.sinq(x, 0.0, 0);
        r_cos.* = trig.cosq(x, 0.0);
        return;
    }

    var y: [2]f128 = undefined;
    const n = rem_pio2l(f128, x, &y);
    const s = trig.sinq(y[0], y[1], 1);
    const c = trig.cosq(y[0], y[1]);
    switch (n & 3) {
        0 => {
            r_sin.* = s;
            r_cos.* = c;
        },
        1 => {
            r_sin.* = c;
            r_cos.* = -s;
        },
        2 => {
            r_sin.* = -s;
            r_cos.* = -c;
        },
        else => {
            r_sin.* = -c;
            r_cos.* = s;
        },
    }
}

pub fn sincosl(x: c_longdouble, r_sin: *c_longdouble, r_cos: *c_longdouble) callconv(.c) void {
    switch (@typeInfo(c_longdouble).float.bits) {
        16 => return sincosh(x, r_sin, r_cos),
        32 => return sincosf(x, r_sin, r_cos),
        64 => return sincos(x, r_sin, r_cos),
        80 => return sincosx(x, r_sin, r_cos),
        128 => return sincosq(x, r_sin, r_cos),
        else => @compileError("unreachable"),
    }
}

fn testSincosSpecial(comptime T: type) !void {
    const f = switch (T) {
        f32 => sincosf,
        f64 => sincos,
        f80 => sincosx,
        f128 => sincosq,
        else => @compileError("unimplemented"),
    };

    var s: T = undefined;
    var c: T = undefined;

    f(0.0, &s, &c);
    try expect(math.isPositiveZero(s));
    try expect(c == 1.0);

    f(-0.0, &s, &c);
    try expect(math.isNegativeZero(s));
    try expect(c == 1.0);

    f(math.inf(T), &s, &c);
    try expect(math.isNan(s));
    try expect(math.isNan(c));

    f(-math.inf(T), &s, &c);
    try expect(math.isNan(s));
    try expect(math.isNan(c));

    f(math.nan(T), &s, &c);
    try expect(math.isNan(s));
    try expect(math.isNan(c));
}

test "sincos32.normal" {
    const epsilon = math.floatEps(f32);
    var s: f32 = undefined;
    var c: f32 = undefined;

    sincosf(0.0, &s, &c);
    try expectApproxEqAbs(@as(f32, 0.0), s, epsilon);
    try expectApproxEqAbs(@as(f32, 1.0), c, epsilon);

    sincosf(0.2, &s, &c);
    try expectApproxEqAbs(@as(f32, 0.19866933), s, epsilon);
    try expectApproxEqAbs(@as(f32, 0.9800666), c, epsilon);

    sincosf(0.8923, &s, &c);
    try expectApproxEqAbs(@as(f32, 0.77851737), s, epsilon);
    try expectApproxEqAbs(@as(f32, 0.6276231), c, epsilon);

    sincosf(1.5, &s, &c);
    try expectApproxEqAbs(@as(f32, 0.997495), s, epsilon);
    try expectApproxEqAbs(@as(f32, 0.0707372), c, epsilon);

    sincosf(-1.5, &s, &c);
    try expectApproxEqAbs(@as(f32, -0.997495), s, epsilon);
    try expectApproxEqAbs(@as(f32, 0.0707372), c, epsilon);

    sincosf(37.45, &s, &c);
    try expectApproxEqAbs(@as(f32, -0.24654257), s, epsilon);
    try expectApproxEqAbs(@as(f32, 0.96913195), c, epsilon);

    sincosf(89.123, &s, &c);
    try expectApproxEqAbs(@as(f32, 0.9161657), s, epsilon);
    try expectApproxEqAbs(@as(f32, 0.40079966), c, epsilon);
}

test "sincos32.special" {
    try testSincosSpecial(f32);
}

test "sincos64.normal" {
    const epsilon = math.floatEps(f64);
    var s: f64 = undefined;
    var c: f64 = undefined;

    sincos(0.0, &s, &c);
    try expectApproxEqAbs(@as(f64, 0.0), s, epsilon);
    try expectApproxEqAbs(@as(f64, 1.0), c, epsilon);

    sincos(0.2, &s, &c);
    try expectApproxEqAbs(@as(f64, 0.19866933079506122), s, epsilon);
    try expectApproxEqAbs(@as(f64, 0.9800665778412416), c, epsilon);

    sincos(0.8923, &s, &c);
    try expectApproxEqAbs(@as(f64, 0.7785173385577349), s, epsilon);
    try expectApproxEqAbs(@as(f64, 0.6276230983360804), c, epsilon);

    sincos(1.5, &s, &c);
    try expectApproxEqAbs(@as(f64, 0.9974949866040544), s, epsilon);
    try expectApproxEqAbs(@as(f64, 0.0707372016677029), c, epsilon);

    sincos(-1.5, &s, &c);
    try expectApproxEqAbs(@as(f64, -0.9974949866040544), s, epsilon);
    try expectApproxEqAbs(@as(f64, 0.0707372016677029), c, epsilon);

    sincos(37.45, &s, &c);
    try expectApproxEqAbs(@as(f64, -0.24654331551411082), s, epsilon);
    try expectApproxEqAbs(@as(f64, 0.9691317730707778), c, epsilon);

    sincos(89.123, &s, &c);
    try expectApproxEqAbs(@as(f64, 0.9161652766622714), s, epsilon);
    try expectApproxEqAbs(@as(f64, 0.4008006809354791), c, epsilon);
}

test "sincos64.special" {
    try testSincosSpecial(f64);
}

test "sincos80.normal" {
    const epsilon = math.floatEps(f80);
    var s: f80 = undefined;
    var c: f80 = undefined;

    sincosx(0.0, &s, &c);
    try expectApproxEqAbs(@as(f80, 0.0), s, epsilon);
    try expectApproxEqAbs(@as(f80, 1.0), c, epsilon);

    sincosx(0.2, &s, &c);
    try expectApproxEqAbs(@as(f80, 0.19866933079506121545941262711838975), s, epsilon);
    try expectApproxEqAbs(@as(f80, 0.98006657784124163112419651674816888), c, epsilon);

    sincosx(0.8923, &s, &c);
    try expectApproxEqAbs(@as(f80, 0.77851733855773487830689285621486050), s, epsilon);
    try expectApproxEqAbs(@as(f80, 0.62762309833608037003563995939286067), c, epsilon);

    sincosx(1.5, &s, &c);
    try expectApproxEqAbs(@as(f80, 0.99749498660405443094172337114148732), s, epsilon);
    try expectApproxEqAbs(@as(f80, 0.070737201667702910088189851434268747), c, epsilon);

    sincosx(-1.5, &s, &c);
    try expectApproxEqAbs(@as(f80, -0.99749498660405443094172337114148732), s, epsilon);
    try expectApproxEqAbs(@as(f80, 0.070737201667702910088189851434268747), c, epsilon);

    sincosx(37.45, &s, &c);
    try expectApproxEqAbs(@as(f80, -0.24654331551411356504), s, epsilon);
    try expectApproxEqAbs(@as(f80, 0.9691317730707771246), c, epsilon);

    sincosx(89.123, &s, &c);
    try expectApproxEqAbs(@as(f80, 0.91616527666226951006), s, epsilon);
    try expectApproxEqAbs(@as(f80, 0.4008006809354834001), c, epsilon);
}

test "sincos80.special" {
    try testSincosSpecial(f80);
}

test "sincos128.normal" {
    const epsilon = math.floatEps(f128);
    var s: f128 = undefined;
    var c: f128 = undefined;

    sincosq(0.0, &s, &c);
    try expectApproxEqAbs(@as(f128, 0.0), s, epsilon);
    try expectApproxEqAbs(@as(f128, 1.0), c, epsilon);

    sincosq(0.2, &s, &c);
    try expectApproxEqAbs(@as(f128, 0.19866933079506121545941262711838975), s, epsilon);
    try expectApproxEqAbs(@as(f128, 0.98006657784124163112419651674816888), c, epsilon);

    sincosq(0.8923, &s, &c);
    try expectApproxEqAbs(@as(f128, 0.77851733855773487830689285621486050), s, epsilon);
    try expectApproxEqAbs(@as(f128, 0.62762309833608037003563995939286067), c, epsilon);

    sincosq(1.5, &s, &c);
    try expectApproxEqAbs(@as(f128, 0.99749498660405443094172337114148732), s, epsilon);
    try expectApproxEqAbs(@as(f128, 0.070737201667702910088189851434268747), c, epsilon);

    sincosq(-1.5, &s, &c);
    try expectApproxEqAbs(@as(f128, -0.99749498660405443094172337114148732), s, epsilon);
    try expectApproxEqAbs(@as(f128, 0.070737201667702910088189851434268747), c, epsilon);

    sincosq(37.45, &s, &c);
    try expectApproxEqAbs(@as(f128, -0.24654331551411356571238581321661085), s, epsilon);
    try expectApproxEqAbs(@as(f128, 0.96913177307077712443149563847233230), c, epsilon);

    sincosq(89.123, &s, &c);
    try expectApproxEqAbs(@as(f128, 0.91616527666226951075019849560482170), s, epsilon);
    try expectApproxEqAbs(@as(f128, 0.40080068093548339848199454493704702), c, epsilon);
}

test "sincos128.special" {
    try testSincosSpecial(f128);
}
