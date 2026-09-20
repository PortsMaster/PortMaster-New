const std = @import("std");
const Io = std.Io;

pub const UncheckedSliceWriter = struct {
    const Self = @This();

    pos: usize = 0,
    slice: []u8,

    pub fn write(self: *Self, char: u8) void {
        self.slice[self.pos] = char;
        self.pos += 1;
    }

    pub fn writeSlice(self: *Self, slice: []const u8) void {
        for (slice) |c| {
            self.write(c);
        }
    }

    pub fn getWritten(self: Self) []u8 {
        return self.slice[0..self.pos];
    }
};

/// Emulates the Windows implementation of `iswdigit`, but only returns true
/// for the non-ASCII digits that `iswdigit` on Windows would return true for.
pub fn isNonAsciiDigit(c: u21) bool {
    return switch (c) {
        '²',
        '³',
        '¹',
        '\u{660}'...'\u{669}',
        '\u{6F0}'...'\u{6F9}',
        '\u{7C0}'...'\u{7C9}',
        '\u{966}'...'\u{96F}',
        '\u{9E6}'...'\u{9EF}',
        '\u{A66}'...'\u{A6F}',
        '\u{AE6}'...'\u{AEF}',
        '\u{B66}'...'\u{B6F}',
        '\u{BE6}'...'\u{BEF}',
        '\u{C66}'...'\u{C6F}',
        '\u{CE6}'...'\u{CEF}',
        '\u{D66}'...'\u{D6F}',
        '\u{E50}'...'\u{E59}',
        '\u{ED0}'...'\u{ED9}',
        '\u{F20}'...'\u{F29}',
        '\u{1040}'...'\u{1049}',
        '\u{1090}'...'\u{1099}',
        '\u{17E0}'...'\u{17E9}',
        '\u{1810}'...'\u{1819}',
        '\u{1946}'...'\u{194F}',
        '\u{19D0}'...'\u{19D9}',
        '\u{1B50}'...'\u{1B59}',
        '\u{1BB0}'...'\u{1BB9}',
        '\u{1C40}'...'\u{1C49}',
        '\u{1C50}'...'\u{1C59}',
        '\u{A620}'...'\u{A629}',
        '\u{A8D0}'...'\u{A8D9}',
        '\u{A900}'...'\u{A909}',
        '\u{AA50}'...'\u{AA59}',
        '\u{FF10}'...'\u{FF19}',
        => true,
        else => false,
    };
}

pub const ErrorMessageType = enum { err, warning, note };

pub fn renderErrorMessageToStderr(io: std.Io, msg_type: ErrorMessageType, comptime format: []const u8, args: anytype) !void {
    var stderr = try io.lockStderr(&.{}, null);
    defer io.unlockStderr();
    try renderErrorMessage(stderr.terminal(), msg_type, format, args);
}

/// Used for generic colored errors/warnings/notes, more context-specific error messages
/// are handled elsewhere.
pub fn renderErrorMessage(t: Io.Terminal, msg_type: ErrorMessageType, comptime format: []const u8, args: anytype) !void {
    const writer = t.writer;
    switch (msg_type) {
        .err => {
            try t.setColor(.bold);
            try t.setColor(.red);
            try writer.writeAll("error: ");
        },
        .warning => {
            try t.setColor(.bold);
            try t.setColor(.yellow);
            try writer.writeAll("warning: ");
        },
        .note => {
            try t.setColor(.reset);
            try t.setColor(.cyan);
            try writer.writeAll("note: ");
        },
    }
    try t.setColor(.reset);
    if (msg_type == .err) {
        try t.setColor(.bold);
    }
    try writer.print(format, args);
    try writer.writeByte('\n');
    try t.setColor(.reset);
}

pub fn isLineEndingPair(first: u8, second: u8) bool {
    if (first != '\r' and first != '\n') return false;
    if (second != '\r' and second != '\n') return false;

    // can't be \n\n or \r\r
    if (first == second) return false;

    return true;
}
