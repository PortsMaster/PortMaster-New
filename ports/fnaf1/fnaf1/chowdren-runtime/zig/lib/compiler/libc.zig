const std = @import("std");
const Io = std.Io;
const mem = std.mem;
const LibCInstallation = std.zig.LibCInstallation;

const usage_libc =
    \\Usage: zig libc
    \\
    \\    Detect the native libc installation and print the resulting
    \\    paths to stdout. You can save this into a file and then edit
    \\    the paths to create a cross compilation libc kit. Then you
    \\    can pass `--libc [file]` for Zig to use it.
    \\
    \\Usage: zig libc [paths_file]
    \\
    \\    Parse a libc installation text file and validate it.
    \\
    \\Options:
    \\  -h, --help             Print this help and exit
    \\  -target [name]         <arch><sub>-<os>-<abi> see the targets command
    \\  -includes              Print the libc include directories for the target
    \\
;

var stdout_buffer: [4096]u8 = undefined;

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const gpa = init.gpa;
    const io = init.io;
    const args = try init.minimal.args.toSlice(arena);
    const environ_map = init.environ_map;

    const zig_lib_directory = args[1];

    var input_file: ?[]const u8 = null;
    var target_arch_os_abi: []const u8 = "native";
    var print_includes: bool = false;
    var stdout_writer = Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_writer.interface;
    {
        var i: usize = 2;
        while (i < args.len) : (i += 1) {
            const arg = args[i];
            if (mem.startsWith(u8, arg, "-")) {
                if (mem.eql(u8, arg, "-h") or mem.eql(u8, arg, "--help")) {
                    try stdout.writeAll(usage_libc);
                    try stdout.flush();
                    return std.process.cleanExit(io);
                } else if (mem.eql(u8, arg, "-target")) {
                    if (i + 1 >= args.len) fatal("expected parameter after {s}", .{arg});
                    i += 1;
                    target_arch_os_abi = args[i];
                } else if (mem.eql(u8, arg, "-includes")) {
                    print_includes = true;
                } else {
                    fatal("unrecognized parameter: '{s}'", .{arg});
                }
            } else if (input_file != null) {
                fatal("unexpected extra parameter: '{s}'", .{arg});
            } else {
                input_file = arg;
            }
        }
    }

    const target_query = std.zig.parseTargetQueryOrReportFatalError(gpa, .{
        .arch_os_abi = target_arch_os_abi,
    });
    const target = std.zig.resolveTargetQueryOrFatal(io, target_query);

    if (print_includes) {
        const libc_installation: ?*LibCInstallation = libc: {
            if (input_file) |libc_file| {
                const libc = try arena.create(LibCInstallation);
                libc.* = LibCInstallation.parse(arena, io, libc_file, &target) catch |err| {
                    fatal("unable to parse libc file at path {s}: {t}", .{ libc_file, err });
                };
                break :libc libc;
            } else {
                break :libc null;
            }
        };

        const is_native_abi = target_query.isNativeAbi();

        const libc_dirs = std.zig.LibCDirs.detect(
            arena,
            io,
            zig_lib_directory,
            &target,
            is_native_abi,
            true,
            libc_installation,
            environ_map,
        ) catch |err| {
            const zig_target = try target.zigTriple(arena);
            fatal("unable to detect libc for target {s}: {t}", .{ zig_target, err });
        };

        if (libc_dirs.libc_include_dir_list.len == 0) {
            const zig_target = try target.zigTriple(arena);
            fatal("no include dirs detected for target {s}", .{zig_target});
        }

        for (libc_dirs.libc_include_dir_list) |include_dir| {
            try stdout.writeAll(include_dir);
            try stdout.writeByte('\n');
        }
        try stdout.flush();
        return std.process.cleanExit(io);
    }

    if (input_file) |libc_file| {
        var libc = LibCInstallation.parse(gpa, io, libc_file, &target) catch |err| {
            fatal("unable to parse libc file at path {s}: {t}", .{ libc_file, err });
        };
        defer libc.deinit(gpa);
    } else {
        if (!target_query.canDetectLibC()) {
            fatal("unable to detect libc for non-native target", .{});
        }
        var libc = LibCInstallation.findNative(gpa, io, .{
            .verbose = true,
            .target = &target,
            .environ_map = environ_map,
        }) catch |err| {
            fatal("unable to detect native libc: {t}", .{err});
        };
        defer libc.deinit(gpa);

        try libc.render(stdout);
        try stdout.flush();
    }
}

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.log.err(format, args);
    std.process.exit(1);
}
