const std = @import("std");
const Io = std.Io;
const fatal = std.process.fatal;
const mem = std.mem;
const assert = std.debug.assert;

var stdout_buffer: [4000]u8 = undefined;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    var opt_input_path: ?[]const u8 = null;
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const arg = args[i];
        if (mem.startsWith(u8, arg, "-")) {
            if (mem.eql(u8, arg, "-h") or mem.eql(u8, arg, "--help")) {
                return Io.File.stdout().writeStreamingAll(io, usage);
            } else {
                fatal("unrecognized argument: {s}", .{arg});
            }
        } else if (opt_input_path == null) {
            opt_input_path = arg;
        } else {
            fatal("unexpected positional: {s}", .{arg});
        }
    }

    const input_path = opt_input_path orelse fatal("missing input file path positional argument", .{});

    var file = std.Io.Dir.cwd().openFile(io, input_path, .{}) catch |err|
        fatal("failed to open {s}: {t}", .{ input_path, err });
    defer file.close(io);

    var buffer: [4000]u8 = undefined;
    var file_reader = file.reader(io, &buffer);
    var stdout_writer = std.Io.File.stdout().writerStreaming(io, &stdout_buffer);
    dump(&file_reader.interface, &stdout_writer.interface) catch |err| switch (err) {
        error.ReadFailed => return file_reader.err.?,
        error.WriteFailed => return stdout_writer.err.?,
        error.UnknownFile => fatal("unrecognized file: {s}", .{input_path}),
        else => |e| return e,
    };
    try stdout_writer.flush();
}

fn dump(r: *Io.Reader, w: *Io.Writer) !void {
    try r.fill(4);
    elf: {
        if (!mem.eql(u8, r.buffered()[0..4], std.elf.MAGIC)) break :elf;
        return elf.dump(r, w);
    }
    macho: {
        if (mem.readInt(u32, r.buffered()[0..4], .little) != std.macho.MH_MAGIC_64) break :macho;
        return macho.dump(r, w);
    }
    wasm: {
        comptime assert(std.wasm.magic.len == 4);
        if (!mem.eql(u8, r.buffered()[0..4], &std.wasm.magic)) break :wasm;
        return wasm.dump(r, w);
    }
    return error.UnknownFile;
}

const elf = struct {
    fn dump(r: *Io.Reader, w: *Io.Writer) !void {
        _ = r;
        try w.writeAll("TODO dump elf file\n");
    }
};

const macho = struct {
    fn dump(r: *Io.Reader, w: *Io.Writer) !void {
        _ = r;
        try w.writeAll("TODO dump macho file\n");
    }
};

const wasm = struct {
    fn dump(r: *Io.Reader, w: *Io.Writer) !void {
        _ = r;
        try w.writeAll("TODO dump wasm file\n");
    }
};

const usage =
    \\Usage: zig objdump [options] file
    \\
    \\Options:
    \\  -h, --help                              Print this help and exit
    \\
;
