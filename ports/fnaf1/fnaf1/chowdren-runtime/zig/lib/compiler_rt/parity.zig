//! parity - if number of bits set is even => 0, else => 1
//! - pariytXi2_generic for big and little endian
const symbol = @import("../compiler_rt.zig").symbol;

comptime {
    symbol(&__paritysi2, "__paritysi2");
    symbol(&__paritydi2, "__paritydi2");
    symbol(&__parityti2, "__parityti2");
}

pub fn __paritysi2(a: i32) callconv(.c) i32 {
    return parityXi2(i32, a);
}

pub fn __paritydi2(a: i64) callconv(.c) i32 {
    return parityXi2(i64, a);
}

pub fn __parityti2(a: i128) callconv(.c) i32 {
    return parityXi2(i128, a);
}

inline fn parityXi2(comptime T: type, a: T) i32 {
    var x: @Int(.unsigned, @typeInfo(T).int.bits) = @bitCast(a);
    // Bit Twiddling Hacks: Compute parity in parallel
    comptime var shift: u8 = @bitSizeOf(T) / 2;
    inline while (shift > 2) {
        x ^= x >> shift;
        shift = shift >> 1;
    }
    x &= 0xf;
    return (@as(u16, 0x6996) >> @intCast(x)) & 1; // optimization for >>2 and >>1
}

test {
    _ = @import("paritysi2_test.zig");
    _ = @import("paritydi2_test.zig");
    _ = @import("parityti2_test.zig");
}
