///! The quoted behavior definitions are from
///! https://gcc.gnu.org/onlinedocs/gcc-12.1.0/gccint/Soft-float-library-routines.html#Soft-float-library-routines
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const comparef = @import("./comparef.zig");

comptime {
    if (compiler_rt.want_ppc_abi) {
        symbol(&__getf2, "__gekf2");
        symbol(&__gttf2, "__gtkf2");
    } else if (compiler_rt.want_sparc_abi) {
        // These exports are handled in cmptf2.zig because gt and ge on sparc
        // are based on calling _Qp_cmp.
    }
    symbol(&__getf2, "__getf2");
    symbol(&__gttf2, "__gttf2");
}

/// "These functions return a value greater than or equal to zero if neither
/// argument is NaN, and a is greater than or equal to b."
fn __getf2(a: f128, b: f128) callconv(.c) i32 {
    return @intFromEnum(comparef.cmpf2(f128, comparef.GE, a, b));
}

/// "These functions return a value greater than zero if neither argument is NaN,
/// and a is strictly greater than b."
fn __gttf2(a: f128, b: f128) callconv(.c) i32 {
    return __getf2(a, b);
}
