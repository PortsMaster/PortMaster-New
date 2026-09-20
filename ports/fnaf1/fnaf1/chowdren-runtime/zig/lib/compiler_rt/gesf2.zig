///! The quoted behavior definitions are from
///! https://gcc.gnu.org/onlinedocs/gcc-12.1.0/gccint/Soft-float-library-routines.html#Soft-float-library-routines
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const comparef = @import("./comparef.zig");

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_fcmpge, "__aeabi_fcmpge");
        symbol(&__aeabi_fcmpgt, "__aeabi_fcmpgt");
    } else {
        symbol(&__gesf2, "__gesf2");
        symbol(&__gtsf2, "__gtsf2");
    }
}

/// "These functions return a value greater than or equal to zero if neither
/// argument is NaN, and a is greater than or equal to b."
pub fn __gesf2(a: f32, b: f32) callconv(.c) i32 {
    return @intFromEnum(comparef.cmpf2(f32, comparef.GE, a, b));
}

/// "These functions return a value greater than zero if neither argument is NaN,
/// and a is strictly greater than b."
pub fn __gtsf2(a: f32, b: f32) callconv(.c) i32 {
    return __gesf2(a, b);
}

fn __aeabi_fcmpge(a: f32, b: f32) callconv(.{ .arm_aapcs = .{} }) i32 {
    return @intFromBool(comparef.cmpf2(f32, comparef.GE, a, b) != .Less);
}

fn __aeabi_fcmpgt(a: f32, b: f32) callconv(.{ .arm_aapcs = .{} }) i32 {
    return @intFromBool(comparef.cmpf2(f32, comparef.LE, a, b) == .Greater);
}
