//! Ported from musl, which is licensed under the MIT license:
//! https://git.musl-libc.org/cgit/musl/tree/COPYRIGHT
//!
//! https://git.musl-libc.org/cgit/musl/tree/src/math/tanf.c
//! https://git.musl-libc.org/cgit/musl/tree/src/math/tan.c
//! https://git.musl-libc.org/cgit/musl/tree/src/math/tanl.c
//! https://golang.org/src/math/tan.go

const std = @import("std");
const builtin = @import("builtin");
const math = std.math;
const mem = std.mem;
const expect = std.testing.expect;
const expectApproxEqAbs = std.testing.expectApproxEqAbs;

const kernel = @import("trig.zig");
const rem_pio2 = @import("rem_pio2.zig").rem_pio2;
const rem_pio2f = @import("rem_pio2f.zig").rem_pio2f;
const rem_pio2l = @import("rem_pio2l.zig").rem_pio2l;
const ld = @import("long_double.zig");

const arch = builtin.cpu.arch;
const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    symbol(&tanh, "__tanh");
    symbol(&tanf, "tanf");
    symbol(&tan, "tan");
    symbol(&tanx, "__tanx");
    if (compiler_rt.want_ppc_abi) {
        symbol(&tanq, "tanf128");
    }
    symbol(&tanq, "tanq");
    symbol(&tanl, "tanl");
}

pub fn tanh(x: f16) callconv(.c) f16 {
    // TODO: more efficient implementation
    return @floatCast(tanf(x));
}

pub fn tanf(x: f32) callconv(.c) f32 {
    // Small multiples of pi/2 rounded to double precision.
    const t1pio2: f64 = 1.0 * math.pi / 2.0; // 0x3FF921FB, 0x54442D18
    const t2pio2: f64 = 2.0 * math.pi / 2.0; // 0x400921FB, 0x54442D18
    const t3pio2: f64 = 3.0 * math.pi / 2.0; // 0x4012D97C, 0x7F3321D2
    const t4pio2: f64 = 4.0 * math.pi / 2.0; // 0x401921FB, 0x54442D18

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
        return kernel.tandf(x, false);
    }
    if (ix <= 0x407b53d1) { // |x| ~<= 5*pi/4
        if (ix <= 0x4016cbe3) { // |x| ~<= 3pi/4
            return kernel.tandf((if (sign) x + t1pio2 else x - t1pio2), true);
        } else {
            return kernel.tandf((if (sign) x + t2pio2 else x - t2pio2), false);
        }
    }
    if (ix <= 0x40e231d5) { // |x| ~<= 9*pi/4
        if (ix <= 0x40afeddf) { // |x| ~<= 7*pi/4
            return kernel.tandf((if (sign) x + t3pio2 else x - t3pio2), true);
        } else {
            return kernel.tandf((if (sign) x + t4pio2 else x - t4pio2), false);
        }
    }

    // tan(Inf or NaN) is NaN
    if (ix >= 0x7f800000) {
        return x - x;
    }

    var y: f64 = undefined;
    const n = rem_pio2f(x, &y);
    return kernel.tandf(y, n & 1 != 0);
}

pub fn tan(x: f64) callconv(.c) f64 {
    var ix = @as(u64, @bitCast(x)) >> 32;
    ix &= 0x7fffffff;

    // |x| ~< pi/4
    if (ix <= 0x3fe921fb) {
        if (ix < 0x3e400000) { // |x| < 2**-27
            // raise inexact if x!=0 and underflow if subnormal
            if (compiler_rt.want_float_exceptions) {
                if (ix < 0x00100000) {
                    mem.doNotOptimizeAway(x / 0x1p120);
                } else {
                    mem.doNotOptimizeAway(x + 0x1p120);
                }
            }
            return x;
        }
        return kernel.tan(x, 0.0, false);
    }

    // tan(Inf or NaN) is NaN
    if (ix >= 0x7ff00000) {
        return x - x;
    }

    var y: [2]f64 = undefined;
    const n = rem_pio2(x, &y);
    return kernel.tan(y[0], y[1], n & 1 != 0);
}

pub fn tanx(x: f80) callconv(.c) f80 {
    const se = ld.signExponent(x) & 0x7fff;
    if (se == 0x7fff) {
        return x - x;
    }

    if (@abs(x) < kernel.pi_4) {
        if (se < 0x3fff - math.floatMantissaBits(f80) / 2) {
            if (compiler_rt.want_float_exceptions) {
                mem.doNotOptimizeAway(if (se == 0) x * 0x1p-120 else x + 0x1p120);
            }
            return x;
        }
        return kernel.tanx(x, 0.0, 0);
    }

    var y: [2]f80 = undefined;
    const n = rem_pio2l(f80, x, &y);
    return kernel.tanx(y[0], y[1], n & 1);
}

pub fn tanq(x: f128) callconv(.c) f128 {
    const se = ld.signExponent(x) & 0x7fff;
    if (se == 0x7fff) {
        return x - x;
    }

    if (@abs(x) < kernel.pi_4) {
        if (se < 0x3fff - math.floatMantissaBits(f128) / 2) {
            if (compiler_rt.want_float_exceptions) {
                mem.doNotOptimizeAway(if (se == 0) x * 0x1p-120 else x + 0x1p120);
            }
            return x;
        }
        return kernel.tanq(x, 0.0, 0);
    }

    var y: [2]f128 = undefined;
    const n = rem_pio2l(f128, x, &y);
    return kernel.tanq(y[0], y[1], n & 1);
}

pub fn tanl(x: c_longdouble) callconv(.c) c_longdouble {
    switch (@typeInfo(c_longdouble).float.bits) {
        16 => return tanh(x),
        32 => return tanf(x),
        64 => return tan(x),
        80 => return tanx(x),
        128 => return tanq(x),
        else => @compileError("unreachable"),
    }
}

fn testTanNormal(comptime T: type) !void {
    const f = switch (T) {
        f32 => tanf,
        f64 => tan,
        else => @compileError("unimplemented"),
    };
    const epsilon = 0.00001;

    try expectApproxEqAbs(@as(T, 0.0), f(0.0), epsilon);
    try expectApproxEqAbs(@as(T, 0.202710), f(0.2), epsilon);
    try expectApproxEqAbs(@as(T, 1.240422), f(0.8923), epsilon);
    try expectApproxEqAbs(@as(T, 14.101420), f(1.5), epsilon);
    try expectApproxEqAbs(@as(T, -0.254397), f(37.45), epsilon);
    try expectApproxEqAbs(@as(T, 2.285837), f(89.123), epsilon);
}

fn testTanSpecial(comptime T: type) !void {
    const f = switch (T) {
        f32 => tanf,
        f64 => tan,
        f80 => tanx,
        f128 => tanq,
        else => @compileError("unimplemented"),
    };

    try expect(math.isPositiveZero(f(0.0)));
    try expect(math.isNegativeZero(f(-0.0)));
    try expect(math.isNan(f(math.inf(f32))));
    try expect(math.isNan(f(-math.inf(f32))));
    try expect(math.isNan(f(math.nan(f32))));
}

test "tan32.normal" {
    try testTanNormal(f32);
}

test "tan64.normal" {
    try testTanNormal(f64);
}

test "tan80.normal" {
    const epsilon = math.floatEps(f80);

    try expectApproxEqAbs(@as(f80, 0.0), tanx(0.0), epsilon);
    try expectApproxEqAbs(@as(f80, 0.2027100355086724833213582716475345), tanx(0.2), epsilon);
    try expectApproxEqAbs(@as(f80, 1.2404217445497097995561220131857544), tanx(0.8923), epsilon);
    try expectApproxEqAbs(@as(f80, 14.10141994717171938764), tanx(1.5), epsilon);
    try expectApproxEqAbs(@as(f80, -0.25439607116885656232), tanx(37.45), epsilon);
    try expectApproxEqAbs(@as(f80, 2.2858376251355320963), tanx(89.123), epsilon);
}

test "tan128.normal" {
    const epsilon = math.floatEps(f128);

    try expectApproxEqAbs(@as(f128, 0.0), tanq(0.0), epsilon);
    try expectApproxEqAbs(@as(f128, 0.2027100355086724833213582716475345), tanq(0.2), epsilon);
    try expectApproxEqAbs(@as(f128, 1.2404217445497097995561220131857544), tanq(0.8923), epsilon);
    try expectApproxEqAbs(@as(f128, 14.101419947171719387646083651987755), tanq(1.5), epsilon);
    try expectApproxEqAbs(@as(f128, -0.2543960711688565630469573224504774), tanq(37.45), epsilon);
    try expectApproxEqAbs(@as(f128, 2.2858376251355321074066028114094292), tanq(89.123), epsilon);
}

test "tan32.special" {
    try testTanSpecial(f32);
}

test "tan64.special" {
    try testTanSpecial(f64);
}

test "tan80.special" {
    try testTanSpecial(f80);
}

test "tan128.special" {
    try testTanSpecial(f128);
}
