const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const maxInt = std.math.maxInt;
const minInt = std.math.minInt;
const divCeil = std.math.divCeil;

const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");

const endian = builtin.cpu.arch.endian();

inline fn limbGet(limbs: []const u64, i: usize) u64 {
    return switch (endian) {
        .little => limbs[i],
        .big => limbs[limbs.len - 1 - i],
    };
}

inline fn limbSet(limbs: []u64, i: usize, value: u64) void {
    switch (endian) {
        .little => limbs[i] = value,
        .big => limbs[limbs.len - 1 - i] = value,
    }
}

fn limbCount(bits: u16) u16 {
    return divCeil(u16, bits, 64) catch unreachable;
}

fn Limbs(T: type) type {
    const int_info = @typeInfo(T).int;
    const limb_cnt = comptime limbCount(int_info.bits);
    return [limb_cnt]u64;
}

fn asLimbs(v: anytype) Limbs(@TypeOf(v)) {
    const T = @TypeOf(v);
    const int_info = @typeInfo(T).int;
    const limb_cnt = comptime limbCount(int_info.bits);
    const ET = @Int(int_info.signedness, limb_cnt * 64);
    return @bitCast(@as(ET, v));
}

fn limbWrap(limb: u64, is_signed: bool, bits: u16) u64 {
    assert(bits % 64 != 0);
    const pad_bits: u6 = @intCast(64 - bits % 64);
    if (!is_signed) {
        const s = limb << pad_bits;
        return s >> pad_bits;
    } else {
        const s = @as(i64, @bitCast(limb)) << pad_bits;
        return @bitCast(s >> pad_bits);
    }
}

comptime {
    @export(&__addo_limb64, .{ .name = "__addo_limb64", .linkage = compiler_rt.linkage, .visibility = compiler_rt.visibility });
}

fn __addo_limb64(out_ptr: [*]u64, a_ptr: [*]const u64, b_ptr: [*]const u64, is_signed: bool, bits: u16) callconv(.c) bool {
    const limb_cnt = limbCount(bits);
    const out = out_ptr[0..limb_cnt];
    const a = a_ptr[0..limb_cnt];
    const b = b_ptr[0..limb_cnt];

    var carry: u1 = 0;
    var i: usize = 0;
    while (i < limb_cnt - 1) : (i += 1) {
        const s1 = @addWithOverflow(limbGet(a, i), limbGet(b, i));
        const s2 = @addWithOverflow(s1[0], carry);
        carry = s1[1] | s2[1];
        limbSet(out, i, s2[0]);
    }

    const limb: u64 = b: {
        if (!is_signed) {
            const s1 = @addWithOverflow(limbGet(a, i), limbGet(b, i));
            const s2 = @addWithOverflow(s1[0], carry);
            carry = s1[1] | s2[1];
            break :b s2[0];
        } else {
            const as: i64 = @bitCast(limbGet(a, i));
            const bs: i64 = @bitCast(limbGet(b, i));
            const s1 = @addWithOverflow(as, bs);
            const s2 = @addWithOverflow(s1[0], carry);
            carry = s1[1] | s2[1];
            break :b @bitCast(s2[0]);
        }
    };

    if (bits % 64 == 0) {
        limbSet(out, i, limb);
        return carry != 0;
    } else {
        assert(carry == 0);
        const wrapped_limb = limbWrap(limb, is_signed, bits);
        limbSet(out, i, wrapped_limb);
        return wrapped_limb != limb;
    }
}

fn test__addo_limb64(comptime T: type, a: T, b: T, expected: struct { T, bool }) !void {
    const int_info = @typeInfo(T).int;
    const is_signed = int_info.signedness == .signed;

    var a_limbs = asLimbs(a);
    var b_limbs = asLimbs(b);
    var out: Limbs(T) = undefined;
    const overflow = __addo_limb64(&out, &a_limbs, &b_limbs, is_signed, int_info.bits);

    const expected_limbs = asLimbs(expected[0]);
    try testing.expectEqual(expected_limbs, out);
    try testing.expectEqual(expected[1], overflow);
}

test __addo_limb64 {
    try test__addo_limb64(u64, 1, 2, .{ 3, false });
    try test__addo_limb64(u64, maxInt(u64), 2, .{ 1, true });
    try test__addo_limb64(u65, maxInt(u65), 2, .{ 1, true });
    try test__addo_limb64(u255, 1, 2, .{ 3, false });

    try test__addo_limb64(i64, 1, 2, .{ 3, false });
    try test__addo_limb64(i64, maxInt(i64), 1, .{ minInt(i64), true });
    try test__addo_limb64(i65, maxInt(i65), 1, .{ minInt(i65), true });
    try test__addo_limb64(i255, -3, 2, .{ -1, false });
}

comptime {
    @export(&__subo_limb64, .{ .name = "__subo_limb64", .linkage = compiler_rt.linkage, .visibility = compiler_rt.visibility });
}

fn __subo_limb64(out_ptr: [*]u64, a_ptr: [*]const u64, b_ptr: [*]const u64, is_signed: bool, bits: u16) callconv(.c) bool {
    const limb_cnt = limbCount(bits);
    const out = out_ptr[0..limb_cnt];
    const a = a_ptr[0..limb_cnt];
    const b = b_ptr[0..limb_cnt];

    var borrow: u1 = 0;
    var i: usize = 0;
    while (i < limb_cnt - 1) : (i += 1) {
        const s1 = @subWithOverflow(limbGet(a, i), limbGet(b, i));
        const s2 = @subWithOverflow(s1[0], borrow);
        borrow = s1[1] | s2[1];
        limbSet(out, i, s2[0]);
    }

    const limb: u64 = b: {
        if (!is_signed) {
            const s1 = @subWithOverflow(limbGet(a, i), limbGet(b, i));
            const s2 = @subWithOverflow(s1[0], borrow);
            borrow = s1[1] | s2[1];
            break :b s2[0];
        } else {
            const as: i64 = @bitCast(limbGet(a, i));
            const bs: i64 = @bitCast(limbGet(b, i));
            const s1 = @subWithOverflow(as, bs);
            const s2 = @subWithOverflow(s1[0], borrow);
            borrow = s1[1] | s2[1];
            break :b @bitCast(s2[0]);
        }
    };

    if (bits % 64 == 0) {
        limbSet(out, i, limb);
        return borrow != 0;
    } else {
        const wrapped_limb = limbWrap(limb, is_signed, bits);
        limbSet(out, i, wrapped_limb);
        return borrow != 0 or wrapped_limb != limb;
    }
}

fn test__subo_limb64(comptime T: type, a: T, b: T, expected: struct { T, bool }) !void {
    const int_info = @typeInfo(T).int;
    const is_signed = int_info.signedness == .signed;

    var a_limbs = asLimbs(a);
    var b_limbs = asLimbs(b);
    var out: Limbs(T) = undefined;
    const overflow = __subo_limb64(&out, &a_limbs, &b_limbs, is_signed, int_info.bits);

    const expected_limbs = asLimbs(expected[0]);
    try testing.expectEqual(expected_limbs, out);
    try testing.expectEqual(expected[1], overflow);
}

test __subo_limb64 {
    try test__subo_limb64(u64, 3, 2, .{ 1, false });
    try test__subo_limb64(u64, 0, 1, .{ maxInt(u64), true });
    try test__subo_limb64(u65, 0, 1, .{ maxInt(u65), true });
    try test__subo_limb64(u255, 3, 2, .{ 1, false });

    try test__subo_limb64(i64, 1, 2, .{ -1, false });
    try test__subo_limb64(i64, minInt(i64), 1, .{ maxInt(i64), true });
    try test__subo_limb64(i65, minInt(i65), 1, .{ maxInt(i65), true });
    try test__subo_limb64(i255, -1, 2, .{ -3, false });
}

comptime {
    @export(&__cmp_limb64, .{ .name = "__cmp_limb64", .linkage = compiler_rt.linkage, .visibility = compiler_rt.visibility });
}

// a < b  -> -1
// a == b ->  0
// a > b  ->  1
fn __cmp_limb64(a_ptr: [*]const u64, b_ptr: [*]const u64, is_signed: bool, bits: u16) callconv(.c) i8 {
    const limb_cnt = limbCount(bits);
    const a = a_ptr[0..limb_cnt];
    const b = b_ptr[0..limb_cnt];

    var i: usize = 0;
    if (is_signed) {
        const sa: i64 = @bitCast(limbGet(a, limb_cnt - 1));
        const sb: i64 = @bitCast(limbGet(b, limb_cnt - 1));
        if (sa < sb) return -1;
        if (sa > sb) return 1;
        i += 1;
    }

    while (i < limb_cnt) : (i += 1) {
        const ai = limbGet(a, limb_cnt - 1 - i);
        const bi = limbGet(b, limb_cnt - 1 - i);
        if (ai < bi) return -1;
        if (ai > bi) return 1;
    }

    return 0;
}

fn test__cmp_limb64(comptime T: type, a: T, b: T, expected: i8) !void {
    const int_info = @typeInfo(T).int;
    const is_signed = int_info.signedness == .signed;

    var a_limbs = asLimbs(a);
    var b_limbs = asLimbs(b);
    const actual = __cmp_limb64(&a_limbs, &b_limbs, is_signed, int_info.bits);

    try testing.expectEqual(expected, actual);
}

test __cmp_limb64 {
    try test__cmp_limb64(u64, 1, 2, -1);
    try test__cmp_limb64(u64, 2, 2, 0);
    try test__cmp_limb64(u64, 3, 2, 1);

    try test__cmp_limb64(u65, 1, 2, -1);
    try test__cmp_limb64(u65, maxInt(u65), maxInt(u65), 0);
    try test__cmp_limb64(u65, maxInt(u65), maxInt(u65) - 1, 1);

    try test__cmp_limb64(u255, 1, 2, -1);
    try test__cmp_limb64(u255, 7, 7, 0);
    try test__cmp_limb64(u255, maxInt(u255), maxInt(u255) - 1, 1);

    try test__cmp_limb64(i64, -1, 0, -1);
    try test__cmp_limb64(i64, 0, 0, 0);
    try test__cmp_limb64(i64, 1, 0, 1);

    try test__cmp_limb64(i65, minInt(i65), maxInt(i65), -1);
    try test__cmp_limb64(i65, -1, -1, 0);
    try test__cmp_limb64(i65, maxInt(i65), minInt(i65), 1);

    try test__cmp_limb64(i255, -3, 2, -1);
    try test__cmp_limb64(i255, -5, -5, 0);
    try test__cmp_limb64(i255, 2, -3, 1);
}
