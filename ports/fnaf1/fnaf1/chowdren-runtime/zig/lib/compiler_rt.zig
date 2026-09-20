const builtin = @import("builtin");
const ofmt_c = builtin.object_format == .c;
const native_endian = builtin.cpu.arch.endian();

const std = @import("std");

/// Avoid dragging in the runtime safety mechanisms into this .o file, unless
/// we're trying to test compiler-rt.
pub const panic = if (test_safety)
    std.debug.FullPanic(std.debug.defaultPanic)
else
    std.debug.no_panic;

pub const std_options_debug_threaded_io: ?*std.Io.Threaded = if (builtin.is_test)
    std.Io.Threaded.global_single_threaded
else
    null;

pub const std_options_debug_io: std.Io = if (builtin.is_test)
    std.Io.Threaded.global_single_threaded.io()
else
    unreachable;

pub inline fn symbol(comptime func: *const anyopaque, comptime name: []const u8) void {
    @export(func, .{ .name = name, .linkage = linkage, .visibility = visibility });
}

/// For now, we prefer weak linkage because some of the routines we implement here may also be
/// provided by system/dynamic libc. Eventually we should be more disciplined about this on a
/// per-symbol, per-target basis: https://github.com/ziglang/zig/issues/11883
pub const linkage: std.builtin.GlobalLinkage = if (builtin.is_test)
    .internal
else if (ofmt_c)
    .strong
else
    .weak;

/// Determines the symbol's visibility to other objects.
/// For WebAssembly this allows the symbol to be resolved to other modules, but will not
/// export it to the host runtime.
pub const visibility: std.builtin.SymbolVisibility = if (linkage == .internal or builtin.link_mode == .dynamic)
    .default
else
    .hidden;

pub const test_safety = switch (builtin.zig_backend) {
    .stage2_aarch64 => false,
    else => builtin.is_test,
};

comptime {
    // Integer routines
    _ = @import("compiler_rt/count0bits.zig");
    _ = @import("compiler_rt/parity.zig");
    _ = @import("compiler_rt/popcount.zig");
    _ = @import("compiler_rt/bitreverse.zig");
    _ = @import("compiler_rt/bswap.zig");
    _ = @import("compiler_rt/cmp.zig");

    _ = @import("compiler_rt/shift.zig");
    symbol(&__negsi2, "__negsi2");
    symbol(&__negdi2, "__negdi2");
    symbol(&__negti2, "__negti2");
    _ = @import("compiler_rt/int.zig");
    _ = @import("compiler_rt/mulXi3.zig");
    _ = @import("compiler_rt/udivmod.zig");

    _ = @import("compiler_rt/absv.zig");
    _ = @import("compiler_rt/absvsi2.zig");
    _ = @import("compiler_rt/absvdi2.zig");
    _ = @import("compiler_rt/absvti2.zig");
    _ = @import("compiler_rt/negv.zig");

    _ = @import("compiler_rt/addvsi3.zig");
    _ = @import("compiler_rt/addvdi3.zig");

    _ = @import("compiler_rt/subvsi3.zig");
    _ = @import("compiler_rt/subvdi3.zig");

    _ = @import("compiler_rt/mulvsi3.zig");

    _ = @import("compiler_rt/mulo.zig");

    // Float routines
    // conversion
    _ = @import("compiler_rt/extendf.zig");
    _ = @import("compiler_rt/extendhfsf2.zig");
    _ = @import("compiler_rt/extendhfdf2.zig");
    _ = @import("compiler_rt/extendhftf2.zig");
    _ = @import("compiler_rt/extendhfxf2.zig");
    _ = @import("compiler_rt/extendsfdf2.zig");
    _ = @import("compiler_rt/extendsftf2.zig");
    _ = @import("compiler_rt/extendsfxf2.zig");
    _ = @import("compiler_rt/extenddftf2.zig");
    _ = @import("compiler_rt/extenddfxf2.zig");
    _ = @import("compiler_rt/extendxftf2.zig");

    _ = @import("compiler_rt/truncf.zig");
    _ = @import("compiler_rt/truncsfhf2.zig");
    _ = @import("compiler_rt/truncdfhf2.zig");
    _ = @import("compiler_rt/truncdfsf2.zig");
    _ = @import("compiler_rt/truncxfhf2.zig");
    _ = @import("compiler_rt/truncxfsf2.zig");
    _ = @import("compiler_rt/truncxfdf2.zig");
    _ = @import("compiler_rt/trunctfhf2.zig");
    _ = @import("compiler_rt/trunctfsf2.zig");
    _ = @import("compiler_rt/trunctfdf2.zig");
    _ = @import("compiler_rt/trunctfxf2.zig");

    _ = @import("compiler_rt/int_from_float.zig");
    _ = @import("compiler_rt/fixhfei.zig");
    _ = @import("compiler_rt/fixsfsi.zig");
    _ = @import("compiler_rt/fixsfdi.zig");
    _ = @import("compiler_rt/fixsfti.zig");
    _ = @import("compiler_rt/fixsfei.zig");
    _ = @import("compiler_rt/fixdfsi.zig");
    _ = @import("compiler_rt/fixdfdi.zig");
    _ = @import("compiler_rt/fixdfti.zig");
    _ = @import("compiler_rt/fixdfei.zig");
    _ = @import("compiler_rt/fixtfsi.zig");
    _ = @import("compiler_rt/fixtfdi.zig");
    _ = @import("compiler_rt/fixtfti.zig");
    _ = @import("compiler_rt/fixtfei.zig");
    _ = @import("compiler_rt/fixxfsi.zig");
    _ = @import("compiler_rt/fixxfdi.zig");
    _ = @import("compiler_rt/fixxfei.zig");

    _ = @import("compiler_rt/fixunshfsi.zig");
    _ = @import("compiler_rt/fixunshfdi.zig");
    _ = @import("compiler_rt/fixunshfti.zig");
    _ = @import("compiler_rt/fixunshfei.zig");
    _ = @import("compiler_rt/fixunssfsi.zig");
    _ = @import("compiler_rt/fixunssfdi.zig");
    _ = @import("compiler_rt/fixunssfti.zig");
    _ = @import("compiler_rt/fixunssfei.zig");
    _ = @import("compiler_rt/fixunsdfsi.zig");
    _ = @import("compiler_rt/fixunsdfdi.zig");
    _ = @import("compiler_rt/fixunsdfti.zig");
    _ = @import("compiler_rt/fixunsdfei.zig");
    _ = @import("compiler_rt/fixunstfsi.zig");
    _ = @import("compiler_rt/fixunstfdi.zig");
    _ = @import("compiler_rt/fixunstfti.zig");
    _ = @import("compiler_rt/fixunstfei.zig");
    _ = @import("compiler_rt/fixunsxfsi.zig");
    _ = @import("compiler_rt/fixunsxfdi.zig");
    _ = @import("compiler_rt/fixunsxfti.zig");
    _ = @import("compiler_rt/fixunsxfei.zig");

    _ = @import("compiler_rt/float_from_int.zig");
    _ = @import("compiler_rt/floatsihf.zig");
    _ = @import("compiler_rt/floatsisf.zig");
    _ = @import("compiler_rt/floatsidf.zig");
    _ = @import("compiler_rt/floatsitf.zig");
    _ = @import("compiler_rt/floatsixf.zig");
    _ = @import("compiler_rt/floatdihf.zig");
    _ = @import("compiler_rt/floatdisf.zig");
    _ = @import("compiler_rt/floatdidf.zig");
    _ = @import("compiler_rt/floatditf.zig");
    _ = @import("compiler_rt/floatdixf.zig");
    _ = @import("compiler_rt/floattihf.zig");
    _ = @import("compiler_rt/floattisf.zig");
    _ = @import("compiler_rt/floattidf.zig");
    _ = @import("compiler_rt/floattitf.zig");
    _ = @import("compiler_rt/floattixf.zig");
    _ = @import("compiler_rt/floateihf.zig");
    _ = @import("compiler_rt/floateisf.zig");
    _ = @import("compiler_rt/floateidf.zig");
    _ = @import("compiler_rt/floateitf.zig");
    _ = @import("compiler_rt/floateixf.zig");
    _ = @import("compiler_rt/floatunsihf.zig");
    _ = @import("compiler_rt/floatunsisf.zig");
    _ = @import("compiler_rt/floatunsidf.zig");
    _ = @import("compiler_rt/floatunsitf.zig");
    _ = @import("compiler_rt/floatunsixf.zig");
    _ = @import("compiler_rt/floatundihf.zig");
    _ = @import("compiler_rt/floatundisf.zig");
    _ = @import("compiler_rt/floatundidf.zig");
    _ = @import("compiler_rt/floatunditf.zig");
    _ = @import("compiler_rt/floatundixf.zig");
    _ = @import("compiler_rt/floatuntihf.zig");
    _ = @import("compiler_rt/floatuntisf.zig");
    _ = @import("compiler_rt/floatuntidf.zig");
    _ = @import("compiler_rt/floatuntitf.zig");
    _ = @import("compiler_rt/floatuntixf.zig");
    _ = @import("compiler_rt/floatuneihf.zig");
    _ = @import("compiler_rt/floatuneisf.zig");
    _ = @import("compiler_rt/floatuneidf.zig");
    _ = @import("compiler_rt/floatuneitf.zig");
    _ = @import("compiler_rt/floatuneixf.zig");

    // comparison
    _ = @import("compiler_rt/comparef.zig");
    _ = @import("compiler_rt/cmpdf2.zig");
    _ = @import("compiler_rt/cmptf2.zig");
    _ = @import("compiler_rt/cmpxf2.zig");
    _ = @import("compiler_rt/unorddf2.zig");
    _ = @import("compiler_rt/gehf2.zig");
    _ = @import("compiler_rt/gesf2.zig");
    _ = @import("compiler_rt/gedf2.zig");
    _ = @import("compiler_rt/gexf2.zig");
    _ = @import("compiler_rt/getf2.zig");

    // arithmetic
    _ = @import("compiler_rt/addf3.zig");
    _ = @import("compiler_rt/addhf3.zig");
    _ = @import("compiler_rt/addsf3.zig");
    _ = @import("compiler_rt/adddf3.zig");
    _ = @import("compiler_rt/addtf3.zig");
    _ = @import("compiler_rt/addxf3.zig");

    _ = @import("compiler_rt/subhf3.zig");
    _ = @import("compiler_rt/subsf3.zig");
    _ = @import("compiler_rt/subdf3.zig");
    _ = @import("compiler_rt/subtf3.zig");
    _ = @import("compiler_rt/subxf3.zig");

    _ = @import("compiler_rt/mulf3.zig");
    _ = @import("compiler_rt/mulhf3.zig");
    _ = @import("compiler_rt/mulsf3.zig");
    _ = @import("compiler_rt/muldf3.zig");
    _ = @import("compiler_rt/multf3.zig");
    _ = @import("compiler_rt/mulxf3.zig");

    _ = @import("compiler_rt/divhf3.zig");
    _ = @import("compiler_rt/divsf3.zig");
    _ = @import("compiler_rt/divdf3.zig");
    _ = @import("compiler_rt/divxf3.zig");
    _ = @import("compiler_rt/divtf3.zig");

    symbol(&__neghf2, "__neghf2");
    if (want_aeabi) {
        symbol(&__aeabi_fneg, "__aeabi_fneg");
        symbol(&__aeabi_dneg, "__aeabi_dneg");
    } else {
        symbol(&__negsf2, "__negsf2");
        symbol(&__negdf2, "__negdf2");
    }
    if (want_ppc_abi) symbol(&__negtf2, "__negkf2");
    symbol(&__negtf2, "__negtf2");
    symbol(&__negxf2, "__negxf2");

    // other
    _ = @import("compiler_rt/powiXf2.zig");
    _ = @import("compiler_rt/mulc3.zig");
    _ = @import("compiler_rt/mulhc3.zig");
    _ = @import("compiler_rt/mulsc3.zig");
    _ = @import("compiler_rt/muldc3.zig");
    _ = @import("compiler_rt/mulxc3.zig");
    _ = @import("compiler_rt/multc3.zig");

    _ = @import("compiler_rt/divc3.zig");
    _ = @import("compiler_rt/divhc3.zig");
    _ = @import("compiler_rt/divsc3.zig");
    _ = @import("compiler_rt/divdc3.zig");
    _ = @import("compiler_rt/divxc3.zig");
    _ = @import("compiler_rt/divtc3.zig");

    // Math routines. Alphabetically sorted.
    _ = @import("compiler_rt/cos.zig");
    _ = @import("compiler_rt/exp.zig");
    _ = @import("compiler_rt/exp2.zig");
    _ = @import("compiler_rt/fabs.zig");
    _ = @import("compiler_rt/floor_ceil.zig");
    _ = @import("compiler_rt/fma.zig");
    _ = @import("compiler_rt/fmax.zig");
    _ = @import("compiler_rt/fmin.zig");
    _ = @import("compiler_rt/fmod.zig");
    _ = @import("compiler_rt/log.zig");
    _ = @import("compiler_rt/log10.zig");
    _ = @import("compiler_rt/log2.zig");
    _ = @import("compiler_rt/round.zig");
    _ = @import("compiler_rt/sin.zig");
    _ = @import("compiler_rt/sincos.zig");
    _ = @import("compiler_rt/sqrt.zig");
    _ = @import("compiler_rt/tan.zig");
    _ = @import("compiler_rt/trunc.zig");

    // BigInt. Alphabetically sorted.
    _ = @import("compiler_rt/divmodei4.zig");
    _ = @import("compiler_rt/udivmodei4.zig");

    _ = @import("compiler_rt/limb64.zig");

    // extra
    _ = @import("compiler_rt/os_version_check.zig");
    _ = @import("compiler_rt/emutls.zig");
    _ = @import("compiler_rt/arm.zig");
    _ = @import("compiler_rt/aulldiv.zig");
    _ = @import("compiler_rt/aullrem.zig");
    _ = @import("compiler_rt/clear_cache.zig");
    _ = @import("compiler_rt/hexagon.zig");

    if (@import("builtin").object_format != .c) {
        if (builtin.zig_backend != .stage2_aarch64) _ = @import("compiler_rt/atomics.zig");
        _ = @import("compiler_rt/stack_probe.zig");

        // macOS has these functions inside libSystem.
        if (builtin.cpu.arch.isAARCH64() and !builtin.os.tag.isDarwin()) {
            if (builtin.zig_backend != .stage2_aarch64) _ = @import("compiler_rt/aarch64_outline_atomics.zig");
        }

        _ = @import("compiler_rt/memcpy.zig");
        if (!ofmt_c) {
            symbol(&memset, "memset");
            symbol(&__memset, "__memset");
        }
        _ = @import("compiler_rt/memmove.zig");
        symbol(&memcmp, "memcmp");
        symbol(&bcmp, "bcmp");
        _ = @import("compiler_rt/ssp.zig");
        symbol(&strlen, "strlen");
    }

    // Temporarily used for uefi until https://github.com/ziglang/zig/issues/21630 is addressed.
    if (!builtin.link_libc and (builtin.os.tag == .windows or builtin.os.tag == .uefi) and (builtin.abi == .none or builtin.abi == .msvc)) {
        symbol(&_fltused, "_fltused");
    }
}

var _fltused: c_int = 1;

fn strlen(s: [*:0]const c_char) callconv(.c) usize {
    return std.mem.len(s);
}

fn memcmp(vl: [*]const u8, vr: [*]const u8, n: usize) callconv(.c) c_int {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const compared = @as(c_int, vl[i]) -% @as(c_int, vr[i]);
        if (compared != 0) return compared;
    }
    return 0;
}

test "memcmp" {
    const arr0 = &[_]u8{ 1, 1, 1 };
    const arr1 = &[_]u8{ 1, 1, 1 };
    const arr2 = &[_]u8{ 1, 0, 1 };
    const arr3 = &[_]u8{ 1, 2, 1 };
    const arr4 = &[_]u8{ 1, 0xff, 1 };

    try std.testing.expect(memcmp(arr0, arr1, 3) == 0);
    try std.testing.expect(memcmp(arr0, arr2, 3) > 0);
    try std.testing.expect(memcmp(arr0, arr3, 3) < 0);

    try std.testing.expect(memcmp(arr0, arr4, 3) < 0);
    try std.testing.expect(memcmp(arr4, arr0, 3) > 0);
}

pub const PreferredLoadStoreElement = element: {
    if (std.simd.suggestVectorLength(u8)) |vec_size| {
        const Vec = @Vector(vec_size, u8);

        if (@sizeOf(Vec) == vec_size and std.math.isPowerOfTwo(vec_size)) {
            break :element Vec;
        }
    }
    break :element usize;
};

pub const want_aeabi = switch (builtin.abi) {
    .eabi,
    .eabihf,
    .musleabi,
    .musleabihf,
    .gnueabi,
    .gnueabihf,
    .android,
    .androideabi,
    => switch (builtin.cpu.arch) {
        .arm, .armeb, .thumb, .thumbeb => true,
        else => false,
    },
    else => false,
};

/// These functions are required on Windows on ARM. They are provided by MSVC libc, but in libc-less
/// builds or when linking MinGW libc they are our responsibility.
/// Temporarily used for thumb-uefi until https://github.com/ziglang/zig/issues/21630 is addressed.
pub const want_windows_arm_abi = e: {
    if (!builtin.cpu.arch.isArm()) break :e false;
    switch (builtin.os.tag) {
        .windows, .uefi => {},
        else => break :e false,
    }
    // The ABI is needed, but it's only our reponsibility if libc won't provide it.
    break :e builtin.abi.isGnu() or !builtin.link_libc;
};

/// These functions are required by on Windows on x86 on some ABIs. They are provided by MSVC libc,
/// but in libc-less builds they are our responsibility.
pub const want_windows_x86_msvc_abi = e: {
    if (builtin.cpu.arch != .x86) break :e false;
    if (builtin.os.tag != .windows) break :e false;
    switch (builtin.abi) {
        .none, .msvc, .itanium => {},
        else => break :e false,
    }
    // The ABI is needed, but it's only our responsibility if libc won't provide it.
    break :e !builtin.link_libc;
};

pub const want_ppc_abi = builtin.cpu.arch.isPowerPC();

pub const want_float_exceptions = !builtin.cpu.arch.isWasm();

// Libcalls that involve u128 on Windows x86-64 are expected by LLVM to use the
// calling convention of @Vector(2, u64), rather than what's standard.
pub const want_windows_v2u64_abi = builtin.os.tag == .windows and builtin.cpu.arch == .x86_64 and !ofmt_c;

/// This governs whether to use these symbol names for f16/f32 conversions
/// rather than the standard names:
/// * __gnu_f2h_ieee
/// * __gnu_h2f_ieee
/// Known correct configurations:
///   x86_64-freestanding-none => true
///   x86_64-linux-none => true
///   x86_64-linux-gnu => true
///   x86_64-linux-musl => true
///   x86_64-linux-eabi => true
///   arm-linux-musleabihf => true
///   arm-linux-gnueabihf => true
///   arm-linux-eabihf => false
///   wasm32-wasi-musl => false
///   wasm32-freestanding-none => false
///   x86_64-windows-gnu => true
///   x86_64-windows-msvc => true
///   any-macos-any => false
pub const gnu_f16_abi = switch (builtin.cpu.arch) {
    .wasm32,
    .wasm64,
    .riscv64,
    .riscv64be,
    .riscv32,
    .riscv32be,
    => false,

    .x86, .x86_64 => true,

    .arm, .armeb, .thumb, .thumbeb => switch (builtin.abi) {
        .eabi, .eabihf => false,
        else => true,
    },

    else => !builtin.os.tag.isDarwin(),
};

pub const want_sparc_abi = builtin.cpu.arch.isSPARC();

/// This seems to mostly correspond to `clang::TargetInfo::HasFloat16`.
pub fn F16T(comptime OtherType: type) type {
    return switch (builtin.cpu.arch) {
        .amdgcn,
        .arm,
        .armeb,
        .thumb,
        .thumbeb,
        .aarch64,
        .aarch64_be,
        .hexagon,
        .loongarch32,
        .loongarch64,
        .nvptx,
        .nvptx64,
        .riscv32,
        .riscv32be,
        .riscv64,
        .riscv64be,
        .s390x,
        .spirv32,
        .spirv64,
        => f16,
        .x86, .x86_64 => if (builtin.target.os.tag.isDarwin()) switch (OtherType) {
            // Starting with LLVM 16, Darwin uses different abi for f16
            // depending on the type of the other return/argument..???
            f32, f64 => u16,
            f80, f128 => f16,
            else => unreachable,
        } else f16,
        else => u16,
    };
}

pub fn wideMultiply(comptime Z: type, a: Z, b: Z, hi: *Z, lo: *Z) void {
    switch (Z) {
        u16 => {
            // 16x16 --> 32 bit multiply
            const product = @as(u32, a) * @as(u32, b);
            hi.* = @intCast(product >> 16);
            lo.* = @truncate(product);
        },
        u32 => {
            // 32x32 --> 64 bit multiply
            const product = @as(u64, a) * @as(u64, b);
            hi.* = @truncate(product >> 32);
            lo.* = @truncate(product);
        },
        u64 => {
            const S = struct {
                fn loWord(x: u64) u64 {
                    return @as(u32, @truncate(x));
                }
                fn hiWord(x: u64) u64 {
                    return @as(u32, @truncate(x >> 32));
                }
            };
            // 64x64 -> 128 wide multiply for platforms that don't have such an operation;
            // many 64-bit platforms have this operation, but they tend to have hardware
            // floating-point, so we don't bother with a special case for them here.
            // Each of the component 32x32 -> 64 products
            const plolo: u64 = S.loWord(a) * S.loWord(b);
            const plohi: u64 = S.loWord(a) * S.hiWord(b);
            const philo: u64 = S.hiWord(a) * S.loWord(b);
            const phihi: u64 = S.hiWord(a) * S.hiWord(b);
            // Sum terms that contribute to lo in a way that allows us to get the carry
            const r0: u64 = S.loWord(plolo);
            const r1: u64 = S.hiWord(plolo) +% S.loWord(plohi) +% S.loWord(philo);
            lo.* = r0 +% (r1 << 32);
            // Sum terms contributing to hi with the carry from lo
            hi.* = S.hiWord(plohi) +% S.hiWord(philo) +% S.hiWord(r1) +% phihi;
        },
        u128 => {
            const Word_LoMask: u64 = 0x00000000ffffffff;
            const Word_HiMask: u64 = 0xffffffff00000000;
            const Word_FullMask: u64 = 0xffffffffffffffff;
            const S = struct {
                fn Word_1(x: u128) u64 {
                    return @as(u32, @truncate(x >> 96));
                }
                fn Word_2(x: u128) u64 {
                    return @as(u32, @truncate(x >> 64));
                }
                fn Word_3(x: u128) u64 {
                    return @as(u32, @truncate(x >> 32));
                }
                fn Word_4(x: u128) u64 {
                    return @as(u32, @truncate(x));
                }
            };
            // 128x128 -> 256 wide multiply for platforms that don't have such an operation;
            // many 64-bit platforms have this operation, but they tend to have hardware
            // floating-point, so we don't bother with a special case for them here.

            const product11: u64 = S.Word_1(a) * S.Word_1(b);
            const product12: u64 = S.Word_1(a) * S.Word_2(b);
            const product13: u64 = S.Word_1(a) * S.Word_3(b);
            const product14: u64 = S.Word_1(a) * S.Word_4(b);
            const product21: u64 = S.Word_2(a) * S.Word_1(b);
            const product22: u64 = S.Word_2(a) * S.Word_2(b);
            const product23: u64 = S.Word_2(a) * S.Word_3(b);
            const product24: u64 = S.Word_2(a) * S.Word_4(b);
            const product31: u64 = S.Word_3(a) * S.Word_1(b);
            const product32: u64 = S.Word_3(a) * S.Word_2(b);
            const product33: u64 = S.Word_3(a) * S.Word_3(b);
            const product34: u64 = S.Word_3(a) * S.Word_4(b);
            const product41: u64 = S.Word_4(a) * S.Word_1(b);
            const product42: u64 = S.Word_4(a) * S.Word_2(b);
            const product43: u64 = S.Word_4(a) * S.Word_3(b);
            const product44: u64 = S.Word_4(a) * S.Word_4(b);

            const sum0: u128 = @as(u128, product44);
            const sum1: u128 = @as(u128, product34) +%
                @as(u128, product43);
            const sum2: u128 = @as(u128, product24) +%
                @as(u128, product33) +%
                @as(u128, product42);
            const sum3: u128 = @as(u128, product14) +%
                @as(u128, product23) +%
                @as(u128, product32) +%
                @as(u128, product41);
            const sum4: u128 = @as(u128, product13) +%
                @as(u128, product22) +%
                @as(u128, product31);
            const sum5: u128 = @as(u128, product12) +%
                @as(u128, product21);
            const sum6: u128 = @as(u128, product11);

            const r0: u128 = (sum0 & Word_FullMask) +%
                ((sum1 & Word_LoMask) << 32);
            const r1: u128 = (sum0 >> 64) +%
                ((sum1 >> 32) & Word_FullMask) +%
                (sum2 & Word_FullMask) +%
                ((sum3 << 32) & Word_HiMask);

            lo.* = r0 +% (r1 << 64);
            hi.* = (r1 >> 64) +%
                (sum1 >> 96) +%
                (sum2 >> 64) +%
                (sum3 >> 32) +%
                sum4 +%
                (sum5 << 32) +%
                (sum6 << 64);
        },
        else => @compileError("unsupported"),
    }
}

pub fn normalize(comptime T: type, significand: *std.meta.Int(.unsigned, @typeInfo(T).float.bits)) i32 {
    const Z = std.meta.Int(.unsigned, @typeInfo(T).float.bits);
    const integerBit = @as(Z, 1) << std.math.floatFractionalBits(T);

    const shift = @clz(significand.*) - @clz(integerBit);
    significand.* <<= @as(std.math.Log2Int(Z), @intCast(shift));
    return @as(i32, 1) - shift;
}

pub inline fn fneg(a: anytype) @TypeOf(a) {
    const F = @TypeOf(a);
    const bits = @typeInfo(F).float.bits;
    const U = @Int(.unsigned, bits);
    const sign_bit_mask = @as(U, 1) << (bits - 1);
    const negated = @as(U, @bitCast(a)) ^ sign_bit_mask;
    return @bitCast(negated);
}

fn __negxf2(a: f80) callconv(.c) f80 {
    return fneg(a);
}

fn __neghf2(a: f16) callconv(.c) f16 {
    return fneg(a);
}

fn __negdf2(a: f64) callconv(.c) f64 {
    return fneg(a);
}

fn __aeabi_dneg(a: f64) callconv(.{ .arm_aapcs = .{} }) f64 {
    return fneg(a);
}

fn __negtf2(a: f128) callconv(.c) f128 {
    return fneg(a);
}

fn __negsf2(a: f32) callconv(.c) f32 {
    return fneg(a);
}

fn __aeabi_fneg(a: f32) callconv(.{ .arm_aapcs = .{} }) f32 {
    return fneg(a);
}

/// Allows to access underlying bits as two equally sized lower and higher
/// signed or unsigned integers.
pub fn HalveInt(comptime T: type, comptime signed_half: bool) type {
    return extern union {
        pub const bits = @divExact(@typeInfo(T).int.bits, 2);
        pub const HalfTU = std.meta.Int(.unsigned, bits);
        pub const HalfTS = std.meta.Int(.signed, bits);
        pub const HalfT = if (signed_half) HalfTS else HalfTU;

        all: T,
        s: if (native_endian == .little)
            extern struct { low: HalfT, high: HalfT }
        else
            extern struct { high: HalfT, low: HalfT },
    };
}

pub fn __negsi2(a: i32) callconv(.c) i32 {
    return negXi2(i32, a);
}

pub fn __negdi2(a: i64) callconv(.c) i64 {
    return negXi2(i64, a);
}

pub fn __negti2(a: i128) callconv(.c) i128 {
    return negXi2(i128, a);
}

inline fn negXi2(comptime T: type, a: T) T {
    return -a;
}

pub fn memset(dest: ?[*]u8, c: u8, len: usize) callconv(.c) ?[*]u8 {
    @setRuntimeSafety(false);

    if (len != 0) {
        var d = dest.?;
        var n = len;
        while (true) {
            d[0] = c;
            n -= 1;
            if (n == 0) break;
            d += 1;
        }
    }

    return dest;
}

pub fn __memset(dest: ?[*]u8, c: u8, n: usize, dest_n: usize) callconv(.c) ?[*]u8 {
    if (dest_n < n)
        @panic("buffer overflow");
    return memset(dest, c, n);
}

pub fn bcmp(vl: [*]allowzero const u8, vr: [*]allowzero const u8, n: usize) callconv(.c) c_int {
    @setRuntimeSafety(false);

    var index: usize = 0;
    while (index != n) : (index += 1) {
        if (vl[index] != vr[index]) {
            return 1;
        }
    }

    return 0;
}

test "bcmp" {
    const base_arr = &[_]u8{ 1, 1, 1 };
    const arr1 = &[_]u8{ 1, 1, 1 };
    const arr2 = &[_]u8{ 1, 0, 1 };
    const arr3 = &[_]u8{ 1, 2, 1 };

    try std.testing.expect(bcmp(base_arr[0..], arr1[0..], base_arr.len) == 0);
    try std.testing.expect(bcmp(base_arr[0..], arr2[0..], base_arr.len) != 0);
    try std.testing.expect(bcmp(base_arr[0..], arr3[0..], base_arr.len) != 0);
}

test {
    _ = @import("compiler_rt/negsi2_test.zig");
    _ = @import("compiler_rt/negdi2_test.zig");
    _ = @import("compiler_rt/negti2_test.zig");
}
