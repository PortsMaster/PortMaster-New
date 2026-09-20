//! Utilities for dealing with the `long double` type (`f80` or `f128`)

const std = @import("std");

pub const U80 = std.meta.Int(.unsigned, 80);

/// Returns the sign + exponent bits of a `long double`
pub fn signExponent(x: anytype) u16 {
    const T = @TypeOf(x);
    switch (T) {
        f80 => {
            const bits: U80 = @bitCast(x);
            return @intCast(bits >> 64);
        },
        f128 => {
            const bits: u128 = @bitCast(x);
            return @intCast(bits >> 112);
        },
        else => @compileError("`signExponent` supports only `f80` and `f128`, got: " ++ @typeName(T)),
    }
}

/// Takes the top 16 bits of a `long double`'s mantissa
pub fn mantissaTop(x: anytype) u16 {
    const T = @TypeOf(x);
    switch (T) {
        f80 => {
            const bits: U80 = @bitCast(x);
            return @intCast((bits >> 48) & 0xFFFF);
        },
        f128 => {
            const bits: u128 = @bitCast(x);
            return @intCast((bits >> 96) & 0xFFFF);
        },
        else => @compileError("`mantissaTop` supports only `f80` and `f128`, got: " ++ @typeName(T)),
    }
}
