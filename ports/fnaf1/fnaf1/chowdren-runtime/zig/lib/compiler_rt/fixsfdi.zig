const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");
const intFromFloat = @import("./int_from_float.zig").intFromFloat;
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    if (compiler_rt.want_aeabi) {
        symbol(&__aeabi_f2lz, "__aeabi_f2lz");
    } else {
        if (compiler_rt.want_windows_arm_abi) {
            symbol(&__fixsfdi, "__stoi64");
        }
        symbol(&__fixsfdi, "__fixsfdi");
    }
}

pub fn __fixsfdi(a: f32) callconv(.c) i64 {
    return intFromFloat(i64, a);
}

fn __aeabi_f2lz(a: f32) callconv(.{ .arm_aapcs = .{} }) i64 {
    return intFromFloat(i64, a);
}
