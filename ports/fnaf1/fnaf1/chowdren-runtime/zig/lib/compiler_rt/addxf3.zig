const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;
const addf3 = @import("./addf3.zig").addf3;

comptime {
    symbol(&__addxf3, "__addxf3");
}

pub fn __addxf3(a: f80, b: f80) callconv(.c) f80 {
    return addf3(f80, a, b);
}
