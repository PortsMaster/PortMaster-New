const symbol = @import("../compiler_rt.zig").symbol;
const comparef = @import("./comparef.zig");

comptime {
    symbol(&__gexf2, "__gexf2");
    symbol(&__gtxf2, "__gtxf2");
}

fn __gexf2(a: f80, b: f80) callconv(.c) i32 {
    return @intFromEnum(comparef.cmp_f80(comparef.GE, a, b));
}

fn __gtxf2(a: f80, b: f80) callconv(.c) i32 {
    return __gexf2(a, b);
}
