const std = @import("std");

const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_fcmpun, "__aeabi_fcmpun");
    } else {
        symbol(&__unordsf2, "__unordsf2");
    }

    symbol(&__unordxf2, "__unordxf2");

    symbol(&__eqhf2, "__eqhf2");
    symbol(&__nehf2, "__nehf2");
    symbol(&__lehf2, "__lehf2");
    symbol(&__cmphf2, "__cmphf2");
    symbol(&__lthf2, "__lthf2");

    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_fcmpeq, "__aeabi_fcmpeq");
        symbol(&__aeabi_fcmplt, "__aeabi_fcmplt");
        symbol(&__aeabi_fcmple, "__aeabi_fcmple");
    } else {
        symbol(&__eqsf2, "__eqsf2");
        symbol(&__nesf2, "__nesf2");
        symbol(&__lesf2, "__lesf2");
        symbol(&__cmpsf2, "__cmpsf2");
        symbol(&__ltsf2, "__ltsf2");
    }

    if (compiler_rt.want_ppc_abi) {
        symbol(&__unordtf2, "__unordkf2");
    } else if (compiler_rt.want_sparc_abi) {
        // These exports are handled in cmptf2.zig because unordered comparisons
        // are based on calling _Qp_cmp.
    }
    symbol(&__unordtf2, "__unordtf2");
    symbol(&__unordhf2, "__unordhf2");
}

pub fn __unordhf2(a: f16, b: f16) callconv(.c) i32 {
    return unordcmp(f16, a, b);
}

pub fn __unordtf2(a: f128, b: f128) callconv(.c) i32 {
    return unordcmp(f128, a, b);
}

/// "These functions calculate a <=> b. That is, if a is less than b, they return -1;
/// if a is greater than b, they return 1; and if a and b are equal they return 0.
/// If either argument is NaN they return 1..."
///
/// Note that this matches the definition of `__lesf2`, `__eqsf2`, `__nesf2`, `__cmpsf2`,
/// and `__ltsf2`.
fn __cmpsf2(a: f32, b: f32) callconv(.c) i32 {
    return @intFromEnum(cmpf2(f32, LE, a, b));
}

/// "These functions return a value less than or equal to zero if neither argument is NaN,
/// and a is less than or equal to b."
pub fn __lesf2(a: f32, b: f32) callconv(.c) i32 {
    return __cmpsf2(a, b);
}

/// "These functions return zero if neither argument is NaN, and a and b are equal."
/// Note that due to some kind of historical accident, __eqsf2 and __nesf2 are defined
/// to have the same return value.
pub fn __eqsf2(a: f32, b: f32) callconv(.c) i32 {
    return __cmpsf2(a, b);
}

/// "These functions return a nonzero value if either argument is NaN, or if a and b are unequal."
/// Note that due to some kind of historical accident, __eqsf2 and __nesf2 are defined
/// to have the same return value.
pub fn __nesf2(a: f32, b: f32) callconv(.c) i32 {
    return __cmpsf2(a, b);
}

/// "These functions return a value less than zero if neither argument is NaN, and a
/// is strictly less than b."
pub fn __ltsf2(a: f32, b: f32) callconv(.c) i32 {
    return __cmpsf2(a, b);
}

fn __aeabi_fcmpeq(a: f32, b: f32) callconv(.{ .arm_aapcs = .{} }) i32 {
    return @intFromBool(cmpf2(f32, LE, a, b) == .Equal);
}

fn __aeabi_fcmplt(a: f32, b: f32) callconv(.{ .arm_aapcs = .{} }) i32 {
    return @intFromBool(cmpf2(f32, LE, a, b) == .Less);
}

fn __aeabi_fcmple(a: f32, b: f32) callconv(.{ .arm_aapcs = .{} }) i32 {
    return @intFromBool(cmpf2(f32, LE, a, b) != .Greater);
}

/// "These functions calculate a <=> b. That is, if a is less than b, they return -1;
/// if a is greater than b, they return 1; and if a and b are equal they return 0.
/// If either argument is NaN they return 1..."
///
/// Note that this matches the definition of `__lehf2`, `__eqhf2`, `__nehf2`, `__cmphf2`,
/// and `__lthf2`.
fn __cmphf2(a: f16, b: f16) callconv(.c) i32 {
    return @intFromEnum(cmpf2(f16, LE, a, b));
}

/// "These functions return a value less than or equal to zero if neither argument is NaN,
/// and a is less than or equal to b."
fn __lehf2(a: f16, b: f16) callconv(.c) i32 {
    return __cmphf2(a, b);
}

/// "These functions return zero if neither argument is NaN, and a and b are equal."
/// Note that due to some kind of historical accident, __eqhf2 and __nehf2 are defined
/// to have the same return value.
fn __eqhf2(a: f16, b: f16) callconv(.c) i32 {
    return __cmphf2(a, b);
}

/// "These functions return a nonzero value if either argument is NaN, or if a and b are unequal."
/// Note that due to some kind of historical accident, __eqhf2 and __nehf2 are defined
/// to have the same return value.
fn __nehf2(a: f16, b: f16) callconv(.c) i32 {
    return __cmphf2(a, b);
}

/// "These functions return a value less than zero if neither argument is NaN, and a
/// is strictly less than b."
fn __lthf2(a: f16, b: f16) callconv(.c) i32 {
    return __cmphf2(a, b);
}

fn __unordxf2(a: f80, b: f80) callconv(.c) i32 {
    return unordcmp(f80, a, b);
}

pub fn __unordsf2(a: f32, b: f32) callconv(.c) i32 {
    return unordcmp(f32, a, b);
}

fn __aeabi_fcmpun(a: f32, b: f32) callconv(.{ .arm_aapcs = .{} }) i32 {
    return unordcmp(f32, a, b);
}

pub const LE = enum(i32) {
    Less = -1,
    Equal = 0,
    Greater = 1,

    const Unordered: LE = .Greater;
};

pub const GE = enum(i32) {
    Less = -1,
    Equal = 0,
    Greater = 1,

    const Unordered: GE = .Less;
};

pub inline fn cmpf2(comptime T: type, comptime RT: type, a: T, b: T) RT {
    const bits = @typeInfo(T).float.bits;
    const srep_t = std.meta.Int(.signed, bits);
    const rep_t = std.meta.Int(.unsigned, bits);

    const significandBits = std.math.floatMantissaBits(T);
    const exponentBits = std.math.floatExponentBits(T);
    const signBit = (@as(rep_t, 1) << (significandBits + exponentBits));
    const absMask = signBit - 1;
    const infT = comptime std.math.inf(T);
    const infRep = @as(rep_t, @bitCast(infT));

    const aInt = @as(srep_t, @bitCast(a));
    const bInt = @as(srep_t, @bitCast(b));
    const aAbs = @as(rep_t, @bitCast(aInt)) & absMask;
    const bAbs = @as(rep_t, @bitCast(bInt)) & absMask;

    // If either a or b is NaN, they are unordered.
    if (aAbs > infRep or bAbs > infRep) return RT.Unordered;

    // If a and b are both zeros, they are equal.
    if ((aAbs | bAbs) == 0) return .Equal;

    // If at least one of a and b is positive, we get the same result comparing
    // a and b as signed integers as we would with a floating-point compare.
    if ((aInt & bInt) >= 0) {
        if (aInt < bInt) {
            return .Less;
        } else if (aInt == bInt) {
            return .Equal;
        } else return .Greater;
    } else {
        // Otherwise, both are negative, so we need to flip the sense of the
        // comparison to get the correct result.  (This assumes a twos- or ones-
        // complement integer representation; if integers are represented in a
        // sign-magnitude representation, then this flip is incorrect).
        if (aInt > bInt) {
            return .Less;
        } else if (aInt == bInt) {
            return .Equal;
        } else return .Greater;
    }
}

pub inline fn cmp_f80(comptime RT: type, a: f80, b: f80) RT {
    const a_rep = std.math.F80.fromFloat(a);
    const b_rep = std.math.F80.fromFloat(b);
    const sig_bits = std.math.floatMantissaBits(f80);
    const int_bit = 0x8000000000000000;
    const sign_bit = 0x8000;
    const special_exp = 0x7FFF;

    // If either a or b is NaN, they are unordered.
    if ((a_rep.exp & special_exp == special_exp and a_rep.fraction ^ int_bit != 0) or
        (b_rep.exp & special_exp == special_exp and b_rep.fraction ^ int_bit != 0))
        return RT.Unordered;

    // If a and b are both zeros, they are equal.
    if ((a_rep.fraction | b_rep.fraction) | ((a_rep.exp | b_rep.exp) & special_exp) == 0)
        return .Equal;

    if (@intFromBool(a_rep.exp == b_rep.exp) & @intFromBool(a_rep.fraction == b_rep.fraction) != 0) {
        return .Equal;
    } else if (a_rep.exp & sign_bit != b_rep.exp & sign_bit) {
        // signs are different
        if (@as(i16, @bitCast(a_rep.exp)) < @as(i16, @bitCast(b_rep.exp))) {
            return .Less;
        } else {
            return .Greater;
        }
    } else {
        const a_fraction = a_rep.fraction | (@as(u80, a_rep.exp) << sig_bits);
        const b_fraction = b_rep.fraction | (@as(u80, b_rep.exp) << sig_bits);
        if ((a_fraction < b_fraction) == (a_rep.exp & sign_bit == 0)) {
            return .Less;
        } else {
            return .Greater;
        }
    }
}

test "cmp_f80" {
    inline for (.{ LE, GE }) |RT| {
        try std.testing.expect(cmp_f80(RT, 1.0, 1.0) == RT.Equal);
        try std.testing.expect(cmp_f80(RT, 0.0, -0.0) == RT.Equal);
        try std.testing.expect(cmp_f80(RT, 2.0, 4.0) == RT.Less);
        try std.testing.expect(cmp_f80(RT, 2.0, -4.0) == RT.Greater);
        try std.testing.expect(cmp_f80(RT, -2.0, -4.0) == RT.Greater);
        try std.testing.expect(cmp_f80(RT, -2.0, 4.0) == RT.Less);
    }
}

pub inline fn unordcmp(comptime T: type, a: T, b: T) i32 {
    const rep_t = std.meta.Int(.unsigned, @typeInfo(T).float.bits);

    const significandBits = std.math.floatMantissaBits(T);
    const exponentBits = std.math.floatExponentBits(T);
    const signBit = (@as(rep_t, 1) << (significandBits + exponentBits));
    const absMask = signBit - 1;
    const infRep = @as(rep_t, @bitCast(std.math.inf(T)));

    const aAbs: rep_t = @as(rep_t, @bitCast(a)) & absMask;
    const bAbs: rep_t = @as(rep_t, @bitCast(b)) & absMask;

    return @intFromBool(aAbs > infRep or bAbs > infRep);
}

test {
    _ = @import("comparesf2_test.zig");
    _ = @import("comparedf2_test.zig");
}
