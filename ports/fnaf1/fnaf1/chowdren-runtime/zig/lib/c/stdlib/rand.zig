const builtin = @import("builtin");
const std = @import("std");
const symbol = @import("../../c.zig").symbol;

comptime {
    if (builtin.target.isMuslLibC() or builtin.target.isWasiLibC()) {
        symbol(&rand, "rand");
        symbol(&srand, "srand");
        symbol(&rand_r, "rand_r");
    }
}

// NOTE: The PRNG used for `rand` is unspecified, so it can be any!
var rand_state: std.Random.SplitMix64 = .init(1);

fn rand_r(seed: *c_uint) callconv(.c) c_int {
    var mix: std.Random.SplitMix64 = .init(seed.*);
    defer seed.* = @truncate(mix.s);

    // Every bundled libc defines RAND_MAX as `std.math.maxInt(u31)` (except windows where it is `std.math.maxInt(u15)`)
    return @as(u31, @truncate(mix.next() >> 33));
}

fn srand(seed: c_uint) callconv(.c) void {
    rand_state = .init(seed);
}

fn rand() callconv(.c) c_int {
    return @as(u31, @truncate(rand_state.next() >> 33));
}
