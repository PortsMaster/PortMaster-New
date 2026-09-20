//! negv - negate oVerflow
//! * @panic, if result can not be represented
//! - negvXi4_generic for unoptimized version
const std = @import("std");
const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;

comptime {
    symbol(&__negvsi2, "__negvsi2");
    symbol(&__negvdi2, "__negvdi2");
    symbol(&__negvti2, "__negvti2");
}

pub fn __negvsi2(a: i32) callconv(.c) i32 {
    return negvXi(i32, a);
}

pub fn __negvdi2(a: i64) callconv(.c) i64 {
    return negvXi(i64, a);
}

pub fn __negvti2(a: i128) callconv(.c) i128 {
    return negvXi(i128, a);
}

inline fn negvXi(comptime ST: type, a: ST) ST {
    const UT = switch (ST) {
        i32 => u32,
        i64 => u64,
        i128 => u128,
        else => unreachable,
    };
    const N: UT = @bitSizeOf(ST);
    const min: ST = @as(ST, @bitCast((@as(UT, 1) << (N - 1))));
    if (a == min)
        @panic("compiler_rt negv: overflow");
    return -a;
}

test {
    _ = @import("negvsi2_test.zig");
    _ = @import("negvdi2_test.zig");
    _ = @import("negvti2_test.zig");
}
