//! Implementation of ARM specific builtins for Run-time ABI
//! This file includes all ARM-only functions.
const std = @import("std");
const builtin = @import("builtin");
const target = builtin.target;
const arch = builtin.cpu.arch;
const compiler_rt = @import("../compiler_rt.zig");
const symbol = compiler_rt.symbol;

comptime {
    if (!builtin.is_test) {
        if (arch.isArm()) {
            symbol(&__aeabi_unwind_cpp_pr0, "__aeabi_unwind_cpp_pr0");
            symbol(&__aeabi_unwind_cpp_pr1, "__aeabi_unwind_cpp_pr1");
            symbol(&__aeabi_unwind_cpp_pr2, "__aeabi_unwind_cpp_pr2");

            if (compiler_rt.want_windows_arm_abi) {
                symbol(&__aeabi_ldivmod, "__rt_sdiv64");
                symbol(&__aeabi_uldivmod, "__rt_udiv64");
                symbol(&__aeabi_idivmod, "__rt_sdiv");
                symbol(&__aeabi_uidivmod, "__rt_udiv");
            }
            symbol(&__aeabi_ldivmod, "__aeabi_ldivmod");
            symbol(&__aeabi_uldivmod, "__aeabi_uldivmod");
            symbol(&__aeabi_idivmod, "__aeabi_idivmod");
            symbol(&__aeabi_uidivmod, "__aeabi_uidivmod");

            symbol(&__aeabi_memcpy, "__aeabi_memcpy");
            symbol(&__aeabi_memcpy4, "__aeabi_memcpy4");
            symbol(&__aeabi_memcpy8, "__aeabi_memcpy8");

            symbol(&__aeabi_memmove, "__aeabi_memmove");
            symbol(&__aeabi_memmove4, "__aeabi_memmove4");
            symbol(&__aeabi_memmove8, "__aeabi_memmove8");

            symbol(&__aeabi_memset, "__aeabi_memset");
            symbol(&__aeabi_memset4, "__aeabi_memset4");
            symbol(&__aeabi_memset8, "__aeabi_memset8");

            symbol(&__aeabi_memclr, "__aeabi_memclr");
            symbol(&__aeabi_memclr4, "__aeabi_memclr4");
            symbol(&__aeabi_memclr8, "__aeabi_memclr8");

            if (builtin.os.tag == .linux or builtin.os.tag == .freebsd) {
                symbol(&__aeabi_read_tp, "__aeabi_read_tp");
            }

            // floating-point helper functions (single+double-precision reverse subtraction, y – x), see subdf3.zig
            symbol(&__aeabi_frsub, "__aeabi_frsub");
            symbol(&__aeabi_drsub, "__aeabi_drsub");
        }
    }
}

const __divmodsi4 = @import("int.zig").__divmodsi4;
const __udivmodsi4 = @import("int.zig").__udivmodsi4;
const __divmoddi4 = @import("int.zig").__divmoddi4;
const __udivmoddi4 = @import("int.zig").__udivmoddi4;

extern fn memset(dest: ?[*]u8, c: i32, n: usize) ?[*]u8;
extern fn memcpy(noalias dest: ?[*]u8, noalias src: ?[*]const u8, n: usize) ?[*]u8;
extern fn memmove(dest: ?[*]u8, src: ?[*]const u8, n: usize) ?[*]u8;

pub fn __aeabi_memcpy(dest: [*]u8, src: [*]u8, n: usize) callconv(.{ .arm_aapcs = .{} }) void {
    @setRuntimeSafety(false);
    _ = memcpy(dest, src, n);
}
pub fn __aeabi_memcpy4(dest: [*]u8, src: [*]u8, n: usize) callconv(.{ .arm_aapcs = .{} }) void {
    @setRuntimeSafety(false);
    _ = memcpy(dest, src, n);
}
pub fn __aeabi_memcpy8(dest: [*]u8, src: [*]u8, n: usize) callconv(.{ .arm_aapcs = .{} }) void {
    @setRuntimeSafety(false);
    _ = memcpy(dest, src, n);
}

pub fn __aeabi_memmove(dest: [*]u8, src: [*]u8, n: usize) callconv(.{ .arm_aapcs = .{} }) void {
    @setRuntimeSafety(false);
    _ = memmove(dest, src, n);
}
pub fn __aeabi_memmove4(dest: [*]u8, src: [*]u8, n: usize) callconv(.{ .arm_aapcs = .{} }) void {
    @setRuntimeSafety(false);
    _ = memmove(dest, src, n);
}
pub fn __aeabi_memmove8(dest: [*]u8, src: [*]u8, n: usize) callconv(.{ .arm_aapcs = .{} }) void {
    @setRuntimeSafety(false);
    _ = memmove(dest, src, n);
}

pub fn __aeabi_memset(dest: [*]u8, n: usize, c: i32) callconv(.{ .arm_aapcs = .{} }) void {
    @setRuntimeSafety(false);
    // This is dentical to the standard `memset` definition but with the last
    // two arguments swapped
    _ = memset(dest, c, n);
}
pub fn __aeabi_memset4(dest: [*]u8, n: usize, c: i32) callconv(.{ .arm_aapcs = .{} }) void {
    @setRuntimeSafety(false);
    _ = memset(dest, c, n);
}
pub fn __aeabi_memset8(dest: [*]u8, n: usize, c: i32) callconv(.{ .arm_aapcs = .{} }) void {
    @setRuntimeSafety(false);
    _ = memset(dest, c, n);
}

pub fn __aeabi_memclr(dest: [*]u8, n: usize) callconv(.{ .arm_aapcs = .{} }) void {
    @setRuntimeSafety(false);
    _ = memset(dest, 0, n);
}
pub fn __aeabi_memclr4(dest: [*]u8, n: usize) callconv(.{ .arm_aapcs = .{} }) void {
    @setRuntimeSafety(false);
    _ = memset(dest, 0, n);
}
pub fn __aeabi_memclr8(dest: [*]u8, n: usize) callconv(.{ .arm_aapcs = .{} }) void {
    @setRuntimeSafety(false);
    _ = memset(dest, 0, n);
}

// Dummy functions to avoid errors during the linking phase
pub fn __aeabi_unwind_cpp_pr0() callconv(.{ .arm_aapcs = .{} }) void {}
pub fn __aeabi_unwind_cpp_pr1() callconv(.{ .arm_aapcs = .{} }) void {}
pub fn __aeabi_unwind_cpp_pr2() callconv(.{ .arm_aapcs = .{} }) void {}

// This function can only clobber r0 according to the ABI
pub fn __aeabi_read_tp() callconv(.naked) void {
    @setRuntimeSafety(false);
    asm volatile (
        \\ mrc p15, 0, r0, c13, c0, 3
        \\ bx lr
    );
    unreachable;
}

// The following functions are wrapped in an asm block to ensure the required
// calling convention is always respected

pub fn __aeabi_uidivmod() callconv(.naked) void {
    @setRuntimeSafety(false);
    // Divide r0 by r1; the quotient goes in r0, the remainder in r1
    asm volatile (
        \\ push {lr}
        \\ sub sp, #4
        \\ mov r2, sp
        \\ bl  %[__udivmodsi4]
        \\ ldr r1, [sp]
        \\ add sp, #4
        \\ pop {pc}
        :
        : [__udivmodsi4] "X" (&__udivmodsi4),
        : .{ .memory = true });
    unreachable;
}

pub fn __aeabi_uldivmod() callconv(.naked) void {
    @setRuntimeSafety(false);
    // Divide r1:r0 by r3:r2; the quotient goes in r1:r0, the remainder in r3:r2
    asm volatile (
        \\ push {r4, lr}
        \\ sub sp, #16
        \\ add r4, sp, #8
        \\ str r4, [sp]
        \\ bl  %[__udivmoddi4]
        \\ ldr r2, [sp, #8]
        \\ ldr r3, [sp, #12]
        \\ add sp, #16
        \\ pop {r4, pc}
        :
        : [__udivmoddi4] "X" (&__udivmoddi4),
        : .{ .memory = true });
    unreachable;
}

pub fn __aeabi_idivmod() callconv(.naked) void {
    @setRuntimeSafety(false);
    // Divide r0 by r1; the quotient goes in r0, the remainder in r1
    asm volatile (
        \\ push {lr}
        \\ sub sp, #4
        \\ mov r2, sp
        \\ bl  %[__divmodsi4]
        \\ ldr r1, [sp]
        \\ add sp, #4
        \\ pop {pc}
        :
        : [__divmodsi4] "X" (&__divmodsi4),
        : .{ .memory = true });
    unreachable;
}

pub fn __aeabi_ldivmod() callconv(.naked) void {
    @setRuntimeSafety(false);
    // Divide r1:r0 by r3:r2; the quotient goes in r1:r0, the remainder in r3:r2
    asm volatile (
        \\ push {r4, lr}
        \\ sub sp, #16
        \\ add r4, sp, #8
        \\ str r4, [sp]
        \\ bl  %[__divmoddi4]
        \\ ldr r2, [sp, #8]
        \\ ldr r3, [sp, #12]
        \\ add sp, #16
        \\ pop {r4, pc}
        :
        : [__divmoddi4] "X" (&__divmoddi4),
        : .{ .memory = true });
    unreachable;
}

// Float Arithmetic

fn __aeabi_frsub(a: f32, b: f32) callconv(.{ .arm_aapcs = .{} }) f32 {
    const neg_a: f32 = @bitCast(@as(u32, @bitCast(a)) ^ (@as(u32, 1) << 31));
    return b + neg_a;
}

fn __aeabi_drsub(a: f64, b: f64) callconv(.{ .arm_aapcs = .{} }) f64 {
    const neg_a: f64 = @bitCast(@as(u64, @bitCast(a)) ^ (@as(u64, 1) << 63));
    return b + neg_a;
}

test "__aeabi_frsub" {
    if (!builtin.cpu.arch.isArm() or builtin.cpu.arch.isThumb()) return error.SkipZigTest;
    const inf32 = std.math.inf(f32);
    const maxf32 = std.math.floatMax(f32);
    const frsub_data = [_][3]f32{
        [_]f32{ 0.0, 0.0, -0.0 },
        [_]f32{ 0.0, -0.0, -0.0 },
        [_]f32{ -0.0, 0.0, 0.0 },
        [_]f32{ -0.0, -0.0, -0.0 },
        [_]f32{ 0.0, 1.0, 1.0 },
        [_]f32{ 1.0, 0.0, -1.0 },
        [_]f32{ 1.0, 1.0, 0.0 },
        [_]f32{ 1234.56789, 9876.54321, 8641.97532 },
        [_]f32{ 9876.54321, 1234.56789, -8641.97532 },
        [_]f32{ -8641.97532, 1234.56789, 9876.54321 },
        [_]f32{ 8641.97532, 9876.54321, 1234.56789 },
        [_]f32{ -maxf32, -maxf32, 0.0 },
        [_]f32{ maxf32, maxf32, 0.0 },
        [_]f32{ maxf32, -maxf32, -inf32 },
        [_]f32{ -maxf32, maxf32, inf32 },
    };
    for (frsub_data) |data| {
        try std.testing.expectApproxEqAbs(data[2], __aeabi_frsub(data[0], data[1]), 0.001);
    }
}

test "__aeabi_drsub" {
    if (!builtin.cpu.arch.isArm() or builtin.cpu.arch.isThumb()) return error.SkipZigTest;
    if (builtin.cpu.arch == .armeb and builtin.zig_backend == .stage2_llvm) return error.SkipZigTest; // https://github.com/ziglang/zig/issues/22061
    const inf64 = std.math.inf(f64);
    const maxf64 = std.math.floatMax(f64);
    const frsub_data = [_][3]f64{
        [_]f64{ 0.0, 0.0, -0.0 },
        [_]f64{ 0.0, -0.0, -0.0 },
        [_]f64{ -0.0, 0.0, 0.0 },
        [_]f64{ -0.0, -0.0, -0.0 },
        [_]f64{ 0.0, 1.0, 1.0 },
        [_]f64{ 1.0, 0.0, -1.0 },
        [_]f64{ 1.0, 1.0, 0.0 },
        [_]f64{ 1234.56789, 9876.54321, 8641.97532 },
        [_]f64{ 9876.54321, 1234.56789, -8641.97532 },
        [_]f64{ -8641.97532, 1234.56789, 9876.54321 },
        [_]f64{ 8641.97532, 9876.54321, 1234.56789 },
        [_]f64{ -maxf64, -maxf64, 0.0 },
        [_]f64{ maxf64, maxf64, 0.0 },
        [_]f64{ maxf64, -maxf64, -inf64 },
        [_]f64{ -maxf64, maxf64, inf64 },
    };
    for (frsub_data) |data| {
        try std.testing.expectApproxEqAbs(data[2], __aeabi_drsub(data[0], data[1]), 0.000001);
    }
}
