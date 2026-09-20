const compiler_rt = @import("../compiler_rt.zig");
const addf3 = @import("./addf3.zig").addf3;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_dadd, "__aeabi_dadd");
    } else {
        symbol(&__adddf3, "__adddf3");
    }
}

fn __adddf3(a: f64, b: f64) callconv(.c) f64 {
    return addf3(f64, a, b);
}

fn __aeabi_dadd(a: f64, b: f64) callconv(.{ .arm_aapcs = .{} }) f64 {
    return addf3(f64, a, b);
}
