//! Ported from musl, which is MIT licensed.
//! https://git.musl-libc.org/cgit/musl/tree/COPYRIGHT
//!
//! https://git.musl-libc.org/cgit/musl/tree/src/math/ceilf.c
//! https://git.musl-libc.org/cgit/musl/tree/src/math/ceil.c
//! https://git.musl-libc.org/cgit/musl/tree/src/math/ceill.c
//!
//! https://git.musl-libc.org/cgit/musl/tree/src/math/floorf.c
//! https://git.musl-libc.org/cgit/musl/tree/src/math/floor.c
//! https://git.musl-libc.org/cgit/musl/tree/src/math/floorl.c

const std = @import("std");
const math = std.math;
const mem = std.mem;
const expect = std.testing.expect;

const compiler_rt = @import("../compiler_rt.zig");
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    // floor
    symbol(&__floorh, "__floorh");
    symbol(&floorf, "floorf");
    symbol(&floor, "floor");
    symbol(&__floorx, "__floorx");
    if (compiler_rt.want_ppc_abi) {
        symbol(&floorq, "floorf128");
    }
    symbol(&floorq, "floorq");
    symbol(&floorl, "floorl");

    // ceil
    symbol(&__ceilh, "__ceilh");
    symbol(&ceilf, "ceilf");
    symbol(&ceil, "ceil");
    symbol(&__ceilx, "__ceilx");
    if (compiler_rt.want_ppc_abi) {
        symbol(&ceilq, "ceilf128");
    }
    symbol(&ceilq, "ceilq");
    symbol(&ceill, "ceill");
}

pub fn __floorh(x: f16) callconv(.c) f16 {
    return impl(f16, .floor, x);
}

pub fn floorf(x: f32) callconv(.c) f32 {
    return impl(f32, .floor, x);
}

pub fn floor(x: f64) callconv(.c) f64 {
    return impl(f64, .floor, x);
}

pub fn __floorx(x: f80) callconv(.c) f80 {
    return impl(f80, .floor, x);
}

pub fn floorq(x: f128) callconv(.c) f128 {
    return impl(f128, .floor, x);
}

pub fn floorl(x: c_longdouble) callconv(.c) c_longdouble {
    return impl(std.meta.Float(@bitSizeOf(c_longdouble)), .floor, x);
}

pub fn __ceilh(x: f16) callconv(.c) f16 {
    return impl(f16, .ceil, x);
}

pub fn ceilf(x: f32) callconv(.c) f32 {
    return impl(f32, .ceil, x);
}

pub fn ceil(x: f64) callconv(.c) f64 {
    return impl(f64, .ceil, x);
}

pub fn __ceilx(x: f80) callconv(.c) f80 {
    return impl(f80, .ceil, x);
}

pub fn ceilq(x: f128) callconv(.c) f128 {
    return impl(f128, .ceil, x);
}

pub fn ceill(x: c_longdouble) callconv(.c) c_longdouble {
    return impl(std.meta.Float(@bitSizeOf(c_longdouble)), .ceil, x);
}

inline fn impl(comptime T: type, comptime op: enum { floor, ceil }, x: T) T {
    const C = 1.0 / math.floatEps(T);
    const mantissa = math.floatMantissaBits(T);
    const mask = (1 << math.floatExponentBits(T)) - 1;
    const bias = (1 << (math.floatExponentBits(T) - 1)) - 1;

    const bits = @bitSizeOf(T);
    const U = @Int(.unsigned, bits);
    var u: U = @bitCast(x);
    switch (T) {
        f16, f32 => {
            const e = @as(@Int(.signed, bits), @intCast((u >> mantissa) & mask)) - bias;
            if (e >= mantissa) return x;

            if (e >= 0) {
                const m = (@as(U, 1) << @intCast(mantissa - e)) - 1;
                if (u & m == 0) return x;
                if (compiler_rt.want_float_exceptions) mem.doNotOptimizeAway(x + 0x1.0p120);
                if (u >> bits - 1 == @intFromBool(op == .floor)) u += m;
                return @bitCast(u & ~m);
            } else {
                if (compiler_rt.want_float_exceptions) mem.doNotOptimizeAway(x + 0x1.0p120);
                return switch (op) {
                    .floor => if (u >> bits - 1 == 0) 0.0 else if (u << 1 != 0) -1.0 else x,
                    .ceil => if (u >> bits - 1 != 0) -0.0 else if (u << 1 != 0) 1.0 else x,
                };
            }
        },
        f64, f80, f128 => {
            const e = (u >> mantissa) & mask;
            if (e >= bias + math.floatFractionalBits(T) or x == 0) return x;

            const positive = u >> @bitSizeOf(T) - 1 == 0;
            const y: T = if (positive)
                x + C - C - x
            else
                x - C + C - x;

            if (e <= bias - 1) {
                if (compiler_rt.want_float_exceptions) mem.doNotOptimizeAway(y);
                return switch (op) {
                    .floor => if (positive) 0.0 else -1.0,
                    .ceil => if (positive) 1.0 else -0.0,
                };
            }
            switch (op) {
                .floor => if (y > 0) return x + y - 1,
                .ceil => if (y < 0) return x + y + 1,
            }
            return x + y;
        },
        else => unreachable,
    }
}

test "floor16" {
    try expect(__floorh(1.3) == 1.0);
    try expect(__floorh(-1.3) == -2.0);
    try expect(__floorh(0.2) == 0.0);
}

test "floor32" {
    try expect(floorf(1.3) == 1.0);
    try expect(floorf(-1.3) == -2.0);
    try expect(floorf(0.2) == 0.0);
}

test "floor64" {
    try expect(floor(1.3) == 1.0);
    try expect(floor(-1.3) == -2.0);
    try expect(floor(0.2) == 0.0);
}

test "floor80" {
    try expect(__floorx(1.3) == 1.0);
    try expect(__floorx(-1.3) == -2.0);
    try expect(__floorx(0.2) == 0.0);
}

test "floor128" {
    try expect(floorq(1.3) == 1.0);
    try expect(floorq(-1.3) == -2.0);
    try expect(floorq(0.2) == 0.0);
}

test "floor16.special" {
    try expect(__floorh(0.0) == 0.0);
    try expect(__floorh(-0.0) == -0.0);
    try expect(math.isPositiveInf(__floorh(math.inf(f16))));
    try expect(math.isNegativeInf(__floorh(-math.inf(f16))));
    try expect(math.isNan(__floorh(math.nan(f16))));
}

test "floor32.special" {
    try expect(floorf(0.0) == 0.0);
    try expect(floorf(-0.0) == -0.0);
    try expect(math.isPositiveInf(floorf(math.inf(f32))));
    try expect(math.isNegativeInf(floorf(-math.inf(f32))));
    try expect(math.isNan(floorf(math.nan(f32))));
}

test "floor64.special" {
    try expect(floor(0.0) == 0.0);
    try expect(floor(-0.0) == -0.0);
    try expect(math.isPositiveInf(floor(math.inf(f64))));
    try expect(math.isNegativeInf(floor(-math.inf(f64))));
    try expect(math.isNan(floor(math.nan(f64))));
}

test "floor80.special" {
    try expect(__floorx(0.0) == 0.0);
    try expect(__floorx(-0.0) == -0.0);
    try expect(math.isPositiveInf(__floorx(math.inf(f80))));
    try expect(math.isNegativeInf(__floorx(-math.inf(f80))));
    try expect(math.isNan(__floorx(math.nan(f80))));
}

test "floor128.special" {
    try expect(floorq(0.0) == 0.0);
    try expect(floorq(-0.0) == -0.0);
    try expect(math.isPositiveInf(floorq(math.inf(f128))));
    try expect(math.isNegativeInf(floorq(-math.inf(f128))));
    try expect(math.isNan(floorq(math.nan(f128))));
}

test "ceil16" {
    try expect(__ceilh(1.3) == 2.0);
    try expect(__ceilh(-1.3) == -1.0);
    try expect(__ceilh(0.2) == 1.0);
}

test "ceil32" {
    try expect(ceilf(1.3) == 2.0);
    try expect(ceilf(-1.3) == -1.0);
    try expect(ceilf(0.2) == 1.0);
}

test "ceil64" {
    try expect(ceil(1.3) == 2.0);
    try expect(ceil(-1.3) == -1.0);
    try expect(ceil(0.2) == 1.0);
}

test "ceil80" {
    try expect(__ceilx(1.3) == 2.0);
    try expect(__ceilx(-1.3) == -1.0);
    try expect(__ceilx(0.2) == 1.0);
}

test "ceil128" {
    try expect(ceilq(1.3) == 2.0);
    try expect(ceilq(-1.3) == -1.0);
    try expect(ceilq(0.2) == 1.0);
}

test "ceil16.special" {
    try expect(__ceilh(0.0) == 0.0);
    try expect(__ceilh(-0.0) == -0.0);
    try expect(math.isPositiveInf(__ceilh(math.inf(f16))));
    try expect(math.isNegativeInf(__ceilh(-math.inf(f16))));
    try expect(math.isNan(__ceilh(math.nan(f16))));
}

test "ceil32.special" {
    try expect(ceilf(0.0) == 0.0);
    try expect(ceilf(-0.0) == -0.0);
    try expect(math.isPositiveInf(ceilf(math.inf(f32))));
    try expect(math.isNegativeInf(ceilf(-math.inf(f32))));
    try expect(math.isNan(ceilf(math.nan(f32))));
}

test "ceil64.special" {
    try expect(ceil(0.0) == 0.0);
    try expect(ceil(-0.0) == -0.0);
    try expect(math.isPositiveInf(ceil(math.inf(f64))));
    try expect(math.isNegativeInf(ceil(-math.inf(f64))));
    try expect(math.isNan(ceil(math.nan(f64))));
}

test "ceil80.special" {
    try expect(__ceilx(0.0) == 0.0);
    try expect(__ceilx(-0.0) == -0.0);
    try expect(math.isPositiveInf(__ceilx(math.inf(f80))));
    try expect(math.isNegativeInf(__ceilx(-math.inf(f80))));
    try expect(math.isNan(__ceilx(math.nan(f80))));
}

test "ceil128.special" {
    try expect(ceilq(0.0) == 0.0);
    try expect(ceilq(-0.0) == -0.0);
    try expect(math.isPositiveInf(ceilq(math.inf(f128))));
    try expect(math.isNegativeInf(ceilq(-math.inf(f128))));
    try expect(math.isNan(ceilq(math.nan(f128))));
}
