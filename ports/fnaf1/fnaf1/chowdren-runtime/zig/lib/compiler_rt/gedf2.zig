///! The quoted behavior definitions are from
///! https://gcc.gnu.org/onlinedocs/gcc-12.1.0/gccint/Soft-float-library-routines.html#Soft-float-library-routines
const compiler_rt = @import("../compiler_rt.zig");
const comparef = @import("./comparef.zig");
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_dcmpge, "__aeabi_dcmpge");
        symbol(&__aeabi_dcmpgt, "__aeabi_dcmpgt");
    } else {
        symbol(&__gedf2, "__gedf2");
        symbol(&__gtdf2, "__gtdf2");
    }
}

/// "These functions return a value greater than or equal to zero if neither
/// argument is NaN, and a is greater than or equal to b."
pub fn __gedf2(a: f64, b: f64) callconv(.c) i32 {
    return @intFromEnum(comparef.cmpf2(f64, comparef.GE, a, b));
}

/// "These functions return a value greater than zero if neither argument is NaN,
/// and a is strictly greater than b."
pub fn __gtdf2(a: f64, b: f64) callconv(.c) i32 {
    return __gedf2(a, b);
}

fn __aeabi_dcmpge(a: f64, b: f64) callconv(.{ .arm_aapcs = .{} }) i32 {
    return @intFromBool(comparef.cmpf2(f64, comparef.GE, a, b) != .Less);
}

fn __aeabi_dcmpgt(a: f64, b: f64) callconv(.{ .arm_aapcs = .{} }) i32 {
    return @intFromBool(comparef.cmpf2(f64, comparef.GE, a, b) == .Greater);
}
