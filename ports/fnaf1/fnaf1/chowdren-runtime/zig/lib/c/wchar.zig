const builtin = @import("builtin");

const std = @import("std");
const wint_t = std.c.wint_t;
const wchar_t = std.c.wchar_t;

const symbol = @import("../c.zig").symbol;

comptime {
    if (builtin.target.isMuslLibC() or builtin.target.isWasiLibC()) {
        symbol(&wmemchr, "wmemchr");
        symbol(&wmemcmp, "wmemcmp");
        symbol(&wmemcpy, "wmemcpy");
        symbol(&wmemmove, "wmemmove");
        symbol(&wmemset, "wmemset");
        symbol(&wcslen, "wcslen");
        symbol(&wcsnlen, "wcsnlen");
        symbol(&wcscmp, "wcscmp");
        symbol(&wcsncmp, "wcsncmp");
        symbol(&wcpcpy, "wcpcpy");
        symbol(&wcpncpy, "wcpncpy");
        symbol(&wcscpy, "wcscpy");
        symbol(&wcsncpy, "wcsncpy");
        symbol(&wcscat, "wcscat");
        symbol(&wcsncat, "wcsncat");
        symbol(&wcschr, "wcschr");
        symbol(&wcsrchr, "wcsrchr");
        symbol(&wcsspn, "wcsspn");
        symbol(&wcscspn, "wcscspn");
        symbol(&wcspbrk, "wcspbrk");
        symbol(&wcstok, "wcstok");
        symbol(&wcsstr, "wcsstr");
        symbol(&wcswcs, "wcswcs");
    }

    if (builtin.target.isMinGW()) {
        symbol(&wmemchr, "wmemchr");
        symbol(&wmemcmp, "wmemcmp");
        symbol(&wmemcpy, "wmemcpy");
        symbol(&wmempcpy, "wmempcpy");
        symbol(&wmemmove, "wmemmove");
        symbol(&wmemset, "wmemset");
        symbol(&wcsnlen, "wcsnlen");
    }
}

fn wmemchr(ptr: [*]const wchar_t, value: wchar_t, len: usize) callconv(.c) ?[*]wchar_t {
    return @constCast(ptr[std.mem.findScalar(wchar_t, ptr[0..len], value) orelse return null ..]);
}

fn wmemcmp(a: [*]const wchar_t, b: [*]const wchar_t, len: usize) callconv(.c) c_int {
    return switch (std.mem.order(wchar_t, a[0..len], b[0..len])) {
        .eq => 0,
        .gt => 1,
        .lt => -1,
    };
}

fn wmemcpy(noalias dest: [*]wchar_t, noalias src: [*]const wchar_t, len: usize) callconv(.c) [*]wchar_t {
    @memcpy(dest[0..len], src[0..len]);
    return dest;
}

fn wmempcpy(noalias dest: [*]wchar_t, noalias src: [*]const wchar_t, len: usize) callconv(.c) [*]wchar_t {
    @memcpy(dest[0..len], src[0..len]);
    return dest + len;
}

fn wmemmove(dest: [*]wchar_t, src: [*]const wchar_t, len: usize) callconv(.c) [*]wchar_t {
    @memmove(dest[0..len], src[0..len]);
    return dest;
}

fn wmemset(dest: [*]wchar_t, elem: wchar_t, len: usize) callconv(.c) [*]wchar_t {
    @memset(dest[0..len], elem);
    return dest;
}

fn wcslen(str: [*:0]const wchar_t) callconv(.c) usize {
    return wcsnlen(str, std.math.maxInt(usize));
}

fn wcsnlen(str: [*:0]const wchar_t, max: usize) callconv(.c) usize {
    return std.mem.findScalar(wchar_t, str[0..max], 0) orelse max;
}

fn wcscmp(a: [*:0]const wchar_t, b: [*:0]const wchar_t) callconv(.c) c_int {
    return wcsncmp(a, b, std.math.maxInt(usize));
}

fn wcsncmp(a: [*:0]const wchar_t, b: [*:0]const wchar_t, max: usize) callconv(.c) c_int {
    return switch (std.mem.boundedOrderZ(wchar_t, a, b, max)) {
        .eq => 0,
        .gt => 1,
        .lt => -1,
    };
}

fn wcpcpy(noalias dst: [*]wchar_t, noalias src: [*:0]const wchar_t) callconv(.c) [*]wchar_t {
    const src_len = std.mem.len(src);
    @memcpy(dst[0 .. src_len + 1], src[0 .. src_len + 1]);
    return dst + src_len;
}

fn wcpncpy(noalias dst: [*]wchar_t, noalias src: [*:0]const wchar_t, max: usize) callconv(.c) [*]wchar_t {
    const src_len = wcsnlen(src, max);
    const copying_len = @min(max, src_len);
    @memcpy(dst[0..copying_len], src[0..copying_len]);
    @memset(dst[copying_len..][0 .. max - copying_len], 0x00);
    return dst + copying_len;
}

fn wcscpy(noalias dst: [*]wchar_t, noalias src: [*:0]const wchar_t) callconv(.c) [*]wchar_t {
    _ = wcpcpy(dst, src);
    return dst;
}

fn wcsncpy(noalias dst: [*]wchar_t, noalias src: [*:0]const wchar_t, max: usize) callconv(.c) [*]wchar_t {
    _ = wcpncpy(dst, src, max);
    return dst;
}

fn wcscat(noalias dst: [*:0]wchar_t, noalias src: [*:0]const wchar_t) callconv(.c) [*:0]wchar_t {
    return wcsncat(dst, src, std.math.maxInt(usize));
}

fn wcsncat(noalias dst: [*:0]wchar_t, noalias src: [*:0]const wchar_t, max: usize) callconv(.c) [*:0]wchar_t {
    const dst_len = std.mem.len(dst);
    const src_len = std.mem.len(src);
    const copying_len = @min(max, src_len);

    @memcpy(dst[dst_len..][0..copying_len], src[0..copying_len]);
    dst[dst_len + copying_len] = 0;
    return dst[0..(dst_len + copying_len) :0].ptr;
}

fn wcschr(str: [*:0]const wchar_t, value: wchar_t) callconv(.c) ?[*:0]wchar_t {
    const len = std.mem.len(str);

    if (value == 0) return @constCast(str + len);
    return @constCast(str[std.mem.findScalar(wchar_t, str[0..len], value) orelse return null ..]);
}

fn wcsrchr(str: [*:0]const wchar_t, value: wchar_t) callconv(.c) ?[*:0]wchar_t {
    // std.mem.len(str) + 1 to not special case '\0'
    return @constCast(str[std.mem.findScalarLast(wchar_t, str[0..(std.mem.len(str) + 1)], value) orelse return null ..]);
}

fn wcsspn(dst: [*:0]const wchar_t, values: [*:0]const wchar_t) callconv(.c) usize {
    const dst_slice = std.mem.span(dst);
    return std.mem.findNone(wchar_t, dst_slice, std.mem.span(values)) orelse dst_slice.len;
}

fn wcscspn(dst: [*:0]const wchar_t, values: [*:0]const wchar_t) callconv(.c) usize {
    const dst_slice = std.mem.span(dst);
    return std.mem.findAny(wchar_t, dst_slice, std.mem.span(values)) orelse dst_slice.len;
}

fn wcspbrk(haystack: [*:0]const wchar_t, needle: [*:0]const wchar_t) callconv(.c) ?[*:0]wchar_t {
    return @constCast(haystack[std.mem.findAny(wchar_t, std.mem.span(haystack), std.mem.span(needle)) orelse return null ..]);
}

fn wcstok(noalias maybe_str: ?[*:0]wchar_t, noalias values: [*:0]const wchar_t, noalias state: *?[*:0]wchar_t) callconv(.c) ?[*:0]wchar_t {
    const str = if (maybe_str) |str|
        str
    else if (state.*) |state_str|
        state_str
    else
        return null;

    const str_chars = std.mem.span(str);
    const values_chars = std.mem.span(values);
    const tok_start = std.mem.findNone(wchar_t, str_chars, values_chars) orelse return null;

    if (std.mem.findAnyPos(wchar_t, str_chars, tok_start, values_chars)) |tok_end| {
        str[tok_end] = 0;
        state.* = str[tok_end + 1 ..];
    } else {
        state.* = str[str_chars.len..];
    }

    return str[tok_start..];
}

fn wcsstr(noalias haystack: [*:0]const wchar_t, noalias needle: [*:0]const wchar_t) callconv(.c) ?[*:0]wchar_t {
    return @constCast(haystack[std.mem.find(wchar_t, std.mem.span(haystack), std.mem.span(needle)) orelse return null ..]);
}

fn wcswcs(noalias haystack: [*:0]const wchar_t, noalias needle: [*:0]const wchar_t) callconv(.c) ?[*:0]wchar_t {
    return wcsstr(haystack, needle);
}
