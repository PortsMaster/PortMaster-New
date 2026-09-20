//! Multi-target implementation of libc, providing ABI compatibility with
//! bundled libcs.
//!
//! mingw-w64 libc is not fully statically linked, so some symbols don't need
//! to be exported. However, a future enhancement could be eliminating Zig's
//! dependency on msvcrt dll even when linking libc and targeting Windows.

const builtin = @import("builtin");
const std = @import("std");

// Avoid dragging in the runtime safety mechanisms into this .o file, unless
// we're trying to test zigc.
pub const panic = if (builtin.is_test)
    std.debug.FullPanic(std.debug.defaultPanic)
else
    std.debug.no_panic;

/// It is possible that this libc is being linked into a different test
/// compilation, as opposed to being tested itself. In such case,
/// `builtin.link_libc` will be `true` along with `builtin.is_test`.
///
/// When we don't have a complete libc, `builtin.link_libc` will be `false` and
/// we will be missing externally provided symbols, such as `_errno` from
/// ucrtbase.dll. In such case, we must avoid analyzing otherwise exported
/// functions because it would cause undefined symbol usage.
///
/// Unfortunately such logic cannot be automatically done in this function body
/// since `func` will always be analyzed by the time we get here, so `comptime`
/// blocks will need to each check for `builtin.link_libc` and skip exports
/// when the exported functions have libc dependencies not provided by this
/// compilation unit.
pub inline fn symbol(comptime func: *const anyopaque, comptime name: []const u8) void {
    @export(func, .{
        .name = name,
        // Normally, libc goes into a static archive, making all symbols
        // overridable. However, Zig supports including the libc functions as part
        // of the Zig Compilation Unit, so to support this use case we make all
        // symbols weak.
        .linkage = .weak,
        // For WebAssembly, hidden visibility allows the symbol to be resolved to
        // other modules, but will not export it to the host runtime.
        .visibility = .hidden,
    });
}

/// Given a low-level syscall return value, sets errno and returns `-1`, or on
/// success returns the result.
pub fn errno(syscall_return_value: usize) c_int {
    return switch (builtin.os.tag) {
        .linux => {
            const signed: isize = @bitCast(syscall_return_value);
            const casted: c_int = @intCast(signed);
            if (casted < 0) {
                @branchHint(.unlikely);
                std.c._errno().* = -casted;
                return -1;
            }
            return casted;
        },
        else => comptime unreachable,
    };
}

comptime {
    _ = @import("c/ctype.zig");
    _ = @import("c/fcntl.zig");
    _ = @import("c/inttypes.zig");
    if (!builtin.target.isMinGW()) {
        _ = @import("c/malloc.zig");
    }
    _ = @import("c/math.zig");
    _ = @import("c/search.zig");
    _ = @import("c/stdlib.zig");
    _ = @import("c/string.zig");
    _ = @import("c/strings.zig");
    _ = @import("c/stropts.zig");

    _ = @import("c/sys/capability.zig");
    _ = @import("c/sys/file.zig");
    _ = @import("c/sys/mman.zig");
    _ = @import("c/sys/reboot.zig");
    _ = @import("c/sys/utsname.zig");

    _ = @import("c/unistd.zig");
    _ = @import("c/wchar.zig");
}
