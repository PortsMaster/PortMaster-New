const std = @import("std");
const builtin = @import("builtin");
const Log2Int = std.math.Log2Int;
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;

comptime {
    // symbol compatibility with libgcc
    symbol(&__ashlsi3, "__ashlsi3");
    symbol(&__ashrsi3, "__ashrsi3");
    symbol(&__lshrsi3, "__lshrsi3");

    symbol(&__ashlti3, "__ashlti3");
    symbol(&__ashrti3, "__ashrti3");
    symbol(&__lshrti3, "__lshrti3");

    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_llsl, "__aeabi_llsl");
        symbol(&__aeabi_lasr, "__aeabi_lasr");
        symbol(&__aeabi_llsr, "__aeabi_llsr");
    } else {
        symbol(&__ashldi3, "__ashldi3");
        symbol(&__ashrdi3, "__ashrdi3");
        symbol(&__lshrdi3, "__lshrdi3");
    }
}

// Arithmetic shift left: shift in 0 from right to left
// Precondition: 0 <= b < bits_in_dword
inline fn ashlXi3(comptime T: type, a: T, b: i32) T {
    const word_t = compiler_rt.HalveInt(T, false);

    const input = word_t{ .all = a };
    var output: word_t = undefined;

    if (b >= word_t.bits) {
        output.s.low = 0;
        output.s.high = input.s.low << @intCast(b - word_t.bits);
    } else if (b == 0) {
        return a;
    } else {
        output.s.low = input.s.low << @intCast(b);
        output.s.high = input.s.high << @intCast(b);
        output.s.high |= input.s.low >> @intCast(word_t.bits - b);
    }

    return output.all;
}

// Arithmetic shift right: shift in 1 from left to right
// Precondition: 0 <= b < T.bit_count
inline fn ashrXi3(comptime T: type, a: T, b: i32) T {
    const word_t = compiler_rt.HalveInt(T, true);

    const input = word_t{ .all = a };
    var output: word_t = undefined;

    if (b >= word_t.bits) {
        output.s.high = input.s.high >> (word_t.bits - 1);
        output.s.low = input.s.high >> @intCast(b - word_t.bits);
    } else if (b == 0) {
        return a;
    } else {
        output.s.high = input.s.high >> @intCast(b);
        output.s.low = input.s.high << @intCast(word_t.bits - b);
        // Avoid sign-extension here
        output.s.low |= @bitCast(@as(word_t.HalfTU, @bitCast(input.s.low)) >> @intCast(b));
    }

    return output.all;
}

// Logical shift right: shift in 0 from left to right
// Precondition: 0 <= b < T.bit_count
inline fn lshrXi3(comptime T: type, a: T, b: i32) T {
    const word_t = compiler_rt.HalveInt(T, false);

    const input = word_t{ .all = a };
    var output: word_t = undefined;

    if (b >= word_t.bits) {
        output.s.high = 0;
        output.s.low = input.s.high >> @intCast(b - word_t.bits);
    } else if (b == 0) {
        return a;
    } else {
        output.s.high = input.s.high >> @intCast(b);
        output.s.low = input.s.high << @intCast(word_t.bits - b);
        output.s.low |= input.s.low >> @intCast(b);
    }

    return output.all;
}

pub fn __ashlsi3(a: i32, b: i32) callconv(.c) i32 {
    return ashlXi3(i32, a, b);
}

pub fn __ashrsi3(a: i32, b: i32) callconv(.c) i32 {
    return ashrXi3(i32, a, b);
}

pub fn __lshrsi3(a: i32, b: i32) callconv(.c) i32 {
    return lshrXi3(i32, a, b);
}

pub fn __ashldi3(a: i64, b: i32) callconv(.c) i64 {
    return ashlXi3(i64, a, b);
}
fn __aeabi_llsl(a: i64, b: i32) callconv(.{ .arm_aapcs = .{} }) i64 {
    return ashlXi3(i64, a, b);
}

pub fn __ashlti3(a: i128, b: i32) callconv(.c) i128 {
    return ashlXi3(i128, a, b);
}

pub fn __ashrdi3(a: i64, b: i32) callconv(.c) i64 {
    return ashrXi3(i64, a, b);
}
fn __aeabi_lasr(a: i64, b: i32) callconv(.{ .arm_aapcs = .{} }) i64 {
    return ashrXi3(i64, a, b);
}

pub fn __ashrti3(a: i128, b: i32) callconv(.c) i128 {
    return ashrXi3(i128, a, b);
}

pub fn __lshrdi3(a: i64, b: i32) callconv(.c) i64 {
    return lshrXi3(i64, a, b);
}
fn __aeabi_llsr(a: i64, b: i32) callconv(.{ .arm_aapcs = .{} }) i64 {
    return lshrXi3(i64, a, b);
}

pub fn __lshrti3(a: i128, b: i32) callconv(.c) i128 {
    return lshrXi3(i128, a, b);
}

test {
    _ = @import("shift_test.zig");
}
