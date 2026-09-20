const builtin = @import("builtin");
const std = @import("std");
const symbol = @import("../c.zig").symbol;

comptime {
    if (builtin.target.isMuslLibC() or builtin.target.isWasiLibC()) {
        // bcmp is implemented in compiler_rt
        symbol(&bcopy, "bcopy");
        symbol(&bzero, "bzero");
        symbol(&index, "index");
        symbol(&rindex, "rindex");

        symbol(&ffs, "ffs");
        symbol(&ffsl, "ffsl");
        symbol(&ffsll, "ffsll");

        symbol(&strcasecmp, "strcasecmp");
        symbol(&strncasecmp, "strncasecmp");

        symbol(&__strcasecmp_l, "__strcasecmp_l");
        symbol(&__strncasecmp_l, "__strncasecmp_l");

        symbol(&__strcasecmp_l, "strcasecmp_l");
        symbol(&__strncasecmp_l, "strncasecmp_l");
    }
}

fn bcopy(src: *const anyopaque, dst: *anyopaque, len: usize) callconv(.c) void {
    const src_bytes: [*]const u8 = @ptrCast(src);
    const dst_bytes: [*]u8 = @ptrCast(dst);
    @memmove(dst_bytes[0..len], src_bytes[0..len]);
}

fn bzero(s: *anyopaque, n: usize) callconv(.c) void {
    const s_cast: [*]u8 = @ptrCast(s);
    @memset(s_cast[0..n], 0);
}

fn index(str: [*:0]const c_char, value: c_int) callconv(.c) ?[*:0]c_char {
    return @constCast(str[std.mem.findScalar(u8, std.mem.span(@as([*:0]const u8, @ptrCast(str))), @truncate(@as(c_uint, @bitCast(value)))) orelse return null ..]);
}

fn rindex(str: [*:0]const c_char, value: c_int) callconv(.c) ?[*:0]c_char {
    return @constCast(str[std.mem.findScalarLast(u8, std.mem.span(@as([*:0]const u8, @ptrCast(str))), @truncate(@as(c_uint, @bitCast(value)))) orelse return null ..]);
}

fn firstBitSet(comptime T: type, value: T) T {
    return @bitSizeOf(T) - @clz(value);
}

fn ffs(i: c_int) callconv(.c) c_int {
    return firstBitSet(c_int, i);
}

fn ffsl(i: c_long) callconv(.c) c_long {
    return firstBitSet(c_long, i);
}

fn ffsll(i: c_longlong) callconv(.c) c_longlong {
    return firstBitSet(c_longlong, i);
}

fn strcasecmp(a: [*:0]const c_char, b: [*:0]const c_char) callconv(.c) c_int {
    return strncasecmp(a, b, std.math.maxInt(usize));
}

fn __strcasecmp_l(a: [*:0]const c_char, b: [*:0]const c_char, locale: *anyopaque) callconv(.c) c_int {
    _ = locale;
    return strcasecmp(a, b);
}

fn strncasecmp(a: [*:0]const c_char, b: [*:0]const c_char, max: usize) callconv(.c) c_int {
    return switch (std.ascii.boundedOrderIgnoreCaseZ(@ptrCast(a), @ptrCast(b), max)) {
        .eq => 0,
        .gt => 1,
        .lt => -1,
    };
}

fn __strncasecmp_l(a: [*:0]const c_char, b: [*:0]const c_char, n: usize, locale: *anyopaque) callconv(.c) c_int {
    _ = locale;
    return strncasecmp(a, b, n);
}

test bzero {
    var array: [10]u8 = [_]u8{ '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' };
    var a = std.mem.zeroes([array.len]u8);
    a[9] = '0';
    bzero(&array[0], 9);
    try std.testing.expect(std.mem.eql(u8, &array, &a));
}

test firstBitSet {
    try std.testing.expectEqual(0, firstBitSet(usize, 0));

    for (0..@bitSizeOf(usize)) |i| {
        const bit = @as(usize, 1) << @intCast(i);

        try std.testing.expectEqual(i + 1, firstBitSet(usize, bit));
    }
}

test strcasecmp {
    try std.testing.expect(strcasecmp(@ptrCast("a"), @ptrCast("b")) < 0);
    try std.testing.expect(strcasecmp(@ptrCast("b"), @ptrCast("a")) > 0);
    try std.testing.expect(strcasecmp(@ptrCast("A"), @ptrCast("b")) < 0);
    try std.testing.expect(strcasecmp(@ptrCast("b"), @ptrCast("A")) > 0);
    try std.testing.expect(strcasecmp(@ptrCast("A"), @ptrCast("A")) == 0);
    try std.testing.expect(strcasecmp(@ptrCast("B"), @ptrCast("b")) == 0);
    try std.testing.expect(strcasecmp(@ptrCast("bb"), @ptrCast("AA")) > 0);
}

test strncasecmp {
    try std.testing.expect(strncasecmp(@ptrCast("a"), @ptrCast("b"), 1) < 0);
    try std.testing.expect(strncasecmp(@ptrCast("b"), @ptrCast("a"), 1) > 0);
    try std.testing.expect(strncasecmp(@ptrCast("A"), @ptrCast("b"), 1) < 0);
    try std.testing.expect(strncasecmp(@ptrCast("b"), @ptrCast("A"), 1) > 0);
    try std.testing.expect(strncasecmp(@ptrCast("A"), @ptrCast("A"), 1) == 0);
    try std.testing.expect(strncasecmp(@ptrCast("B"), @ptrCast("b"), 1) == 0);
    try std.testing.expect(strncasecmp(@ptrCast("bb"), @ptrCast("AA"), 2) > 0);
}
