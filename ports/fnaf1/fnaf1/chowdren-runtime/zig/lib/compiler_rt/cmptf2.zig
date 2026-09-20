///! The quoted behavior definitions are from
///! https://gcc.gnu.org/onlinedocs/gcc-12.1.0/gccint/Soft-float-library-routines.html#Soft-float-library-routines
const compiler_rt = @import("../compiler_rt.zig");
const comparef = @import("./comparef.zig");
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__eqtf2, "__eqkf2");
        symbol(&__netf2, "__nekf2");
        symbol(&__lttf2, "__ltkf2");
        symbol(&__letf2, "__lekf2");
    } else if (compiler_rt.want_sparc_abi) {
        symbol(&_Qp_cmp, "_Qp_cmp");
        symbol(&_Qp_feq, "_Qp_feq");
        symbol(&_Qp_fne, "_Qp_fne");
        symbol(&_Qp_flt, "_Qp_flt");
        symbol(&_Qp_fle, "_Qp_fle");
        symbol(&_Qp_fgt, "_Qp_fgt");
        symbol(&_Qp_fge, "_Qp_fge");
    }
    symbol(&__eqtf2, "__eqtf2");
    symbol(&__netf2, "__netf2");
    symbol(&__letf2, "__letf2");
    symbol(&__cmptf2, "__cmptf2");
    symbol(&__lttf2, "__lttf2");
}

/// "These functions calculate a <=> b. That is, if a is less than b, they return -1;
/// if a is greater than b, they return 1; and if a and b are equal they return 0.
/// If either argument is NaN they return 1..."
///
/// Note that this matches the definition of `__letf2`, `__eqtf2`, `__netf2`, `__cmptf2`,
/// and `__lttf2`.
fn __cmptf2(a: f128, b: f128) callconv(.c) i32 {
    return @intFromEnum(comparef.cmpf2(f128, comparef.LE, a, b));
}

/// "These functions return a value less than or equal to zero if neither argument is NaN,
/// and a is less than or equal to b."
fn __letf2(a: f128, b: f128) callconv(.c) i32 {
    return __cmptf2(a, b);
}

/// "These functions return zero if neither argument is NaN, and a and b are equal."
/// Note that due to some kind of historical accident, __eqtf2 and __netf2 are defined
/// to have the same return value.
fn __eqtf2(a: f128, b: f128) callconv(.c) i32 {
    return __cmptf2(a, b);
}

/// "These functions return a nonzero value if either argument is NaN, or if a and b are unequal."
/// Note that due to some kind of historical accident, __eqtf2 and __netf2 are defined
/// to have the same return value.
fn __netf2(a: f128, b: f128) callconv(.c) i32 {
    return __cmptf2(a, b);
}

/// "These functions return a value less than zero if neither argument is NaN, and a
/// is strictly less than b."
fn __lttf2(a: f128, b: f128) callconv(.c) i32 {
    return __cmptf2(a, b);
}

const SparcFCMP = enum(i32) {
    Equal = 0,
    Less = 1,
    Greater = 2,
    Unordered = 3,
};

fn _Qp_cmp(a: *const f128, b: *const f128) callconv(.c) i32 {
    return @intFromEnum(comparef.cmpf2(f128, SparcFCMP, a.*, b.*));
}

fn _Qp_feq(a: *const f128, b: *const f128) callconv(.c) bool {
    return @as(SparcFCMP, @enumFromInt(_Qp_cmp(a, b))) == .Equal;
}

fn _Qp_fne(a: *const f128, b: *const f128) callconv(.c) bool {
    return @as(SparcFCMP, @enumFromInt(_Qp_cmp(a, b))) != .Equal;
}

fn _Qp_flt(a: *const f128, b: *const f128) callconv(.c) bool {
    return @as(SparcFCMP, @enumFromInt(_Qp_cmp(a, b))) == .Less;
}

fn _Qp_fgt(a: *const f128, b: *const f128) callconv(.c) bool {
    return @as(SparcFCMP, @enumFromInt(_Qp_cmp(a, b))) == .Greater;
}

fn _Qp_fge(a: *const f128, b: *const f128) callconv(.c) bool {
    return switch (@as(SparcFCMP, @enumFromInt(_Qp_cmp(a, b)))) {
        .Equal, .Greater => true,
        .Less, .Unordered => false,
    };
}

fn _Qp_fle(a: *const f128, b: *const f128) callconv(.c) bool {
    return switch (@as(SparcFCMP, @enumFromInt(_Qp_cmp(a, b)))) {
        .Equal, .Less => true,
        .Greater, .Unordered => false,
    };
}
