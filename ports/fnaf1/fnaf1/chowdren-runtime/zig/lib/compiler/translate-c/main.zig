const std = @import("std");
const assert = std.debug.assert;
const mem = std.mem;
const process = std.process;
const Io = std.Io;

const aro = @import("aro");
const compiler_util = @import("../util.zig");

const Translator = @import("Translator.zig");

const fast_exit = @import("builtin").mode != .Debug;

pub fn main(init: process.Init) u8 {
    const gpa = init.gpa;
    const arena = init.arena.allocator();
    const io = init.io;
    const environ_map = init.environ_map;

    const args = init.minimal.args.toSlice(arena) catch {
        std.debug.print("ran out of memory allocating arguments\n", .{});
        if (fast_exit) process.exit(1);
        return 1;
    };

    var zig_integration = false;
    if (args.len > 1 and std.mem.eql(u8, args[1], "--zig-integration")) {
        zig_integration = true;
    }

    const NO_COLOR = std.zig.EnvVar.NO_COLOR.isSet(environ_map);
    const CLICOLOR_FORCE = std.zig.EnvVar.CLICOLOR_FORCE.isSet(environ_map);

    var stderr_buf: [1024]u8 = undefined;
    var stderr = Io.File.stderr().writer(io, &stderr_buf);
    var diagnostics: aro.Diagnostics = switch (zig_integration) {
        false => .{ .output = .{ .to_writer = .{
            .mode = Io.Terminal.Mode.detect(io, stderr.file, NO_COLOR, CLICOLOR_FORCE) catch .no_color,
            .writer = &stderr.interface,
        } } },
        true => .{ .output = .{ .to_list = .{ .arena = .init(gpa) } } },
    };
    defer diagnostics.deinit();

    var comp = aro.Compilation.init(.{
        .gpa = gpa,
        .arena = arena,
        .io = io,
        .diagnostics = &diagnostics,
        .environ_map = environ_map,
    }) catch |err| switch (err) {
        error.OutOfMemory => {
            std.debug.print("ran out of memory initializing C compilation\n", .{});
            if (fast_exit) process.exit(1);
            return 1;
        },
    };
    defer comp.deinit();

    var driver: aro.Driver = .{ .comp = &comp, .diagnostics = &diagnostics, .aro_name = "aro" };
    defer driver.deinit();

    var toolchain: aro.Toolchain = .{ .driver = &driver };
    defer toolchain.deinit();

    translate(&driver, &toolchain, args, zig_integration) catch |err| switch (err) {
        error.OutOfMemory => {
            std.debug.print("ran out of memory translating\n", .{});
            if (fast_exit) process.exit(1);
            return 1;
        },
        error.FatalError => if (zig_integration) {
            serveErrorBundle(arena, io, &diagnostics) catch |bundle_err| {
                std.debug.print("unable to serve error bundle: {}\n", .{bundle_err});
                if (fast_exit) process.exit(1);
                return 1;
            };

            if (fast_exit) process.exit(0);
            return 0;
        } else {
            if (fast_exit) process.exit(1);
            return 1;
        },
        error.WriteFailed => {
            std.debug.print("unable to write to stdout\n", .{});
            if (fast_exit) process.exit(1);
            return 1;
        },
    };
    assert(comp.diagnostics.errors == 0 or !zig_integration);
    if (fast_exit) process.exit(@intFromBool(comp.diagnostics.errors != 0));
    return @intFromBool(comp.diagnostics.errors != 0);
}

fn serveErrorBundle(arena: std.mem.Allocator, io: Io, diagnostics: *const aro.Diagnostics) !void {
    const error_bundle = try compiler_util.aroDiagnosticsToErrorBundle(
        diagnostics,
        arena,
        "translation failure",
    );
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = Io.File.stdout().writer(io, &stdout_buffer);
    var server: std.zig.Server = .{
        .out = &stdout_writer.interface,
        .in = undefined,
    };
    try server.serveErrorBundle(error_bundle);
}

pub const usage =
    \\Usage {s}: [options] file [CC options]
    \\
    \\Options:
    \\  --help                      Print this message
    \\  --version                   Print translate-c version
    \\  -fmodule-libs               Import libraries as modules
    \\  -fno-module-libs            (default) Install libraries next to output file
    \\  -fpub-static                (default) Translate static functions as pub
    \\  -fno-pub-static             Do not translate static functions as pub
    \\  -ffunc-bodies               (default) Translate function bodies
    \\  -fno-func-bodies            Do not translate function bodies
    \\  -fkeep-macro-literals       (default) Preserve macro names for literals
    \\  -fno-keep-macro-literals    Do not preserve macro names for literals
    \\  -fdefault-init              Default initialize struct fields
    \\  -fno-default-init           (default) Do not default initialize struct fields
    \\  -fstrict-flex-arrays=<n>    Control when to treat a trailing array as a flexible array member (default: 2)
    \\                                0: any trailing array
    \\                                1: size [0]/[1]/[]
    \\                                2: size [0]/[]
    \\                                3: [] only
    \\
    \\
;

fn translate(d: *aro.Driver, tc: *aro.Toolchain, args: []const [:0]const u8, zig_integration: bool) !void {
    const gpa = d.comp.gpa;
    const io = d.comp.io;

    var module_libs = true;
    var pub_static = true;
    var func_bodies = true;
    var keep_macro_literals = true;
    var default_init = true;
    var strict_flex_arrays: Translator.StrictFlexArraysLevel = .@"2";

    var aro_args: std.ArrayList([:0]const u8) = try .initCapacity(gpa, args.len);
    defer aro_args.deinit(gpa);

    for (args, 0..) |arg, i| {
        if (mem.eql(u8, arg, "--help")) {
            var stdout_buf: [512]u8 = undefined;
            var stdout = Io.File.stdout().writer(io, &stdout_buf);
            try stdout.interface.print(usage, .{args[0]});
            try stdout.interface.flush();
            return;
        } else if (mem.eql(u8, arg, "--version")) {
            var stdout_buf: [512]u8 = undefined;
            var stdout = Io.File.stdout().writer(io, &stdout_buf);
            // TODO add version
            try stdout.interface.writeAll("0.0.0-dev\n");
            try stdout.interface.flush();
            return;
        } else if (mem.eql(u8, arg, "--zig-integration")) {
            if (i != 1 or !zig_integration)
                return d.fatal("--zig-integration must be the first argument", .{});
        } else if (mem.eql(u8, arg, "-fmodule-libs")) {
            module_libs = true;
        } else if (mem.eql(u8, arg, "-fno-module-libs")) {
            module_libs = false;
        } else if (mem.eql(u8, arg, "-fpub-static")) {
            pub_static = true;
        } else if (mem.eql(u8, arg, "-fno-pub-static")) {
            pub_static = false;
        } else if (mem.eql(u8, arg, "-ffunc-bodies")) {
            func_bodies = true;
        } else if (mem.eql(u8, arg, "-fno-func-bodies")) {
            func_bodies = false;
        } else if (mem.eql(u8, arg, "-fkeep-macro-literals")) {
            keep_macro_literals = true;
        } else if (mem.eql(u8, arg, "-fno-keep-macro-literals")) {
            keep_macro_literals = false;
        } else if (mem.eql(u8, arg, "-fdefault-init")) {
            default_init = true;
        } else if (mem.eql(u8, arg, "-fno-default-init")) {
            default_init = false;
        } else if (mem.startsWith(u8, arg, "-fstrict-flex-arrays=")) {
            const val_str = arg["-fstrict-flex-arrays=".len..];
            if (val_str.len != 1 or val_str[0] < '0' or val_str[0] > '3') {
                return d.fatal("-fstrict-flex-arrays= requires a value of '0', '1', '2', or '3'", .{});
            }
            strict_flex_arrays = @enumFromInt(val_str[0] - '0');
        } else {
            aro_args.appendAssumeCapacity(arg);
        }
    }
    const user_macros = macros: {
        var macro_buf: std.ArrayList(u8) = .empty;
        defer macro_buf.deinit(gpa);

        var discard_buf: [256]u8 = undefined;
        var discarding: Io.Writer.Discarding = .init(&discard_buf);
        assert(!try d.parseArgs(&discarding.writer, &macro_buf, aro_args.items));
        if (macro_buf.items.len > std.math.maxInt(u32)) {
            return d.fatal("user provided macro source exceeded max size", .{});
        }

        const has_output_file = if (d.output_name) |path|
            !std.mem.eql(u8, path, "-")
        else
            false;
        if (zig_integration and !has_output_file) {
            return d.fatal("--zig-integration requires specifying an output file", .{});
        }

        const content = try macro_buf.toOwnedSlice(gpa);
        errdefer gpa.free(content);

        break :macros try d.comp.addSourceFromOwnedBuffer("<command line>", content, .user);
    };

    if (d.inputs.items.len != 1) {
        return d.fatal("expected exactly one input file", .{});
    }
    const source = d.inputs.items[0];

    tc.discover() catch |er| switch (er) {
        error.OutOfMemory => return error.OutOfMemory,
        error.TooManyMultilibs => return d.fatal("found more than one multilib with the same priority", .{}),
    };
    try tc.defineSystemIncludes();
    try d.comp.initSearchPath(d.includes.items, d.verbose_search_path);

    const builtin_macros = d.comp.generateBuiltinMacros(d.system_defines) catch |err| switch (err) {
        error.FileTooBig => return d.fatal("builtin macro source exceeded max size", .{}),
        else => |e| return e,
    };

    var pp = try aro.Preprocessor.init(d.comp, .{
        .base_file = source.id,
    });
    defer pp.deinit();

    var name_buf: [std.fs.max_name_bytes]u8 = undefined;
    // Omit the source file from the dep file so that it can be tracked separately.
    // In the Zig compiler we want to omit it from the cache hash since it will
    // be written to a tmp file then renamed into place, meaning the path will be
    // wrong as soon as the work is done.
    var opt_dep_file = try d.initDepFile(source, &name_buf, true);
    defer if (opt_dep_file) |*dep_file| dep_file.deinit(gpa);

    if (opt_dep_file) |*dep_file| pp.dep_file = dep_file;

    try pp.preprocessSources(.{
        .main = source,
        .builtin = builtin_macros,
        .command_line = user_macros,
        .imacros = d.imacros.items,
        .implicit_includes = d.implicit_includes.items,
    });

    var c_tree = try pp.parse();
    defer c_tree.deinit();

    if (d.diagnostics.errors != 0) {
        if (fast_exit and !zig_integration) process.exit(1);
        return error.FatalError;
    }

    var out_buf: [4096]u8 = undefined;
    if (opt_dep_file) |dep_file| {
        const dep_file_name = try d.getDepFileName(source, out_buf[0..std.fs.max_name_bytes]);

        const file = if (dep_file_name) |path|
            d.comp.cwd.createFile(io, path, .{}) catch |er|
                return d.fatal("unable to create dependency file '{s}': {s}", .{ path, aro.Driver.errorDescription(er) })
        else
            Io.File.stdout();
        defer if (dep_file_name != null) file.close(io);

        var file_writer = file.writer(io, &out_buf);
        dep_file.write(&file_writer.interface) catch
            return d.fatal("unable to write dependency file: {s}", .{aro.Driver.errorDescription(file_writer.err.?)});
    }

    const rendered_zig = try Translator.translate(.{
        .gpa = gpa,
        .comp = d.comp,
        .pp = &pp,
        .tree = &c_tree,
        .module_libs = module_libs,
        .pub_static = pub_static,
        .func_bodies = func_bodies,
        .keep_macro_literals = keep_macro_literals,
        .default_init = default_init,
        .strict_flex_arrays = strict_flex_arrays,
    });
    defer gpa.free(rendered_zig);

    var close_out_file = false;
    var out_file_path: []const u8 = "<stdout>";
    var out_file: Io.File = .stdout();
    defer if (close_out_file) out_file.close(io);

    if (d.output_name) |path| blk: {
        if (std.mem.eql(u8, path, "-")) break :blk;
        if (std.fs.path.dirname(path)) |dirname| {
            Io.Dir.cwd().createDirPath(io, dirname) catch |err|
                return d.fatal("failed to create path to '{s}': {s}", .{ path, aro.Driver.errorDescription(err) });
        }
        out_file = Io.Dir.cwd().createFile(io, path, .{}) catch |err| {
            return d.fatal("failed to create output file '{s}': {s}", .{ path, aro.Driver.errorDescription(err) });
        };
        close_out_file = true;
        out_file_path = path;
    }

    var out_writer = out_file.writer(io, &out_buf);
    out_writer.interface.writeAll(rendered_zig) catch {};
    out_writer.interface.flush() catch {};
    if (out_writer.err) |write_err|
        return d.fatal("failed to write result to '{s}': {s}", .{ out_file_path, aro.Driver.errorDescription(write_err) });

    if (fast_exit and !zig_integration) process.exit(0);
}

test {
    _ = Translator;
    _ = @import("helpers.zig");
    _ = @import("PatternList.zig");
}
