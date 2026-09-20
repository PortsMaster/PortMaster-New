const builtin = @import("builtin");

const std = @import("std");
const math = std.math;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectApproxEqAbs = std.testing.expectApproxEqAbs;
const expectApproxEqRel = std.testing.expectApproxEqRel;

const symbol = @import("../c.zig").symbol;

comptime {
    if (builtin.target.isMinGW()) {
        symbol(&isnan, "isnan");
        symbol(&isnan, "__isnan");
        symbol(&isnanf, "isnanf");
        symbol(&isnanf, "__isnanf");
        symbol(&isnanl, "isnanl");
        symbol(&isnanl, "__isnanl");

        symbol(&math.floatTrueMin(f64), "__DENORM");
        symbol(&math.inf(f64), "__INF");
        symbol(&math.nan(f64), "__QNAN");
        symbol(&math.snan(f64), "__SNAN");

        symbol(&math.floatTrueMin(f32), "__DENORMF");
        symbol(&math.inf(f32), "__INFF");
        symbol(&math.nan(f32), "__QNANF");
        symbol(&math.snan(f32), "__SNANF");

        symbol(&math.floatTrueMin(c_longdouble), "__DENORML");
        symbol(&math.inf(c_longdouble), "__INFL");
        symbol(&math.nan(c_longdouble), "__QNANL");
        symbol(&math.snan(c_longdouble), "__SNANL");
    }

    if (builtin.target.isMinGW() or builtin.target.isMuslLibC() or builtin.target.isWasiLibC()) {
        symbol(&frexpf, "frexpf");
        symbol(&frexpl, "frexpl");
        symbol(&hypotf, "hypotf");
        symbol(&hypotl, "hypotl");
        symbol(&modfl, "modfl");
    }

    if ((builtin.target.isMinGW() and @sizeOf(f64) != @sizeOf(c_longdouble)) or builtin.target.isMuslLibC() or builtin.target.isWasiLibC()) {
        symbol(&atanl, "atanl");
        symbol(&copysignl, "copysignl");
        symbol(&nanl, "nanl");
    }

    if ((builtin.target.isMinGW() and builtin.cpu.arch == .x86) or builtin.target.isMuslLibC() or builtin.target.isWasiLibC()) {
        symbol(&acosf, "acosf");
        symbol(&atanf, "atanf");
        symbol(&coshf, "coshf");
        symbol(&modff, "modff");
        symbol(&tanhf, "tanhf");
    }

    if (builtin.target.isMuslLibC() or builtin.target.isWasiLibC()) {
        symbol(&acos, "acos");
        symbol(&acoshf, "acoshf");
        symbol(&asin, "asin");
        symbol(&atan, "atan");
        symbol(&cbrt, "cbrt");
        symbol(&cbrtf, "cbrtf");
        symbol(&cosh, "cosh");
        symbol(&exp10, "exp10");
        symbol(&exp10f, "exp10f");
        symbol(&fdim, "fdim");
        symbol(&finite, "finite");
        symbol(&finitef, "finitef");
        symbol(&frexp, "frexp");
        symbol(&hypot, "hypot");
        symbol(&lrint, "lrint");
        symbol(&lrintf, "lrintf");
        symbol(&modf, "modf");
        symbol(&nan, "nan");
        symbol(&nanf, "nanf");
        symbol(&pow10, "pow10");
        symbol(&pow10f, "pow10f");
        symbol(&tanh, "tanh");
    }

    if (builtin.target.isMuslLibC()) {
        symbol(&copysign, "copysign");
        symbol(&copysignf, "copysignf");
        symbol(&rint, "rint");
        symbol(&rintf, "rintf");
    }
}

fn acos(x: f64) callconv(.c) f64 {
    return math.acos(x);
}

fn acosf(x: f32) callconv(.c) f32 {
    return math.acos(x);
}

fn acoshf(x: f32) callconv(.c) f32 {
    return math.acosh(x);
}

fn asin(x: f64) callconv(.c) f64 {
    return math.asin(x);
}

fn atan(x: f64) callconv(.c) f64 {
    return math.atan(x);
}

fn atanf(x: f32) callconv(.c) f32 {
    return math.atan(x);
}

fn atanl(x: c_longdouble) callconv(.c) c_longdouble {
    return switch (@typeInfo(@TypeOf(x)).float.bits) {
        16 => math.atan(@as(f16, @floatCast(x))),
        32 => math.atan(@as(f32, @floatCast(x))),
        64 => math.atan(@as(f64, @floatCast(x))),
        80 => math.atan(@as(f80, @floatCast(x))),
        128 => math.atan(@as(f128, @floatCast(x))),
        else => unreachable,
    };
}

fn cbrt(x: f64) callconv(.c) f64 {
    return math.cbrt(x);
}

fn cbrtf(x: f32) callconv(.c) f32 {
    return math.cbrt(x);
}

fn copysign(x: f64, y: f64) callconv(.c) f64 {
    return math.copysign(x, y);
}

fn copysignf(x: f32, y: f32) callconv(.c) f32 {
    return math.copysign(x, y);
}

fn copysignl(x: c_longdouble, y: c_longdouble) callconv(.c) c_longdouble {
    return math.copysign(x, y);
}

fn cosh(x: f64) callconv(.c) f64 {
    return math.cosh(x);
}

fn coshf(x: f32) callconv(.c) f32 {
    return math.cosh(x);
}

fn exp10(x: f64) callconv(.c) f64 {
    return math.pow(f64, 10.0, x);
}

fn exp10f(x: f32) callconv(.c) f32 {
    return math.pow(f32, 10.0, x);
}

fn fdim(x: f64, y: f64) callconv(.c) f64 {
    if (math.isNan(x)) {
        return x;
    }
    if (math.isNan(y)) {
        return y;
    }
    if (x > y) {
        return x - y;
    }
    return 0;
}

fn finite(x: f64) callconv(.c) c_int {
    return if (math.isFinite(x)) 1 else 0;
}

fn finitef(x: f32) callconv(.c) c_int {
    return if (math.isFinite(x)) 1 else 0;
}

fn frexpGeneric(comptime T: type, x: T, e: *c_int) T {
    // libc expects `*e` to be unspecified in this case; an unspecified C value
    // should be a valid value of the relevant type, yet Zig's std
    // implementation sets it to `undefined` -- which can even be nonsense
    // according to the type (int). Therefore, we're setting it to a valid
    // int value in Zig -- a zero.
    //
    // This mirrors the handling of infinities, where libc also expects
    // unspecified for the value of `*e` and Zig std sets it to a zero.
    if (math.isNan(x)) {
        e.* = 0;
        return x;
    }

    const r = math.frexp(x);
    e.* = r.exponent;
    return r.significand;
}

fn frexp(x: f64, e: *c_int) callconv(.c) f64 {
    return frexpGeneric(f64, x, e);
}

fn frexpf(x: f32, e: *c_int) callconv(.c) f32 {
    return frexpGeneric(f32, x, e);
}

fn frexpl(x: c_longdouble, e: *c_int) callconv(.c) c_longdouble {
    return frexpGeneric(c_longdouble, x, e);
}

fn hypot(x: f64, y: f64) callconv(.c) f64 {
    return math.hypot(x, y);
}

fn hypotf(x: f32, y: f32) callconv(.c) f32 {
    return math.hypot(x, y);
}

fn hypotl(x: c_longdouble, y: c_longdouble) callconv(.c) c_longdouble {
    return math.hypot(x, y);
}

fn isnan(x: f64) callconv(.c) c_int {
    return if (math.isNan(x)) 1 else 0;
}

fn isnanf(x: f32) callconv(.c) c_int {
    return if (math.isNan(x)) 1 else 0;
}

fn isnanl(x: c_longdouble) callconv(.c) c_int {
    return if (math.isNan(x)) 1 else 0;
}

fn lrint(x: f64) callconv(.c) c_long {
    return @intFromFloat(rint(x));
}

fn lrintf(x: f32) callconv(.c) c_long {
    return @intFromFloat(rintf(x));
}

fn modfGeneric(comptime T: type, x: T, iptr: *T) T {
    if (math.isNegativeInf(x)) {
        iptr.* = -math.inf(T);
        return -0.0;
    }

    if (math.isPositiveInf(x)) {
        iptr.* = math.inf(T);
        return 0.0;
    }

    if (math.isNan(x)) {
        iptr.* = math.nan(T);
        return math.nan(T);
    }

    const r = math.modf(x);
    iptr.* = r.ipart;

    // If the result is a negative zero, we must be explicit about
    // returning a negative zero.
    return if (math.isNegativeZero(x) or (x < 0.0 and x == r.ipart)) -0.0 else r.fpart;
}

fn modf(x: f64, iptr: *f64) callconv(.c) f64 {
    return modfGeneric(f64, x, iptr);
}

fn modff(x: f32, iptr: *f32) callconv(.c) f32 {
    return modfGeneric(f32, x, iptr);
}

fn modfl(x: c_longdouble, iptr: *c_longdouble) callconv(.c) c_longdouble {
    return modfGeneric(c_longdouble, x, iptr);
}

fn testModf(comptime T: type) !void {
    // Choose the appropriate `modf` impl to test based on type
    const f = switch (T) {
        f32 => modff,
        f64 => modf,
        c_longdouble => modfl,
        else => @compileError("modf not implemented for " ++ @typeName(T)),
    };

    var int: T = undefined;
    const iptr = &int;
    const eps_val: comptime_float = @max(1e-6, math.floatEps(T));

    const normal_frac = f(@as(T, 1234.567), iptr);
    // Account for precision error
    const expected = 1234.567 - @as(T, 1234);
    try expectApproxEqAbs(expected, normal_frac, eps_val);
    try expectApproxEqRel(@as(T, 1234.0), iptr.*, eps_val);

    // When `x` is a NaN, NaN is returned and `*iptr` is set to NaN
    const nan_frac = f(math.nan(T), iptr);
    try expect(math.isNan(nan_frac));
    try expect(math.isNan(iptr.*));

    // When `x` is positive infinity, +0 is returned and `*iptr` is set to
    // positive infinity
    const pos_zero_frac = f(math.inf(T), iptr);
    try expect(math.isPositiveZero(pos_zero_frac));
    try expect(math.isPositiveInf(iptr.*));

    // When `x` is negative infinity, -0 is returned and `*iptr` is set to
    // negative infinity
    const neg_zero_frac = f(-math.inf(T), iptr);
    try expect(math.isNegativeZero(neg_zero_frac));
    try expect(math.isNegativeInf(iptr.*));

    // Return -0 when `x` is a negative integer
    const nz_frac = f(@as(T, -1000.0), iptr);
    try expect(math.isNegativeZero(nz_frac));
    try expectEqual(@as(T, -1000.0), iptr.*);

    // Return +0 when `x` is a positive integer
    const pz_frac = f(@as(T, 1000.0), iptr);
    try expect(math.isPositiveZero(pz_frac));
    try expectEqual(@as(T, 1000.0), iptr.*);
}

test "modf" {
    try testModf(f32);
    try testModf(f64);
    try testModf(c_longdouble);
}

fn nan(_: [*:0]const c_char) callconv(.c) f64 {
    return math.nan(f64);
}

fn nanf(_: [*:0]const c_char) callconv(.c) f32 {
    return math.nan(f32);
}

fn nanl(_: [*:0]const c_char) callconv(.c) c_longdouble {
    return math.nan(c_longdouble);
}

fn pow10(x: f64) callconv(.c) f64 {
    return exp10(x);
}

fn pow10f(x: f32) callconv(.c) f32 {
    return exp10f(x);
}

fn rint(x: f64) callconv(.c) f64 {
    const toint: f64 = 1.0 / math.floatEps(f64);
    const a: u64 = @bitCast(x);
    const e = a >> 52 & 0x7ff;
    const s = a >> 63;
    var y: f64 = undefined;

    if (e >= 0x3ff + 52) {
        return x;
    }
    if (s == 1) {
        y = x - toint + toint;
    } else {
        y = x + toint - toint;
    }
    if (y == 0) {
        return if (s == 1) -0.0 else 0;
    }
    return y;
}

fn rintf(x: f32) callconv(.c) f32 {
    const toint: f32 = 1.0 / math.floatEps(f32);
    const a: u32 = @bitCast(x);
    const e = a >> 23 & 0xff;
    const s = a >> 31;
    var y: f32 = undefined;

    if (e >= 0x7f + 23) {
        return x;
    }

    if (s == 1) {
        y = x - toint + toint;
    } else {
        y = x + toint - toint;
    }

    if (y == 0) {
        return if (s == 1) -0.0 else 0;
    }
    return y;
}

fn testRint(comptime T: type) !void {
    const f = switch (T) {
        f32 => rintf,
        f64 => rint,
        else => @compileError("rint not implemented for" ++ @typeName(T)),
    };

    // Positive numbers round correctly
    try expectEqual(@as(T, 42.0), f(42.2));
    try expectEqual(@as(T, 42.0), f(41.8));

    // Negative numbers round correctly
    try expectEqual(@as(T, -6.0), f(-5.9));
    try expectEqual(@as(T, -6.0), f(-6.1));

    // No rounding needed test
    try expectEqual(@as(T, 5.0), f(5.0));
    try expectEqual(@as(T, -10.0), f(-10.0));
    try expectEqual(@as(T, 0.0), f(0.0));

    // Very large numbers return unchanged
    const large: T = 9007199254740992.0; // 2^53
    try expectEqual(large, f(large));
    try expectEqual(-large, f(-large));

    // Small positive numbers round to zero
    const pos_result = f(0.3);
    try expect(math.isPositiveZero(pos_result));

    // Small negative numbers round to negative zero
    const neg_result = f(-0.3);
    try expect(math.isNegativeZero(neg_result));

    // Exact half rounds to nearest even (banker's rounding)
    try expectEqual(@as(T, 2.0), f(2.5));
    try expectEqual(@as(T, 4.0), f(3.5));
}

test "rint" {
    try testRint(f32);
    try testRint(f64);
}

fn tanh(x: f64) callconv(.c) f64 {
    return math.tanh(x);
}

fn tanhf(x: f32) callconv(.c) f32 {
    return math.tanh(x);
}
