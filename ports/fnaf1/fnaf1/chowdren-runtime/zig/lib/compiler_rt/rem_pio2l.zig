// Ported from musl, which is licensed under the MIT license:
// https://git.musl-libc.org/cgit/musl/tree/COPYRIGHT
//
// https://git.musl-libc.org/cgit/musl/tree/src/math/__rem_pio2l.c

const std = @import("std");
const math = std.math;

const ld = @import("long_double.zig");
const rem_pio2_large = @import("rem_pio2_large.zig").rem_pio2_large;

pub fn rem_pio2l(comptime T: type, x: T, y: *[2]T) i32 {
    const impl = switch (T) {
        f80 => struct {
            const round1: i8 = 22;
            const round2: i8 = 61;
            const nx: i8 = 3;
            const ny: i8 = 2;

            const pio4: T = 0x1.921fb54442d1846ap-1;
            // 64 bits of 2/pi
            const invpio2: T = 6.36619772367581343076e-01; // 0xa2f9836e4e44152a.0p-64
            // first  39 bits of pi/2
            const pio2_1: f64 = 1.57079632679597125389e+00; // 0x3FF921FB, 0x54444000
            // pi/2 - pio2_1
            const pio2_1t: T = -1.07463465549719416346e-12; // -0x973dcb3b399d747f.0p-103
            // second 39 bits of pi/2
            const pio2_2: f64 = -1.07463465549783099519e-12; // -0x12e7b967674000.0p-92
            // pi/2 - (pio2_1+pio2_2)
            const pio2_2t: T = 6.36831716351095013979e-25; // 0xc51701b839a25205.0p-144
            // pi/2 - (pio2_1+pio2_2+pio2_3)
            const pio2_3t: T = -2.75299651904407171810e-37; // -0xbb5bf6c7ddd660ce.0p-185
            // third  39 bits of pi/2
            const pio2_3: f64 = 6.36831716351370313614e-25; // 0x18a2e037074000.0p-133

            fn small(x_val: T) bool {
                const se = ld.signExponent(x_val);
                const top = ld.mantissaTop(x_val);
                const lhs = (@as(u32, se & 0x7fff) << 16) | top;
                const rhs: u32 = ((0x3fff + 25) << 16) | 0x921f >> 1 | 0x8000;
                return lhs < rhs;
            }

            fn quobits(v: T) i32 {
                const q: i32 = @intFromFloat(v);
                return @intCast(@as(u32, @bitCast(q)) & 0x7fffffff);
            }
        },
        f128 => struct {
            const round1: i8 = 51;
            const round2: i8 = 119;
            const nx: i8 = 5;
            const ny: i8 = 3;

            const pio4: T = 0x1.921fb54442d18469898cc51701b8p-1;
            const invpio2: T = 6.3661977236758134307553505349005747e-01;
            const pio2_1: T = 1.5707963267948966192292994253909555e+00;
            const pio2_1t: T = 2.0222662487959507323996846200947577e-21;
            const pio2_2: T = 2.0222662487959507323994779168837751e-21;
            const pio2_2t: T = 2.0670321098263988236496903051604844e-43;
            const pio2_3: T = 2.0670321098263988236499468110329591e-43;
            const pio2_3t: T = -2.5650587247459238361625433492959285e-65;

            fn small(x_val: T) bool {
                const se = ld.signExponent(x_val);
                const top = ld.mantissaTop(x_val);
                const lhs = (@as(u32, se & 0x7fff) << 16) | top;
                const rhs: u32 = ((0x3fff + 45) << 16) | 0x921f;
                return lhs < rhs;
            }

            fn quobits(fn_val: T) i32 {
                const q: i64 = @intFromFloat(fn_val);
                return @intCast(@as(u64, @bitCast(q)) & 0x7fffffff);
            }
        },
        else => @compileError("rem_pio2l supports only f80 and f128, got: " ++ @typeName(T)),
    };

    const x_se = ld.signExponent(x);
    const ex: i32 = @intCast(x_se & 0x7fff);

    if (impl.small(x)) {
        // rint(x/(pi/2))
        const toint: T = 1.5 / math.floatEps(T);
        var fn_ = x * impl.invpio2 + toint - toint;
        var n = impl.quobits(fn_);
        var r = x - fn_ * @as(T, impl.pio2_1);
        var w = fn_ * impl.pio2_1t; // 1st round good to 102/180 bits

        // Matters with directed rounding.
        if (r - w < -impl.pio4) {
            @branchHint(.unlikely);
            n -= 1;
            fn_ -= 1;
            r = x - fn_ * @as(T, impl.pio2_1);
            w = fn_ * impl.pio2_1t;
        } else if (r - w > impl.pio4) {
            @branchHint(.unlikely);
            n += 1;
            fn_ += 1;
            r = x - fn_ * @as(T, impl.pio2_1);
            w = fn_ * impl.pio2_1t;
        }

        y[0] = r - w;

        const ey: i32 = @intCast(ld.signExponent(y[0]) & 0x7fff);
        if (ex - ey > impl.round1) {
            var t = r;
            w = fn_ * impl.pio2_2;
            r = t - w;
            w = fn_ * impl.pio2_2t - ((t - r) - w);
            y[0] = r - w;
            const ey2: i32 = @intCast(ld.signExponent(y[0]) & 0x7fff);
            if (ex - ey2 > impl.round2) {
                t = r;
                w = fn_ * impl.pio2_3;
                r = t - w;
                w = fn_ * impl.pio2_3t - ((t - r) - w);
                y[0] = r - w;
            }
        }
        y[1] = (r - y[0]) - w;
        return n;
    }

    // all other (large) arguments
    if (ex == 0x7fff) { // x is inf or NaN
        y[0] = x - x;
        y[1] = y[0];
        return 0;
    }

    var z: T = math.scalbn(@abs(x), -math.ilogb(x) + 23);
    var tx: [impl.nx]f64 = undefined;
    var ty: [impl.ny]f64 = undefined;
    var i: usize = 0;

    while (i < impl.nx - 1) : (i += 1) {
        tx[i] = @floatFromInt(@as(i32, @intFromFloat(z)));
        z = (z - @as(T, tx[i])) * 0x1p24;
    }

    tx[i] = @floatCast(z);
    while (tx[i] == 0.0) {
        i -= 1;
    }

    const n = rem_pio2_large(
        tx[0..(i + 1)],
        ty[0..impl.ny],
        ex - 0x3fff - 23,
        @intCast(i + 1),
        impl.ny,
    );
    var w: f64 = ty[1];
    if (impl.ny == 3) {
        w += ty[2];
    }
    const r = ty[0] + w;
    w -= r - ty[0];

    if (x_se >> 15 != 0) {
        y[0] = -@as(T, r);
        y[1] = -@as(T, w);
        return -n;
    }

    y[0] = @as(T, r);
    y[1] = @as(T, w);
    return n;
}
