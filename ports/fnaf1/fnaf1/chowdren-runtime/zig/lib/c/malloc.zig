//! Based on wrapping a stateless Zig Allocator implementation, appropriate for:
//! - ReleaseFast and ReleaseSmall optimization modes, with multi-threading
//!   enabled.
//! - WebAssembly or Linux in single-threaded release modes.
//!
//! Because the libc APIs don't have client alignment and size tracking, in
//! order to take advantage of Zig allocator implementations, additional
//! metadata must be stored in the allocations.
//!
//! This implementation stores the metadata just before the pointer returned
//! from `malloc`, just like many libc malloc implementations do, including
//! musl. This has the downside of causing fragmentation for allocations with
//! higher alignment, however most of that memory can be recovered by
//! preemptively putting the gap onto the freelist.
const builtin = @import("builtin");

const std = @import("std");
const assert = std.debug.assert;
const Alignment = std.mem.Alignment;
const alignment_bytes = @max(@alignOf(std.c.max_align_t), @sizeOf(Header));
const alignment: Alignment = .fromByteUnits(alignment_bytes);

const symbol = @import("../c.zig").symbol;

comptime {
    // Dependency on external errno location.
    if (builtin.link_libc) {
        symbol(&malloc, "malloc");
        symbol(&aligned_alloc, "aligned_alloc");
        symbol(&posix_memalign, "posix_memalign");
        symbol(&calloc, "calloc");
        symbol(&realloc, "realloc");
        symbol(&reallocarray, "reallocarray");
        symbol(&free, "free");
        symbol(&malloc_usable_size, "malloc_usable_size");

        symbol(&valloc, "valloc");
        symbol(&memalign, "memalign");
    }
}

const no_context: *anyopaque = undefined;
const no_ra: usize = undefined;
const vtable = switch (builtin.cpu.arch) {
    .wasm32, .wasm64 => std.heap.WasmAllocator.vtable,
    else => if (builtin.single_threaded) std.heap.BrkAllocator.vtable else std.heap.SmpAllocator.vtable,
};

/// Needed because libc memory allocators don't provide old alignment and size
/// which are required by Zig memory allocators.
const Header = packed struct(u64) {
    alignment: Alignment,
    /// Does not include the extra alignment bytes added.
    size: Size,
    canary: Canary = magic,

    comptime {
        assert(@sizeOf(Header) <= alignment_bytes);
    }

    const safety = switch (builtin.mode) {
        .Debug, .ReleaseSafe => true,
        .ReleaseFast, .ReleaseSmall => false,
    };
    const max_addr_bits = switch (safety) {
        true => 48, // Ensures space for Canary bits.
        false => 64,
    };
    const Size = @Int(.unsigned, @min(max_addr_bits, 64 - @bitSizeOf(Alignment), @bitSizeOf(usize)));
    const Canary = @Int(.unsigned, 64 - @bitSizeOf(Alignment) - @bitSizeOf(Size));
    const magic: Canary = switch (safety) {
        true => @truncate(@as(u64, 0x76fa65bebb3d7a39)), // statically chosen entropy
        false => 0,
    };

    fn get(base: [*]align(alignment_bytes) u8) Header {
        const header: *Header = @ptrCast(base - @sizeOf(Header));
        assert(header.canary == magic);
        return header.*;
    }

    fn set(base: [*]align(alignment_bytes) u8, a: Alignment, size: Size) [*]align(alignment_bytes) u8 {
        const header: *Header = @ptrCast(base - @sizeOf(Header));
        header.* = .{ .alignment = a, .size = size };
        return base;
    }
};

fn malloc(n: usize) callconv(.c) ?[*]align(alignment_bytes) u8 {
    const size = std.math.cast(Header.Size, n) orelse return nomem();
    const ptr: [*]align(alignment_bytes) u8 = @alignCast(
        vtable.alloc(no_context, n + alignment_bytes, alignment, no_ra) orelse return nomem(),
    );
    const base = ptr + alignment_bytes;
    return Header.set(base, alignment, size);
}

fn aligned_alloc(alloc_alignment: usize, n: usize) callconv(.c) ?[*]align(alignment_bytes) u8 {
    return aligned_alloc_inner(alloc_alignment, n) orelse return nomem();
}

/// Avoids setting errno so it can be called by `posix_memalign`.
fn aligned_alloc_inner(alloc_alignment: usize, n: usize) ?[*]align(alignment_bytes) u8 {
    const size = std.math.cast(Header.Size, n) orelse return null;
    const max_align = alignment.max(.fromByteUnits(alloc_alignment));
    const max_align_bytes = max_align.toByteUnits();
    const ptr: [*]align(alignment_bytes) u8 = @alignCast(
        vtable.alloc(no_context, n + max_align_bytes, max_align, no_ra) orelse return null,
    );
    const base: [*]align(alignment_bytes) u8 = @alignCast(ptr + max_align_bytes);
    return Header.set(base, max_align, size);
}

fn calloc(elems: usize, len: usize) callconv(.c) ?[*]align(alignment_bytes) u8 {
    const n = std.math.mul(usize, elems, len) catch return nomem();
    const base = malloc(n) orelse return null;
    @memset(base[0..n], 0);
    return base;
}

fn realloc(opt_old_base: ?[*]align(alignment_bytes) u8, n: usize) callconv(.c) ?[*]align(alignment_bytes) u8 {
    if (n == 0) {
        free(opt_old_base);
        return null;
    }
    const old_base = opt_old_base orelse return malloc(n);
    const new_size = std.math.cast(Header.Size, n) orelse return nomem();
    const old_header: Header = .get(old_base);
    const old_size = old_header.size;
    const old_alignment = old_header.alignment;
    const old_alignment_bytes = old_alignment.toByteUnits();
    const old_ptr = old_base - old_alignment_bytes;
    const old_slice = old_ptr[0 .. old_size + old_alignment_bytes];
    const new_base: [*]align(alignment_bytes) u8 = if (vtable.remap(
        no_context,
        old_slice,
        old_alignment,
        n + old_alignment_bytes,
        no_ra,
    )) |new_ptr| @alignCast(new_ptr + old_alignment_bytes) else b: {
        const new_ptr: [*]align(alignment_bytes) u8 = @alignCast(
            vtable.alloc(no_context, n + old_alignment_bytes, old_alignment, no_ra) orelse
                return nomem(),
        );
        const new_base: [*]align(alignment_bytes) u8 = @alignCast(new_ptr + old_alignment_bytes);
        const copy_len = @min(new_size, old_size);
        @memcpy(new_base[0..copy_len], old_base[0..copy_len]);
        vtable.free(no_context, old_slice, old_alignment, no_ra);
        break :b new_base;
    };
    return Header.set(new_base, old_alignment, new_size);
}

fn reallocarray(opt_base: ?[*]align(alignment_bytes) u8, elems: usize, len: usize) callconv(.c) ?[*]align(alignment_bytes) u8 {
    const n = std.math.mul(usize, elems, len) catch return nomem();
    return realloc(opt_base, n);
}

fn free(opt_old_base: ?[*]align(alignment_bytes) u8) callconv(.c) void {
    const old_base = opt_old_base orelse return;
    const old_header: Header = .get(old_base);
    const old_size = old_header.size;
    const old_alignment = old_header.alignment;
    const old_alignment_bytes = old_alignment.toByteUnits();
    const old_ptr = old_base - old_alignment_bytes;
    const old_slice = old_ptr[0 .. old_size + old_alignment_bytes];
    vtable.free(no_context, old_slice, old_alignment, no_ra);
}

fn malloc_usable_size(opt_old_base: ?[*]align(alignment_bytes) u8) callconv(.c) usize {
    const old_base = opt_old_base orelse return 0;
    const old_header: Header = .get(old_base);
    const old_size = old_header.size;
    return old_size;
}

fn valloc(n: usize) callconv(.c) ?[*]align(alignment_bytes) u8 {
    return aligned_alloc(std.heap.pageSize(), n);
}

fn memalign(alloc_alignment: usize, n: usize) callconv(.c) ?[*]align(alignment_bytes) u8 {
    return aligned_alloc(alloc_alignment, n);
}

fn posix_memalign(result: *?[*]align(alignment_bytes) u8, alloc_alignment: usize, n: usize) callconv(.c) c_int {
    if (alloc_alignment < @sizeOf(*anyopaque)) return @intFromEnum(std.c.E.INVAL);
    result.* = aligned_alloc_inner(alloc_alignment, n) orelse return @intFromEnum(std.c.E.NOMEM);
    return 0;
}

/// Libc memory allocation functions must set errno in addition to returning
/// `null`.
fn nomem() ?[*]align(alignment_bytes) u8 {
    @branchHint(.cold);
    std.c._errno().* = @intFromEnum(std.c.E.NOMEM);
    return null;
}
