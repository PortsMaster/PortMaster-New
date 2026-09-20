const compiler_rt = @import("../compiler_rt.zig");
const addf3 = @import("./addf3.zig").addf3;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_fadd, "__aeabi_fadd");
    } else {
        symbol(&__addsf3, "__addsf3");
    }
}

fn __addsf3(a: f32, b: f32) callconv(.c) f32 {
    return addf3(f32, a, b);
}

fn __aeabi_fadd(a: f32, b: f32) callconv(.{ .arm_aapcs = .{} }) f32 {
    return addf3(f32, a, b);
}
