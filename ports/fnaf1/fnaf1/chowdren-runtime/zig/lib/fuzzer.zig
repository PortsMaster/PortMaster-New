const builtin = @import("builtin");

const std = @import("std");
const Io = std.Io;
const mem = std.mem;
const math = std.math;
const assert = std.debug.assert;
const panic = std.debug.panic;
const abi = std.Build.abi.fuzz;
const Uid = abi.Uid;

pub const std_options = std.Options{
    .logFn = logOverride,
};

const io = Io.Threaded.global_single_threaded.io();

fn logOverride(
    comptime level: std.log.Level,
    comptime scope: @EnumLiteral(),
    comptime format: []const u8,
    args: anytype,
) void {
    const f = log_f orelse panic("log before initialization, message:\n" ++ format, args);
    f.lock(io, .exclusive) catch |e| panic("failed to lock logging file: {t}", .{e});
    defer f.unlock(io);

    var buf: [256]u8 = undefined;
    var fw = f.writer(io, &buf);
    const end = f.length(io) catch |e| panic("failed to get fuzzer log file end: {t}", .{e});
    fw.seekTo(end) catch |e| panic("failed to seek to fuzzer log file end: {t}", .{e});

    const prefix1 = comptime level.asText();
    const prefix2 = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";
    fw.interface.print(
        "[{s}] " ++ prefix1 ++ prefix2 ++ format ++ "\n",
        .{current_test_name orelse "setup"} ++ args,
    ) catch panic("failed to write to fuzzer log: {t}", .{fw.err.?});
    fw.interface.flush() catch panic("failed to write to fuzzer log: {t}", .{fw.err.?});
}

var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
const gpa = switch (builtin.mode) {
    .Debug => debug_allocator.allocator(),
    .ReleaseFast, .ReleaseSmall, .ReleaseSafe => std.heap.smp_allocator,
};

// Seperate from `exec` to allow initialization before `exec` is.
var log_f: ?Io.File = null;
var exec: Executable = undefined;
var fuzzer: Fuzzer = undefined;
var current_test_name: ?[]const u8 = null;

fn bitsetUsizes(elems: usize) usize {
    return math.divCeil(usize, elems, @bitSizeOf(usize)) catch unreachable;
}

const Executable = struct {
    /// Tracks the hit count for each pc as updated by the test's instrumentation.
    pc_counters: []u8,

    cache_f: Io.Dir,
    /// Shared copy of all pcs that have been hit stored in a memory-mapped file that can viewed
    /// while the fuzzer is running.
    shared_seen_pcs: []align(std.heap.page_size_min) volatile u8,
    /// Hash of pcs used to uniquely identify the shared coverage file
    pc_digest: u64,

    fn getCoverageMap(
        cache_dir: Io.Dir,
        pcs: []const usize,
        pc_digest: u64,
    ) []align(std.heap.page_size_min) volatile u8 {
        const file_name = std.fmt.hex(pc_digest);

        var v = cache_dir.createDirPathOpen(io, "v", .{}) catch |e|
            panic("failed to create directory 'v': {t}", .{e});
        defer v.close(io);

        // Since acquiring locks in createFile is not gauraunteed to be atomic, it is not possible
        // to ensure if we create the file we obtain an exclusive lock to populate it since another
        // process may acquire a shared lock between the file being created and the lock request.
        //
        // Instead, the length will be used to determine if the file needs populated, and no
        // process will acquire a shared lock before the coverage file is known to have been
        // exclusively locked (i.e. is already locked). This means another process than the
        // one which created the file could populate it, which is fine.
        const coverage_file = v.createFile(io, &file_name, .{
            .read = true,
            .truncate = false,
        }) catch |e| panic("failed to open coverage file '{s}': {t}", .{ &file_name, e });

        const maybe_populate = coverage_file.tryLock(io, .exclusive) catch |e| panic(
            "failed to acquire exclusive lock coverage file '{s}': {t}",
            .{ &file_name, e },
        );
        if (!maybe_populate) {
            coverage_file.lock(io, .shared) catch |e|
                panic("failed to acquire share lock coverage file '{s}': {t}", .{ &file_name, e });
        }

        comptime assert(abi.SeenPcsHeader.trailing[0] == .pc_bits_usize);
        comptime assert(abi.SeenPcsHeader.trailing[1] == .pc_addr);
        const pc_bitset_usizes = bitsetUsizes(pcs.len);
        const coverage_file_len = @sizeOf(abi.SeenPcsHeader) +
            pc_bitset_usizes * @sizeOf(usize) +
            pcs.len * @sizeOf(usize);

        var populate: bool = false;
        const size = coverage_file.length(io) catch |e|
            panic("failed to stat coverage file '{s}': {t}", .{ &file_name, e });
        if (size == 0 and maybe_populate) {
            coverage_file.setLength(io, coverage_file_len) catch |e|
                panic("failed to resize new coverage file '{s}': {t}", .{ &file_name, e });
            populate = true;
        } else if (size != coverage_file_len) {
            panic(
                "incompatible existing coverage file '{s}' (differing lengths: {} != {})",
                .{ &file_name, size, coverage_file_len },
            );
        } else if (maybe_populate) {
            coverage_file.lock(io, .shared) catch |e|
                panic("failed to demote lock for coverage file '{s}': {t}", .{ &file_name, e });
        }

        var io_map = coverage_file.createMemoryMap(io, .{ .len = coverage_file_len }) catch |e|
            panic("failed to memmap coverage file '{s}': {t}", .{ &file_name, e });
        const map = io_map.memory;

        const header: *abi.SeenPcsHeader = @ptrCast(map[0..@sizeOf(abi.SeenPcsHeader)]);
        const trailing = map[@sizeOf(abi.SeenPcsHeader)..];
        const trailing_bitset_end = pc_bitset_usizes * @sizeOf(usize);
        const trailing_bitset: []usize = @ptrCast(@alignCast(trailing[0..trailing_bitset_end]));
        const trailing_addresses: []usize = @ptrCast(@alignCast(trailing[trailing_bitset_end..]));

        if (populate) {
            header.* = .{
                .n_runs = 0,
                .unique_runs = 0,
                .pcs_len = pcs.len,
            };
            @memset(trailing_bitset, 0);
            for (trailing_addresses, pcs) |*cov_pc, slided_pc| {
                cov_pc.* = fuzzer_unslide_address(slided_pc);
            }
            io_map.write(io) catch |e|
                panic("failed to write memory map of '{s}': {t}", .{ &file_name, e });

            coverage_file.lock(io, .shared) catch |e| panic(
                "failed to demote lock for coverage file '{s}': {t}",
                .{ &file_name, e },
            );
        } else { // Check expected contents
            if (header.pcs_len != pcs.len) panic(
                "incompatible existing coverage file '{s}' (differing pcs length: {} != {})",
                .{ &file_name, header.pcs_len, pcs.len },
            );
            for (0.., header.pcAddrs(), pcs) |i, cov_pc, slided_pc| {
                const pc = fuzzer_unslide_address(slided_pc);
                if (cov_pc != pc) panic(
                    "incompatible existing coverage file '{s}' (differing pc at index {d}: {x} != {x})",
                    .{ &file_name, i, cov_pc, pc },
                );
            }
        }
        return map;
    }

    pub fn init(cache_dir_path: []const u8) Executable {
        var self: Executable = undefined;

        const cache_dir = Io.Dir.cwd().createDirPathOpen(io, cache_dir_path, .{}) catch |e|
            panic("failed to open directory '{s}': {t}", .{ cache_dir_path, e });
        log_f = cache_dir.createFile(io, "tmp/libfuzzer.log", .{ .truncate = false }) catch |e|
            panic("failed to create file 'tmp/libfuzzer.log': {t}", .{e});
        self.cache_f = cache_dir.createDirPathOpen(io, "f", .{}) catch |e|
            panic("failed to open directory 'f': {t}", .{e});

        // Linkers are expected to automatically add symbols prefixed with these for the start and
        // end of sections whose names are valid C identifiers.
        const ofmt = builtin.object_format;
        const section_start_prefix, const section_end_prefix = switch (ofmt) {
            .elf => .{ "__start_", "__stop_" },
            .macho => .{ "\x01section$start$__DATA$", "\x01section$end$__DATA$" },
            else => @compileError("unsupported fuzzing object format '" ++ @tagName(ofmt) ++ "'"),
        };

        self.pc_counters = blk: {
            const pc_counters_start_name = section_start_prefix ++ "__sancov_cntrs";
            const pc_counters_start = @extern([*]u8, .{
                .name = pc_counters_start_name,
                .linkage = .weak,
            }) orelse panic("missing {s} symbol", .{pc_counters_start_name});

            const pc_counters_end_name = section_end_prefix ++ "__sancov_cntrs";
            const pc_counters_end = @extern([*]u8, .{
                .name = pc_counters_end_name,
                .linkage = .weak,
            }) orelse panic("missing {s} symbol", .{pc_counters_end_name});

            break :blk pc_counters_start[0 .. pc_counters_end - pc_counters_start];
        };

        const pcs = blk: {
            const pcs_start_name = section_start_prefix ++ "__sancov_pcs1";
            const pcs_start = @extern([*]usize, .{
                .name = pcs_start_name,
                .linkage = .weak,
            }) orelse panic("missing {s} symbol", .{pcs_start_name});

            const pcs_end_name = section_end_prefix ++ "__sancov_pcs1";
            const pcs_end = @extern([*]usize, .{
                .name = pcs_end_name,
                .linkage = .weak,
            }) orelse panic("missing {s} symbol", .{pcs_end_name});

            break :blk pcs_start[0 .. pcs_end - pcs_start];
        };

        if (self.pc_counters.len != pcs.len) panic(
            "pc counters length and pcs length do not match ({} != {})",
            .{ self.pc_counters.len, pcs.len },
        );

        self.pc_digest = digest: {
            // Relocations have been applied to `pcs` so it contains runtime addresses (with slide
            // applied). We need to translate these to the virtual addresses as on disk.
            var h: std.hash.Wyhash = .init(0);
            for (pcs) |pc| {
                const pc_vaddr = fuzzer_unslide_address(pc);
                h.update(@ptrCast(&pc_vaddr));
            }
            break :digest h.final();
        };
        self.shared_seen_pcs = getCoverageMap(cache_dir, pcs, self.pc_digest);

        return self;
    }

    /// Asserts `buf[0..2]` is "in"
    fn inputFileName(buf: *[10]u8, i: u32) []u8 {
        assert(buf[0..2].* == "in".*);
        const hex = std.fmt.bufPrint(buf[2..], "{x}", .{i}) catch unreachable;
        return buf[0 .. 2 + hex.len];
    }

    pub fn pcBitsetIterator(self: Executable) PcBitsetIterator {
        return .{ .pc_counters = self.pc_counters };
    }

    /// Iterates over pc_counters returning a bitset for if each of them have been hit
    pub const PcBitsetIterator = struct {
        index: usize = 0,
        pc_counters: []u8,

        pub fn next(i: *PcBitsetIterator) usize {
            const rest = i.pc_counters[i.index..];
            if (rest.len >= @bitSizeOf(usize)) {
                defer i.index += @bitSizeOf(usize);
                const V = @Vector(@bitSizeOf(usize), u8);
                return @as(usize, @bitCast(@as(V, @splat(0)) != rest[0..@bitSizeOf(usize)].*));
            } else if (rest.len != 0) {
                defer i.index += rest.len;
                var res: usize = 0;
                for (0.., rest) |bit_index, byte| {
                    res |= @shlExact(@as(usize, @intFromBool(byte != 0)), @intCast(bit_index));
                }
                return res;
            } else unreachable;
        }
    };

    pub fn seenPcsHeader(e: Executable) *align(std.heap.page_size_min) volatile abi.SeenPcsHeader {
        return mem.bytesAsValue(
            abi.SeenPcsHeader,
            e.shared_seen_pcs[0..@sizeOf(abi.SeenPcsHeader)],
        );
    }
};

const Fuzzer = struct {
    tests: []Test,
    test_i: u32,
    test_one: abi.TestOne,

    // The default PRNG is not used here since going through `Random` can be very expensive
    // since LLVM often fails to devirtualize and inline `fill`. Additionally, optimization
    // is simpler since integers are not serialized then deserialized in the random stream.
    //
    // This acounts for a 30% performance improvement with LLVM 21.
    xoshiro: std.Random.Xoshiro256,
    bytes_input: std.testing.Smith,
    input_builder: Input.Builder,
    /// Number of data calls the current run has made.
    req_values: u32,
    /// Number of bytes provided to the current run.
    req_bytes: u32,
    /// Index into the uid slices the current run is at.
    /// `uid_data_i[i]` corresponds to `corpus[corpus_pos].data.uid_slices.values()[i]`.
    uid_data_i: std.ArrayList(u32),
    mut_data: struct {
        /// Untyped indexes of `corpus[corpus_pos].data` that should be mutated.
        ///
        /// If an index appears multiple times, the first should be prioritized.
        i: [4]u32,
        /// For mutations which are a sequential mutation, the state is stored here.
        seq: [4]struct {
            kind: packed struct {
                class: enum(u1) { replace, insert },
                copy: bool,
                /// If set then `.copy = true` and `.class = .replace`
                ordered_mutate: bool,
                /// If set then all other bits are undefined
                none: bool,
            },
            len: u32,
            copy: SeqCopy,
        },
    },

    /// As values are provided to the Smith, they are appended to this. If the test
    /// crashes, this can be recovered and used to obtain the crashing values. It is
    /// also used to rerun fresh inputs.
    mmap_input: MemoryMappedInput,
    /// The instance is responsible for updating the filesystem corpus.
    ///
    /// Since different fuzzer instances can be out of sync due to finding inputs before recieving
    /// others and nondeterministic tests, the filesystem is only based off the first instance.
    main_instance: bool,

    const Test = struct {
        const NameHash = u64;
        const dirname_len = @sizeOf(NameHash) * 2;

        seen_pcs: []usize,
        bests: struct {
            len: u32,
            quality_buf: []Input.Best,
            input_buf: []Input.Best.Map,
        },
        seen_uids: std.ArrayHashMapUnmanaged(Uid, struct {
            slices: union {
                ints: std.ArrayList([]u64),
                bytes: std.ArrayList(Input.Data.Bytes),
            },
        }, Uid.hashmap_ctx, false),

        /// Past inputs leading to new pc or uid hits.
        /// These are randomly mutated in round-robin fashion.
        corpus: std.MultiArrayList(Input),
        corpus_pos: Input.Index,
        /// If this is `math.maxInt(u32)` (reserved), it means the corpus has not been loaded from
        /// the filesystem.
        ///
        /// If `main_instance` is set, the values in `corpus` after this are mirrored to the
        /// filesystem.
        start_mut_corpus: u32,
        dirname: [dirname_len]u8,
        /// Ensures only one fuzzer writes to the corpus.
        ///
        /// Undefined if this is not the main instance.
        lock_file: Io.File,
        received: Received,

        limit: ?u64,
        /// A batch is the amount of cycles approximently for one second of runtime.
        ///
        /// This value is set to the previous batch's runs per second or run limit.
        batch_cycles: u32,
        batches: u64,
        batches_since_find: u64,
        seen_pc_count: u32,
    };

    const Received = struct {
        state: State,
        /// Stream of inputs with each prefixed with a u32 length
        inputs: std.ArrayList(u8),

        pub const empty: Received = .{
            .state = .{
                .pending = false,
                .read_lock = false,
                .write_lock = false,
            },
            .inputs = .empty,
        };

        pub const State = packed struct(u32) {
            pending: bool,
            read_lock: bool,
            /// If set in conjucation with `read_lock`, then there is a waiter on state.
            write_lock: bool,
            _: u29 = 0,

            pub fn hasPending(s: *State) bool {
                return @atomicLoad(State, s, .monotonic).pending;
            }

            pub fn startReadIfPending(s: *State) bool {
                return @cmpxchgWeak(
                    State,
                    s,
                    .{ .pending = true, .read_lock = false, .write_lock = false },
                    .{ .pending = true, .read_lock = true, .write_lock = false },
                    .acquire,
                    .monotonic,
                ) == null;
            }

            pub fn finishRead(s: *State) void {
                const prev = @atomicRmw(State, s, .And, .{
                    .pending = false,
                    .read_lock = false,
                    .write_lock = true,
                }, .release);
                assert(prev.read_lock);
                if (prev.write_lock) {
                    abi.runner_futex_wake(@ptrCast(s), 1);
                }
            }

            /// Returns if cancelation is requested.
            pub fn startWrite(s: *State) bool {
                var prev = @atomicRmw(State, s, .Or, .{
                    .pending = false,
                    .read_lock = false,
                    .write_lock = true,
                }, .acquire);
                assert(!prev.write_lock);
                while (prev.read_lock) {
                    if (abi.runner_futex_wait(@ptrCast(s), @bitCast(prev))) {
                        s.* = undefined; // fuzzer is exiting
                        return true;
                    }
                    // Still need `.acquire` ordering so @atomicRmw is necessary
                    prev = @atomicRmw(State, s, .Or, .{
                        .pending = false,
                        .read_lock = false,
                        .write_lock = false,
                    }, .acquire);
                    assert(prev.write_lock);
                }
                return false;
            }

            pub fn finishWrite(s: *State) void {
                @atomicStore(State, s, .{
                    .pending = true,
                    .read_lock = false,
                    .write_lock = false,
                }, .release);
            }
        };
    };

    const SeqCopy = union {
        order_i: u32,
        ints: []u64,
        bytes: Input.Data.Bytes,
    };

    const Input = struct {
        /// Untyped indexes into this are formed as follows: If the index is less than `ints.len`
        /// it indexes into `ints`, otherwise it indexes into `bytes` subtracted by `ints.len`.
        /// `math.maxInt(u32)` is reserved and impossible normally.
        data: Data,
        /// Corresponds with `data.uid_slices`.
        /// Values are the indexes of `seen_uids` with the same uid.
        seen_uid_i: []u32,
        /// Used to select a random uid to mutate from.
        ///
        /// The number of times a uid is present in this array is logarithmic
        /// to its data length in order to avoid long inputs from only being
        /// selected while still having some bias towards longer ones.
        weighted_uid_slice_i: []u32,

        ref: struct {
            /// Values are indexes of `Fuzzer.bests`.
            best_i_buf: []u32,
            best_i_len: u32,
        },

        pub const Data = struct {
            uid_slices: Data.UidSlices,
            ints: []u64,
            bytes: Bytes,
            /// Contains untyped indexes in the order they were requested.
            order: []u32,

            pub const Bytes = struct {
                entries: []Entry,
                table: []u8,

                pub const Entry = struct {
                    off: u32,
                    len: u32,
                };

                pub fn deinit(b: Bytes) void {
                    gpa.free(b.entries);
                    gpa.free(b.table);
                }
            };

            pub const UidSlices = std.ArrayHashMapUnmanaged(Uid, struct {
                base: u32,
                len: u32,
            }, Uid.hashmap_ctx, false);
        };

        pub fn deinit(i: *Input) void {
            i.data.uid_slices.deinit(gpa);
            gpa.free(i.data.ints);
            i.data.bytes.deinit();
            gpa.free(i.data.order);
            gpa.free(i.seen_uid_i);
            gpa.free(i.weighted_uid_slice_i);
            gpa.free(i.ref.best_i_buf);
            i.* = undefined;
        }

        pub const none: Input = .{
            .data = .{
                .uid_slices = .empty,
                .ints = &.{},
                .bytes = .{
                    .entries = &.{},
                    .table = undefined,
                },
                .order = &.{},
            },
            .seen_uid_i = &.{},
            .weighted_uid_slice_i = &.{},

            // Empty input is not referenced by `Fuzzer`
            .ref = undefined,
        };

        pub const Index = enum(u32) {
            pub const reserved_start: Index = .bytes_dry;
            /// Only touches `Fuzzer.smith`.
            bytes_dry = math.maxInt(u32) - 1,
            /// Only touches `Fuzzer.smith` and `Fuzzer.input_builder`.
            bytes_fresh = math.maxInt(u32),
            _,
        };

        pub const Best = struct {
            pc: u32,
            min: Quality,
            max: Quality,

            /// Order of significance:
            /// * n_pcs
            /// * req.values
            /// * req.bytes
            pub const Quality = struct {
                n_pcs: u32,
                req: packed struct(u64) {
                    bytes: u32,
                    values: u32,

                    pub fn int(r: @This()) u64 {
                        return @bitCast(r);
                    }
                },

                pub fn betterLess(a: Quality, b: Quality) bool {
                    return (a.n_pcs < b.n_pcs) | ((a.n_pcs == b.n_pcs) & (a.req.int() < b.req.int()));
                }

                pub fn betterMore(a: Quality, b: Quality) bool {
                    return (a.n_pcs > b.n_pcs) | ((a.n_pcs == b.n_pcs) & (a.req.int() < b.req.int()));
                }
            };

            pub const Map = struct {
                min: Input.Index,
                max: Input.Index,
            };
        };

        pub const Builder = struct {
            uid_slices: std.ArrayHashMapUnmanaged(Uid, union {
                ints: std.MultiArrayList(struct {
                    value: u64,
                    order_i: u32,
                }),
                bytes: std.MultiArrayList(struct {
                    value: Data.Bytes.Entry,
                    order_i: u32,
                }),
            }, Uid.hashmap_ctx, false),
            bytes_table: std.ArrayList(u8),
            // These will not overflow due to the 32-bit constraint on `MemoryMappedInput`
            total_ints: u32,
            total_bytes: u32,
            weighted_len: u32,
            /// Used to ensure that the 32-bit constraint in
            /// `MemoryMappedInput` applies to this run.
            smithed_len: u32,

            pub const init: Builder = .{
                .uid_slices = .empty,
                .bytes_table = .empty,
                .total_ints = 0,
                .total_bytes = 0,
                .weighted_len = 0,
                // The - 1 is because we check that `smithed_len` does not overflow a u32;
                // however, `MemoryMappedInput` allows up to `1 << 32`.
                .smithed_len = @sizeOf(abi.MmapInputHeader) - 1,
            };

            pub fn addInt(b: *Builder, uid: Uid, int: u64) void {
                const u = &b.uid_slices;
                const gop = u.getOrPutValue(gpa, uid, .{ .ints = .empty }) catch @panic("OOM");
                gop.value_ptr.ints.append(gpa, .{
                    .value = int,
                    .order_i = b.total_ints + b.total_bytes,
                }) catch @panic("OOM");
                b.total_ints += 1;
                b.weighted_len += @intFromBool(math.isPowerOfTwo(gop.value_ptr.ints.len));
            }

            pub fn addBytes(b: *Builder, uid: Uid, bytes: []const u8) void {
                const u = &b.uid_slices;
                const gop = u.getOrPutValue(gpa, uid, .{ .bytes = .empty }) catch @panic("OOM");
                gop.value_ptr.bytes.append(gpa, .{
                    .value = .{
                        .off = @intCast(b.bytes_table.items.len),
                        .len = @intCast(bytes.len),
                    },
                    .order_i = b.total_ints + b.total_bytes,
                }) catch @panic("OOM");
                b.bytes_table.appendSlice(gpa, bytes) catch @panic("OOM");
                b.total_bytes += 1;
                b.weighted_len += @intFromBool(math.isPowerOfTwo(gop.value_ptr.bytes.len));
            }

            pub fn checkSmithedLen(b: *Builder, n: usize) void {
                const n32 = @min(n, math.maxInt(u32)); // second will overflow
                b.smithed_len, const ov = @addWithOverflow(b.smithed_len, n32);
                if (ov == 1) @panic("too much smith data requested (non-deterministic)");
            }

            /// Additionally resets the state of this structure.
            ///
            /// The callee must populate
            /// * `.seen_uid_i`
            /// * `.ref`
            pub fn build(b: *Builder) Input {
                const uid_slices = b.uid_slices.entries.slice();
                var input: Input = .{
                    .data = .{
                        .uid_slices = Data.UidSlices.init(gpa, uid_slices.items(.key), &.{}) catch
                            @panic("OOM"),
                        .ints = gpa.alloc(u64, b.total_ints) catch @panic("OOM"),
                        .bytes = .{
                            .entries = gpa.alloc(Data.Bytes.Entry, b.total_bytes) catch @panic("OOM"),
                            .table = b.bytes_table.toOwnedSlice(gpa) catch @panic("OOM"),
                        },
                        .order = gpa.alloc(u32, b.total_ints + b.total_bytes) catch @panic("OOM"),
                    },
                    .seen_uid_i = gpa.alloc(u32, uid_slices.len) catch @panic("OOM"),
                    .weighted_uid_slice_i = gpa.alloc(u32, b.weighted_len) catch @panic("OOM"),
                    .ref = undefined,
                };
                var ints_pos: u32 = 0;
                var bytes_pos: u32 = 0;
                var weighted_pos: u32 = 0;

                assert(mem.eql(Uid, uid_slices.items(.key), input.data.uid_slices.keys()));
                for (
                    0..,
                    uid_slices.items(.key),
                    uid_slices.items(.value),
                    input.data.uid_slices.values(),
                ) |uid_i, uid, *uid_data, *slice| {
                    const weighted_len = 1 + math.log2_int(u32, len: switch (uid.kind) {
                        .int => {
                            const ints = uid_data.ints.slice();
                            @memcpy(input.data.ints[ints_pos..][0..ints.len], ints.items(.value));
                            for (ints.items(.order_i), ints_pos..) |order_i, data_i| {
                                input.data.order[order_i] = @intCast(data_i);
                            }
                            uid_data.ints.deinit(gpa);
                            slice.* = .{ .base = ints_pos, .len = @intCast(ints.len) };
                            ints_pos += @intCast(ints.len);
                            break :len @intCast(ints.len);
                        },
                        .bytes => {
                            const bytes = uid_data.bytes.slice();
                            @memcpy(
                                input.data.bytes.entries[bytes_pos..][0..bytes.len],
                                bytes.items(.value),
                            );
                            for (
                                bytes.items(.order_i),
                                b.total_ints + bytes_pos..,
                            ) |order_i, data_i| {
                                input.data.order[order_i] = @intCast(data_i);
                            }
                            uid_data.bytes.deinit(gpa);
                            slice.* = .{ .base = bytes_pos, .len = @intCast(bytes.len) };
                            bytes_pos += @intCast(bytes.len);
                            break :len @intCast(bytes.len);
                        },
                    });
                    const weighted = input.weighted_uid_slice_i[weighted_pos..][0..weighted_len];
                    @memset(weighted, @intCast(uid_i));
                    weighted_pos += weighted_len;
                }

                assert(ints_pos == b.total_ints);
                assert(bytes_pos == b.total_bytes);
                assert(weighted_pos == b.weighted_len);

                b.uid_slices.clearRetainingCapacity();
                b.total_ints = 0;
                b.total_bytes = 0;
                b.weighted_len = 0;
                b.smithed_len = Builder.init.smithed_len;
                return input;
            }

            pub fn reset(b: *Builder) void {
                const uid_slices = b.uid_slices.entries.slice();
                for (uid_slices.items(.key), uid_slices.items(.value)) |uid, *uid_data| {
                    switch (uid.kind) {
                        .int => uid_data.ints.deinit(gpa),
                        .bytes => uid_data.bytes.deinit(gpa),
                    }
                }
                b.uid_slices.clearRetainingCapacity();
                b.bytes_table.clearRetainingCapacity();
                b.total_ints = 0;
                b.total_bytes = 0;
                b.weighted_len = 0;
                b.smithed_len = Builder.init.smithed_len;
            }

            /// Asserts the structure is reset
            pub fn deinit(b: *Builder) void {
                assert(b.uid_slices.entries.len == 0);
                b.uid_slices.deinit(gpa);
                b.bytes_table.deinit(gpa);
                b.* = undefined;
            }
        };
    };

    pub fn init(n_tests: u32, seed: u64, instance_id: u32, limit: ?u64) Fuzzer {
        const pcs = exec.pc_counters.len;
        if (pcs > math.maxInt(u32)) @panic("too many pcs");

        const mmap_input = map: {
            // Find a free input file. `instance_id` should give one that is not in use;
            // however, this may not be the case if there are multiple libfuzzers running.
            var input_i = instance_id;
            const input_f = while (true) {
                var name_buf: [10]u8 = undefined;
                name_buf[0..2].* = "in".*;
                const hex = std.fmt.bufPrint(name_buf[2..], "{x}", .{input_i}) catch unreachable;
                const name = name_buf[0 .. 2 + hex.len];

                if (exec.cache_f.createFile(io, name, .{
                    .read = true,
                    .truncate = false,
                    .lock = .exclusive,
                    .lock_nonblocking = true,
                })) |f| {
                    break f;
                } else |e| switch (e) {
                    // To ensure no input file is unused to avoid the number of input files
                    // growing indefinitely across runs, they are linearly searched through.
                    //
                    // This could be avoided by creating a shared file holding the current number
                    // of input files in use; however, using multiple libfuzzers is uncommon and
                    // there should not be that many input files to search through anyways.
                    error.WouldBlock => input_i += 1,
                    else => panic("failed to create file '{s}': {t}", .{ name, e }),
                }
            };
            break :map MemoryMappedInput.init(input_f, instance_id, input_i);
        };

        const tests = gpa.alloc(Test, n_tests) catch @panic("OOM");
        const seen_pcs_len = bitsetUsizes(pcs);
        var seen_pcs_bufs = gpa.alloc(usize, seen_pcs_len * n_tests) catch @panic("OOM");
        var best_quality_bufs = gpa.alloc(Input.Best, pcs * n_tests) catch @panic("OOM");
        var best_input_bufs = gpa.alloc(Input.Best.Map, pcs * n_tests) catch @panic("OOM");
        @memset(seen_pcs_bufs, 0);
        for (0.., tests) |i, *t| {
            const name = abi.runner_test_name(@intCast(i)).toSlice();
            // A hash is used as the dirname instead of the actual test name since the test name
            // may be not allowed by the filesystem or have a special meaning (e.g. absolute /
            // relative paths).
            const dirname = std.fmt.hex(std.hash.Wyhash.hash(0, name));

            const lock_file = file: {
                if (instance_id != 0) break :file undefined;

                exec.cache_f.createDir(io, &dirname, .default_dir) catch |e| switch (e) {
                    error.PathAlreadyExists => {},
                    else => panic("failed to create directory '{s}': {t}", .{ &dirname, e }),
                };

                var cname: CorpusFileName = .fromTest(dirname);
                const lock_name = cname.syncLockName();
                break :file exec.cache_f.createFile(io, lock_name, .{
                    .truncate = false,
                    .lock = .exclusive,
                    .lock_nonblocking = true,
                }) catch |e| switch (e) {
                    error.WouldBlock => panic("corpus of '{s}' is in use by another fuzzer", .{name}),
                    else => panic("failed to create file '{s}': {t}", .{ lock_name, e }),
                };
            };

            t.* = .{
                .seen_pcs = seen_pcs_bufs[0..seen_pcs_len],
                .bests = .{
                    .len = 0,
                    .quality_buf = best_quality_bufs[0..pcs],
                    .input_buf = best_input_bufs[0..pcs],
                },
                .seen_uids = .empty,

                .corpus = .empty,
                .corpus_pos = @enumFromInt(0),
                .start_mut_corpus = math.maxInt(u32),
                .dirname = dirname,
                .lock_file = lock_file,
                .received = .empty,

                .limit = limit,
                .batch_cycles = 1,
                .batches = 0,
                .batches_since_find = 0,
                .seen_pc_count = 0,
            };
            t.corpus.append(gpa, .none) catch @panic("OOM"); // Also ensures the corpus is not empty
            seen_pcs_bufs = seen_pcs_bufs[seen_pcs_len..];
            best_quality_bufs = best_quality_bufs[pcs..];
            best_input_bufs = best_input_bufs[pcs..];
        }
        assert(seen_pcs_bufs.len == 0);
        assert(best_quality_bufs.len == 0);
        assert(best_input_bufs.len == 0);

        return .{
            .tests = tests,
            .test_i = undefined,
            .test_one = undefined,

            .xoshiro = .init(seed),
            .bytes_input = undefined,
            .input_builder = .init,
            .req_values = undefined,
            .req_bytes = undefined,
            .uid_data_i = .empty,
            .mut_data = undefined,

            .mmap_input = mmap_input,
            .main_instance = instance_id == 0,
        };
    }

    pub fn deinit(f: *Fuzzer) void {
        const pcs = exec.pc_counters.len;
        const n_tests = f.tests.len;
        gpa.free(f.tests[0].seen_pcs.ptr[0 .. bitsetUsizes(pcs) * n_tests]);
        gpa.free(f.tests[0].bests.quality_buf.ptr[0 .. pcs * n_tests]);
        gpa.free(f.tests[0].bests.input_buf.ptr[0 .. pcs * n_tests]);
        for (f.tests) |*t| {
            const seen_uids = t.seen_uids.entries.slice();
            for (seen_uids.items(.key), seen_uids.items(.value)) |uid, *data| {
                switch (uid.kind) {
                    .int => data.slices.ints.deinit(gpa),
                    .bytes => data.slices.bytes.deinit(gpa),
                }
            }
            t.seen_uids.deinit(gpa);
            const corpus = t.corpus.slice();
            // The first input is `Input.none` and so is skipped as `deinit` is illegal.
            for (1..corpus.len) |i| {
                var in = corpus.get(i);
                in.deinit();
            }
            if (f.main_instance) {
                t.lock_file.close(io);
            }
            t.received.inputs.deinit(gpa);
        }
        gpa.free(f.tests);
        f.input_builder.deinit();
        f.mmap_input.deinit();
        f.* = undefined;
    }

    pub fn ensureCorpusLoaded(f: *Fuzzer) void {
        const t = &f.tests[f.test_i];
        if (t.start_mut_corpus != math.maxInt(u32)) return;

        const start_mut: u32 = @intCast(t.corpus.len);
        if (!f.main_instance) {
            // Inputs can be culled as added since filesystem synchronacy is not required
            t.start_mut_corpus = start_mut;
        }

        read_corpus: {
            var cname: CorpusFileName = .fromTest(t.dirname);

            const readlock_name = cname.readLockName();
            const readlock_file = exec.cache_f.createFile(io, readlock_name, .{
                .truncate = false,
                .lock = .shared,
            }) catch |e| switch (e) {
                // FileNotFound means the corpus directory does not exist, which means it is empty
                error.FileNotFound => break :read_corpus,
                else => panic("failed to open '{s}': {t}", .{ readlock_name, e }),
            };
            defer readlock_file.close(io);

            var input_buf: std.ArrayList(u8) = .empty;
            defer input_buf.deinit(gpa);
            var i: u32 = 0;
            while (true) {
                const name = cname.inputName(i);
                const input_file = exec.cache_f.openFile(io, name, .{}) catch |e| switch (e) {
                    error.FileNotFound => break,
                    else => panic("failed to open input file '{s}': {t}", .{ name, e }),
                };

                const len = input_file.length(io) catch |e|
                    panic("failed to get length of '{s}': {t}", .{ name, e });
                const ulen = math.cast(usize, len) orelse @panic("OOM");
                input_buf.resize(gpa, ulen) catch @panic("OOM");

                var r = input_file.readerStreaming(io, &.{});
                r.interface.readSliceAll(input_buf.items) catch |e| switch (e) {
                    error.ReadFailed => panic(
                        "failed to read from input file '{s}': {t}",
                        .{ name, r.err.? },
                    ),
                    error.EndOfStream => panic(
                        "input file '{s}' ended before its reported length",
                        .{name},
                    ),
                };
                f.newInputExternal(input_buf.items);

                i += 1; // Cannot overflow due to corpus 32-bit size limit
            }
        }

        if (f.main_instance) {
            t.start_mut_corpus = start_mut;

            // Cull old inputs
            const ref = t.corpus.items(.ref);
            var i: usize = t.start_mut_corpus;
            while (i < t.corpus.len) {
                if (ref[i].best_i_len == 0) {
                    f.removeInput(@enumFromInt(i));
                } else {
                    i += 1;
                }
            }
        }

        t.corpus_pos = @enumFromInt(0);
    }

    const CorpusFileName = struct {
        buf: [Test.dirname_len + 9]u8,

        pub fn fromTest(dirname: [Test.dirname_len]u8) CorpusFileName {
            var n: CorpusFileName = undefined;
            n.buf[0..dirname.len].* = dirname;
            n.buf[dirname.len] = Io.Dir.path.sep;
            return n;
        }

        pub fn readLockName(n: *CorpusFileName) []u8 {
            const basename = "readlock";
            n.buf[Test.dirname_len + 1 ..][0..basename.len].* = basename.*;
            return n.buf[0 .. Test.dirname_len + 1 + basename.len];
        }

        pub fn syncLockName(n: *CorpusFileName) []u8 {
            const basename = "synclock";
            n.buf[Test.dirname_len + 1 ..][0..basename.len].* = basename.*;
            return n.buf[0 .. Test.dirname_len + 1 + basename.len];
        }

        pub fn inputName(n: *CorpusFileName, i: u32) []u8 {
            const hex = std.fmt.bufPrint(n.buf[Test.dirname_len + 1 ..][0..8], "{x}", .{i}) catch unreachable;
            return n.buf[0 .. Test.dirname_len + 1 + hex.len];
        }
    };

    fn rngInt(f: *Fuzzer, T: type) T {
        comptime assert(@bitSizeOf(T) <= 64);
        const Unsigned = @Int(.unsigned, @bitSizeOf(T));
        return @bitCast(@as(Unsigned, @truncate(f.xoshiro.next())));
    }

    fn rngLessThan(f: *Fuzzer, T: type, limit: T) T {
        return std.Random.limitRangeBiased(T, f.rngInt(T), limit);
    }

    /// Used for generating small values rather than making many calls into the prng.
    const SmallEntronopy = struct {
        bits: u64,

        pub fn take(e: *SmallEntronopy, T: type) T {
            defer e.bits >>= @bitSizeOf(T);
            return @truncate(e.bits);
        }
    };

    fn isFresh(f: *Fuzzer) bool {
        const t = &f.tests[f.test_i];
        // Store as a bool instead of returning immediately to aid optimizations
        // by reducing branching since a fresh input is the unlikely case.
        var fresh: bool = false;

        var n_pcs: u32 = 0;
        var hit_pcs = exec.pcBitsetIterator();
        for (t.seen_pcs) |seen| {
            const hits = hit_pcs.next();
            fresh |= hits & ~seen != 0;
            n_pcs += @popCount(hits);
        }

        const quality: Input.Best.Quality = .{
            .n_pcs = n_pcs,
            .req = .{
                .values = f.req_values,
                .bytes = f.req_bytes,
            },
        };
        for (t.bests.quality_buf[0..t.bests.len]) |best| {
            if (exec.pc_counters[best.pc] == 0) continue;
            fresh |= quality.betterLess(best.min) | quality.betterMore(best.max);
        }

        return fresh;
    }

    /// It is the callee's responsibility to reset the corpus pos
    ///
    /// Returns if `error.SkipZigTest` was indicated
    fn runBytes(f: *Fuzzer, bytes: []const u8, mode: Input.Index) bool {
        assert(mode == .bytes_dry or mode == .bytes_fresh);

        f.bytes_input = .{ .in = bytes };
        f.tests[f.test_i].corpus_pos = mode;
        defer f.tests[f.test_i].corpus_pos = undefined;
        return f.run(0); // 0 since `f.uid_data` is unused
    }

    fn updateSeenPcs(f: *Fuzzer) void {
        comptime assert(abi.SeenPcsHeader.trailing[0] == .pc_bits_usize);
        const shared_seen_pcs: [*]volatile usize = @ptrCast(
            exec.shared_seen_pcs[@sizeOf(abi.SeenPcsHeader)..].ptr,
        );

        const t = &f.tests[f.test_i];
        var hit_pcs = exec.pcBitsetIterator();
        for (t.seen_pcs, shared_seen_pcs) |*seen, *shared_seen| {
            const new = hit_pcs.next() & ~seen.*;
            if (new != 0) {
                seen.* |= new;
                _ = @atomicRmw(usize, shared_seen, .Or, new, .monotonic);
                t.seen_pc_count += @popCount(new);
            }
        }
    }

    fn removeBest(f: *Fuzzer, i: Input.Index, best_i: u32) void {
        const t = &f.tests[f.test_i];
        const ref = &t.corpus.items(.ref)[@intFromEnum(i)];
        const list_i = mem.indexOfScalar(u32, ref.best_i_buf[0..ref.best_i_len], best_i).?;
        ref.best_i_len -= 1;
        ref.best_i_buf[list_i] = ref.best_i_buf[ref.best_i_len];

        if (ref.best_i_len == 0 and @intFromEnum(i) >= t.start_mut_corpus) {
            // The input is no longer valuable, so remove it.
            f.removeInput(i);
        }
    }

    fn removeInput(f: *Fuzzer, i: Input.Index) void {
        const t = &f.tests[f.test_i];
        const ref = &t.corpus.items(.ref)[@intFromEnum(i)];
        assert(ref.best_i_len == 0 and @intFromEnum(i) >= t.start_mut_corpus);

        var removed_input = t.corpus.get(@intFromEnum(i));
        for (
            removed_input.data.uid_slices.keys(),
            removed_input.data.uid_slices.values(),
            removed_input.seen_uid_i,
        ) |uid, slice, seen_uid_i| {
            switch (uid.kind) {
                .int => {
                    const seen_ints = &t.seen_uids.values()[seen_uid_i].slices.ints;
                    const removed_ints = removed_input.data.ints[slice.base..][0..slice.len];
                    _ = seen_ints.swapRemove(for (0.., seen_ints.items) |idx, ints| {
                        if (removed_ints.ptr == ints.ptr) {
                            assert(removed_ints.len == ints.len);
                            break idx;
                        }
                    } else unreachable);
                },
                .bytes => {
                    const seen_bytes = &t.seen_uids.values()[seen_uid_i].slices.bytes;
                    const removed_bytes: Input.Data.Bytes = .{
                        .entries = removed_input.data.bytes.entries[slice.base..][0..slice.len],
                        .table = removed_input.data.bytes.table,
                    };
                    _ = seen_bytes.swapRemove(for (0.., seen_bytes.items) |idx, bytes| {
                        if (removed_bytes.entries.ptr == bytes.entries.ptr) {
                            assert(removed_bytes.entries.len == bytes.entries.len);
                            assert(removed_bytes.table.ptr == bytes.table.ptr);
                            assert(removed_bytes.table.len == bytes.table.len);
                            break idx;
                        }
                    } else unreachable);
                },
            }
        }
        removed_input.deinit();
        t.corpus.swapRemove(@intFromEnum(i));

        if (@intFromEnum(i) != t.corpus.len) {
            // The last item was moved so its refs need updated.
            // `ref` can be reused since it was a swap remove.
            for (ref.best_i_buf[0..ref.best_i_len]) |update_pc_i| {
                const best = &t.bests.input_buf[update_pc_i];
                assert(@intFromEnum(best.min) == t.corpus.len or
                    @intFromEnum(best.max) == t.corpus.len);

                if (@intFromEnum(best.min) == t.corpus.len) best.min = i;
                if (@intFromEnum(best.max) == t.corpus.len) best.max = i;
            }
        }

        if (!f.main_instance) return;

        var removed_cname: CorpusFileName = .fromTest(t.dirname);
        // Temporarily use removed_name to construct the path to the lock
        const readlock_name = removed_cname.readLockName();
        const readlock_file = exec.cache_f.createFile(io, readlock_name, .{
            .truncate = false,
            .lock = .exclusive,
        }) catch |e| panic("failed to open '{s}': {t}", .{ readlock_name, e });
        defer readlock_file.close(io);

        const removed_name = removed_cname.inputName(@intFromEnum(i) - t.start_mut_corpus);
        if (@intFromEnum(i) == t.corpus.len) {
            exec.cache_f.deleteFile(io, removed_name) catch |e| panic(
                "failed to remove corpus file '{s}': {t}",
                .{ removed_name, e },
            );
        } else {
            var swapped_cname: CorpusFileName = .fromTest(t.dirname);
            const swapped_i: u32 = @intCast(t.corpus.len);
            const swapped_name = swapped_cname.inputName(swapped_i - t.start_mut_corpus);

            exec.cache_f.rename(swapped_name, exec.cache_f, removed_name, io) catch |e| panic(
                "failed to rename corpus file '{s}' to '{s}': {t}",
                .{ swapped_name, removed_name, e },
            );
        }
    }

    pub fn newInputExternal(f: *Fuzzer, bytes: []const u8) void {
        // All inputs including the corpus are required to go through the memory
        // mapped input in case they cause a crash so they can be identified.
        f.mmap_input.appendSlice(bytes);
        f.newInput();
        f.mmap_input.clearRetainingCapacity();
    }

    fn newInput(f: *Fuzzer) void {
        const t = &f.tests[f.test_i];
        const new_is_mut = t.start_mut_corpus != math.maxInt(u32);
        assert(new_is_mut == (t.corpus.len >= t.start_mut_corpus));
        const bytes = f.mmap_input.inputSlice();
        // `error.SkipZigTest` here can be from one of these causes:
        // * A previous corpus input after the test has changed
        // * An input provided by the test
        // * The test is non-deterministic
        if (f.runBytes(bytes, .bytes_fresh) and
            new_is_mut // The corpus must be mutable at this point for the input to be
            // omitted (i.e. test corpus inputs and filesystem inputs cannot be dropped)
        ) {
            f.input_builder.reset();
            t.corpus_pos = @enumFromInt(0);
            return;
        }

        f.req_values = f.input_builder.total_ints + f.input_builder.total_bytes;
        f.req_bytes = @intCast(f.input_builder.bytes_table.items.len);
        const quality: Input.Best.Quality = .{
            .n_pcs = n_pcs: {
                @setRuntimeSafety(builtin.mode == .Debug); // Necessary for vectorization
                var n: u32 = 0;
                for (exec.pc_counters) |c| {
                    n += @intFromBool(c != 0);
                }
                break :n_pcs n;
            },
            .req = .{
                .values = f.req_values,
                .bytes = f.req_bytes,
            },
        };

        var best_i_list: std.ArrayList(u32) = .empty;
        for (0.., t.bests.quality_buf[0..t.bests.len]) |best_i, best| {
            if (exec.pc_counters[best.pc] == 0) continue;

            const better_min = quality.betterLess(best.min);
            const better_max = quality.betterMore(best.max);
            if (!better_min and !better_max) {
                @branchHint(.likely);
                continue;
            }
            best_i_list.append(gpa, @intCast(best_i)) catch @panic("OOM");

            const map = &t.bests.input_buf[best_i];
            if (map.min != map.max) {
                if (better_min) {
                    f.removeBest(map.min, @intCast(best_i));
                }
                if (better_max) {
                    f.removeBest(map.max, @intCast(best_i));
                }
            } else {
                if (better_min and better_max) {
                    f.removeBest(map.min, @intCast(best_i));
                }
            }
        }

        // Must come after the above since some inputs may be removed
        const input_i: Input.Index = @enumFromInt(t.corpus.len);
        if (input_i == Input.Index.reserved_start) {
            @panic("corpus size limit exceeded");
        }

        for (best_i_list.items) |i| {
            const best_qual = &t.bests.quality_buf[i];
            const best_map = &t.bests.input_buf[i];

            if (quality.betterLess(best_qual.min)) {
                best_qual.min = quality;
                best_map.min = input_i;
            }
            if (quality.betterMore(best_qual.max)) {
                best_qual.max = quality;
                best_map.max = input_i;
            }
        }

        for (0.., exec.pc_counters) |i, hits| {
            if (hits == 0) {
                @branchHint(.likely);
                continue;
            }

            if ((t.seen_pcs[i / @bitSizeOf(usize)] >> @intCast(i % @bitSizeOf(usize))) & 1 == 0) {
                @branchHint(.unlikely);
                best_i_list.append(gpa, t.bests.len) catch @panic("OOM");
                t.bests.quality_buf[t.bests.len] = .{
                    .pc = @intCast(i),
                    .min = quality,
                    .max = quality,
                };
                t.bests.input_buf[t.bests.len] = .{ .min = input_i, .max = input_i };
                t.bests.len += 1;
            }
        }

        // Having no best qualities could be from one of these causes:
        // * A previous corpus input after the test has changed
        // * An input provided by the test
        // * The test is non-deterministic
        if (best_i_list.items.len == 0 and new_is_mut) {
            assert(best_i_list.capacity == 0);
            f.input_builder.reset();
            t.corpus_pos = @enumFromInt(0);
            return;
        }

        var input = f.input_builder.build();
        f.uid_data_i.ensureTotalCapacity(gpa, input.data.uid_slices.entries.len) catch @panic("OOM");
        for (
            input.seen_uid_i,
            input.data.uid_slices.keys(),
            input.data.uid_slices.values(),
        ) |*i, uid, slice| {
            const gop = t.seen_uids.getOrPutValue(gpa, uid, switch (uid.kind) {
                .int => .{ .slices = .{ .ints = .empty } },
                .bytes => .{ .slices = .{ .bytes = .empty } },
            }) catch @panic("OOM");
            switch (uid.kind) {
                .int => t.seen_uids.values()[gop.index].slices.ints.append(
                    gpa,
                    input.data.ints[slice.base..][0..slice.len],
                ) catch @panic("OOM"),
                .bytes => t.seen_uids.values()[gop.index].slices.bytes.append(gpa, .{
                    .entries = input.data.bytes.entries[slice.base..][0..slice.len],
                    .table = input.data.bytes.table,
                }) catch @panic("OOM"),
            }
            i.* = @intCast(gop.index);
        }

        input.ref.best_i_buf = best_i_list.toOwnedSlice(gpa) catch @panic("OOM");
        input.ref.best_i_len = @intCast(input.ref.best_i_buf.len);
        t.corpus.append(gpa, input) catch @panic("OOM");
        t.corpus_pos = input_i;

        // Must come after the above since `seen_pcs` is used
        f.updateSeenPcs();

        t.batches_since_find = 0;
        if (f.main_instance and new_is_mut) {
            // Only the main instance increments the number of unique runs since it is likely
            // multiple instances find the same new input at the same time.
            _ = @atomicRmw(usize, &exec.seenPcsHeader().unique_runs, .Add, 1, .monotonic);
            // Write new input to the cache
            var cname: CorpusFileName = .fromTest(t.dirname);
            const name = cname.inputName(@intFromEnum(input_i) - t.start_mut_corpus);
            exec.cache_f.writeFile(io, .{ .sub_path = name, .data = bytes, .flags = .{
                .exclusive = true,
            } }) catch |e| panic("failed to write corpus file '{s}': {t}", .{ name, e });
        }
    }

    /// Returns if `error.SkipZigTest` was indicated
    fn run(f: *Fuzzer, input_uids: usize) bool {
        @memset(exec.pc_counters, 0);
        f.uid_data_i.items.len = input_uids;
        @memset(f.uid_data_i.items, 0);
        f.req_values = 0;
        f.req_bytes = 0;

        const skip = f.test_one();
        _ = @atomicRmw(usize, &exec.seenPcsHeader().n_runs, .Add, 1, .monotonic);
        return skip;
    }

    /// Returns a number of mutations to perform from 1-4
    /// with smaller values exponentially more likely.
    pub fn mutCount(rng: u16) u8 {
        // The below provides the following distribution
        // @clz(@clz(    range       mapped   percentage         ratio
        //          0 ->     0         -> 4  1 = 93.750%  (15 / 16   )
        //          1 ->     1 - 255   -> 3  2 =  5.859%  (15 / 256  )
        //          2 ->   256 - 4095  -> 2  3 =   .391%  (<1 / 256  )
        //          3 ->  4096 - 16383 -> 1  4 =   .002%  ( 1 / 65536)
        //          4 -> 16384 - 32767 -> 1
        //          5 -> 32768 - 65535 -> 1
        return @as(u8, 4) - @min(@clz(@clz(rng)), 3);
    }

    pub fn cycle(f: *Fuzzer) void {
        assert(f.mmap_input.len == 0);

        const t = &f.tests[f.test_i];
        const corpus = t.corpus.slice();
        const corpus_i = @intFromEnum(t.corpus_pos);

        var small_entronopy: SmallEntronopy = .{ .bits = f.rngInt(u64) };
        var n_mutate = mutCount(small_entronopy.take(u16));
        const data = &corpus.items(.data)[corpus_i];
        const weighted_uid_slice_i = corpus.items(.weighted_uid_slice_i)[corpus_i];
        n_mutate *= @intFromBool(weighted_uid_slice_i.len != 0); // No static mutations on empty

        f.mut_data = .{
            .i = @splat(math.maxInt(u32)),
            .seq = @splat(.{
                .kind = .{
                    .class = undefined,
                    .copy = undefined,
                    .ordered_mutate = undefined,
                    .none = true,
                },
                .len = undefined,
                .copy = undefined,
            }),
        };

        const uid_slices = data.uid_slices.entries.slice();
        for (
            f.mut_data.i[0..n_mutate],
            f.mut_data.seq[0..n_mutate],
        ) |*i, *s| if ((data.order.len < 2) | (small_entronopy.take(u3) != 0)) {
            // Mutation on uid
            const uid_slice_wi = f.rngLessThan(u32, @intCast(weighted_uid_slice_i.len));
            const uid_slice_i = weighted_uid_slice_i[uid_slice_wi];

            const is_bytes = uid_slices.items(.key)[uid_slice_i].kind == .bytes;
            const data_slice = uid_slices.items(.value)[uid_slice_i];
            i.* = @as(u32, @intCast(data.ints.len)) * @intFromBool(is_bytes) +
                data_slice.base + f.rngLessThan(u32, data_slice.len);
        } else {
            // Sequence mutation on order
            const order_len: u32 = @intCast(data.order.len);
            const order_i = f.rngLessThan(u32, order_len - 1);
            s.* = .{
                .kind = .{
                    .class = .replace,
                    .copy = true,
                    .ordered_mutate = true,
                    .none = false,
                },
                .len = @min(@clz(f.rngInt(u16)) + 1, order_len - order_i),
                .copy = .{ .order_i = order_i },
            };
            i.* = data.order[order_i];
        };

        const skip = f.run(data.uid_slices.entries.len);
        if (!skip and f.isFresh()) {
            @branchHint(.unlikely);

            abi.runner_broadcast_input(f.test_i, .fromSlice(f.mmap_input.inputSlice()));
            f.newInput();
        } else {
            assert(@intFromEnum(t.corpus_pos) < t.corpus.len);
            t.corpus_pos = @enumFromInt((@intFromEnum(t.corpus_pos) + 1) % t.corpus.len);
        }
        f.mmap_input.clearRetainingCapacity();
    }

    fn takeReceived(f: *Fuzzer) void {
        const t = &f.tests[f.test_i];
        if (t.received.state.startReadIfPending()) {
            defer t.received.state.finishRead();
            const inputs = &t.received.inputs;
            var rem = inputs.items;

            while (true) {
                const len: u32 = @bitCast(rem[0..4].*);
                rem = rem[4..];
                const bytes = rem[0..len];
                rem = rem[len..];

                f.mmap_input.appendSlice(bytes);
                f.newInput();
                f.mmap_input.clearRetainingCapacity();

                if (rem.len == 0) break;
            }

            inputs.clearRetainingCapacity();
        }
    }

    pub fn batch(f: *Fuzzer) void {
        const t = &f.tests[f.test_i];
        assert(t.limit != 0);
        t.batches += 1;
        t.batches_since_find += 1;
        if (f.tests.len != 1) {
            // Use cpu_process since some fuzz tests may spawn
            // other threads and give all the work to them.
            const start: Io.Timestamp = .now(io, .cpu_process);
            var completed_cycles: u32 = 0;
            var total_cycles: u32 = t.batch_cycles;

            while (true) {
                assert(completed_cycles != total_cycles);
                while (completed_cycles < total_cycles) {
                    f.takeReceived();
                    f.cycle();
                    completed_cycles += 1;
                }

                const duration = start.untilNow(io, .cpu_process);
                const ns = @min(@max(1, duration.nanoseconds), math.maxInt(u64));
                const speed = @as(u64, t.batch_cycles) * std.time.ns_per_s / ns;
                // @min avoids large increases in batch_cycles due to just a few cycles running
                // fast. For example, if batch_cycles is only 2, and both run very fast due to
                // unlucky rng, this avoids a large runtime on the next batch. This also avoids
                // timer inprecision giving large values.
                t.batch_cycles = @max(1, @min(speed, t.batch_cycles *| 2));

                if (ns < std.time.ns_per_s * 7 / 8) {
                    // Keep running the test to get closer to a second. This will almost always
                    // be the case for the first batch as the default batch_cycles is 1.
                    if (t.limit == total_cycles) break;

                    const rem_ns: u64 = @as(u32, std.time.ns_per_s) - ns;
                    const extra: u32 = @intCast(rem_ns * t.batch_cycles / std.time.ns_per_s);
                    if (extra == 0) break; // No better approximation of a second possible
                    total_cycles += extra;
                    if (t.limit) |limit| total_cycles = @min(total_cycles, limit);
                    continue;
                }

                break;
            }

            assert(completed_cycles == total_cycles);
            if (t.limit) |prev| {
                t.limit = prev - total_cycles;
                t.batch_cycles = @min(t.batch_cycles, t.limit.?);
            }
        } else {
            while (true) {
                if (t.limit) |limit| {
                    if (limit == 0) break;
                    t.limit = limit - 1;
                }
                f.takeReceived();
                f.cycle();
            }
        }
    }

    pub fn select(f: *Fuzzer) ?u32 {
        assert(f.tests.len > 1); // More efficiently handled by the callee

        // The algorithm for selecting tests is such that:
        // - 1/4 are from the number of pcs as they give an indication of test complexity.
        // - 3/4 are from the recency of the last find as it gives an indication of the
        //   effectiveness of fuzzing for the test.
        // - Tests finding fresh inputs are run 8x other tests.
        //   - Since new tests are considered to have just found a fresh input, this means they
        //     are also prioritized which allows their characteristics to be learnt.
        // When a test has a new input pending, it is treated as if it had just found a fresh
        // input instead of immediately being run. This avoids a test which is finding many new
        // inputs from being exclusively run.
        const new_batches = 16;

        var n_with_new: u32 = 0;
        var n_seen_pcs: u64 = 0;
        var n_latest_find: u64 = 0;

        for (f.tests) |*t| {
            const has_pending = t.received.state.hasPending();
            if (has_pending) {
                assert(t.limit == null); // If multiprocess limited fuzzing was to be added, then
                // `t.received.inputs.clearRetainingCapacity()` would need to be added after
                // `t.received.state.startReadIfPending()` when the limit has been reached.
            }
            if (t.limit == 0) continue;

            const latest_find = t.batches - t.batches_since_find;
            n_with_new += @intFromBool(t.batches_since_find < new_batches or has_pending);
            n_seen_pcs += @max(t.seen_pc_count, 1);
            n_latest_find += @max(latest_find, 1);
        }

        if (n_seen_pcs == 0) {
            assert(n_with_new == 0);
            assert(n_latest_find == 0);
            return null; // All fuzz tests have used up their limit
        }

        const rng: packed struct(u64) {
            idx_rng: u32,
            from_new: u3,
            from_latest_find: u2,
            _: u27,
        } = @bitCast(f.rngInt(u64));

        if (n_with_new != 0 and rng.from_new != 0) {
            var n = std.Random.limitRangeBiased(u32, rng.idx_rng, n_with_new);
            for (0.., f.tests) |i, *t| {
                if (t.limit == 0) continue;
                if (t.batches_since_find < new_batches or t.received.state.hasPending()) {
                    if (n == 0) return @intCast(i);
                    n -= 1;
                }
            }
            unreachable;
        }

        if (rng.from_latest_find != 0) {
            const total_weight = n_latest_find;
            var n = f.rngLessThan(u64, total_weight);
            for (0.., f.tests) |i, *t| {
                if (t.limit == 0) continue;
                const latest_find = @max(t.batches - t.batches_since_find, 1);
                if (n < latest_find) return @intCast(i);
                n -= latest_find;
            }
            unreachable;
        } else {
            const total_weight = n_seen_pcs;
            var n = f.rngLessThan(u64, total_weight);
            for (0.., f.tests) |i, *t| {
                if (t.limit == 0) continue;
                const seen_pc_count = @max(t.seen_pc_count, 1);
                if (n < seen_pc_count) return @intCast(i);
                n -= seen_pc_count;
            }
            unreachable;
        }
    }

    fn weightsContain(int: u64, weights: []const abi.Weight) bool {
        var contains: bool = false;
        for (weights) |w| {
            contains |= w.min <= int and int <= w.max;
        }
        return contains;
    }

    fn weightsContainBytes(bytes: []const u8, weights: []const abi.Weight) bool {
        if (weights[0].min == 0 and weights[0].max == 0xff) {
            // Fast path: all bytes are valid
            return true;
        }

        var contains: bool = true;
        for (bytes) |b| {
            contains &= weightsContain(b, weights);
        }
        return contains;
    }

    fn sumWeightsInclusive(weights: []const abi.Weight) u64 {
        var sum: u64 = math.maxInt(u64);
        for (weights) |w| {
            sum +%= (w.max - w.min +% 1) *% w.weight;
        }
        return sum;
    }

    fn weightedValue(f: *Fuzzer, weights: []const abi.Weight, incl_sum: u64) u64 {
        var incl_n: u64 = f.rngInt(u64);
        const limit = incl_sum +% 1;
        if (limit != 0) incl_n = std.Random.limitRangeBiased(u64, incl_n, limit);

        for (weights) |w| {
            // (w.max - w.min + 1) * w.weight - 1
            const incl_vals = (w.max - w.min) * w.weight + (w.weight - 1);
            if (incl_n > incl_vals) {
                incl_n -= incl_vals + 1;
            } else {
                const val = w.min + incl_n / w.weight;
                assert(val <= w.max);
                return val;
            }
        } else unreachable;
    }

    const Untyped = union {
        int: u64,
        bytes: []u8,
    };

    fn nextUntyped(f: *Fuzzer, uid: Uid, weights: []const abi.Weight) union(enum) {
        copy: Untyped,
        mutate: Untyped,
        fresh: void,
    } {
        const t = &f.tests[f.test_i];
        const corpus = t.corpus.slice();
        const corpus_i = @intFromEnum(t.corpus_pos);
        const data = &corpus.items(.data)[corpus_i];
        var small_entronopy: SmallEntronopy = .{ .bits = f.rngInt(u64) };

        const uid_i = data.uid_slices.getIndex(uid) orelse {
            @branchHint(.unlikely);
            return .fresh;
        };
        const data_slice = data.uid_slices.values()[uid_i];
        var slice_i = f.uid_data_i.items[uid_i];
        var data_i = data_slice.base + slice_i;

        new_data: while (true) {
            assert(slice_i == f.uid_data_i.items[uid_i] and data_i == data_slice.base + slice_i);
            if (slice_i == data_slice.len) break :new_data;
            assert(slice_i < data_slice.len);

            f.uid_data_i.items[uid_i] += 1;
            const mut_i = std.simd.firstIndexOfValue(
                @as(@Vector(4, u32), f.mut_data.i),
                data_i + @as(u32, @intCast(data.ints.len)) * @intFromEnum(uid.kind),
            ) orelse {
                @branchHint(.likely);
                switch (uid.kind) {
                    .int => {
                        const int = data.ints[data_i];
                        if (weightsContain(int, weights)) {
                            @branchHint(.likely);
                            return .{ .copy = .{ .int = int } };
                        }
                    },
                    .bytes => {
                        const entry = data.bytes.entries[data_i];
                        const bytes = data.bytes.table[entry.off..][0..entry.len];
                        if (weightsContainBytes(bytes, weights)) {
                            @branchHint(.likely);
                            return .{ .copy = .{ .bytes = bytes } };
                        }
                    },
                }
                break :new_data;
            };

            const seq = &f.mut_data.seq[mut_i];
            new_seq: {
                if (!seq.kind.none) break :new_seq;

                var opts: packed struct(u6) {
                    // Matches layout as `mut_data.seq.kind`
                    insert: bool,
                    copy: bool,

                    seq: u2,
                    delete: bool,
                    splice: bool,
                } = @bitCast(small_entronopy.take(u6));
                if (opts.seq != 0) break :new_data;

                const max_consume = data_slice.len - slice_i; // inclusive
                if (opts.delete) {
                    f.uid_data_i.items[uid_i] += f.rngLessThan(u32, max_consume);
                    slice_i = f.uid_data_i.items[uid_i];
                    data_i = data_slice.base + slice_i;
                    continue;
                }
                opts.insert |= max_consume == 0;
                seq.kind = .{
                    .class = if (opts.insert) .replace else .insert,
                    .copy = opts.copy,
                    .ordered_mutate = false,
                    .none = false,
                };

                if (!seq.kind.copy) {
                    seq.len = switch (seq.kind.class) {
                        .replace => f.rngLessThan(u32, max_consume) + 1,
                        .insert => @clz(f.rngInt(u16)) + 1,
                    };
                    seq.copy = undefined;
                } else {
                    const src: SeqCopy, const src_len: u32 = if (!opts.splice) .{
                        switch (uid.kind) {
                            .int => .{ .ints = data.ints[data_slice.base..][0..data_slice.len] },
                            .bytes => .{ .bytes = .{
                                .entries = data.bytes.entries[data_slice.base..][0..data_slice.len],
                                .table = data.bytes.table,
                            } },
                        },
                        data_slice.len,
                    } else src: {
                        const seen_uid_i = corpus.items(.seen_uid_i)[corpus_i][uid_i];
                        const untyped_slices = t.seen_uids.values()[seen_uid_i].slices;
                        switch (uid.kind) {
                            .int => {
                                const slices = untyped_slices.ints.items;
                                const i = f.rngLessThan(u32, @intCast(slices.len));
                                break :src .{
                                    .{ .ints = slices[i] },
                                    @intCast(slices[i].len),
                                };
                            },
                            .bytes => {
                                const slices = untyped_slices.bytes.items;
                                const i = f.rngLessThan(u32, @intCast(slices.len));
                                break :src .{
                                    .{ .bytes = slices[i] },
                                    @intCast(slices[i].entries.len),
                                };
                            },
                        }
                    };

                    const off = f.rngLessThan(u32, src_len);
                    seq.len = f.rngLessThan(u32, src_len - off) + 1;
                    if (seq.kind.class == .replace) seq.len = @min(seq.len, max_consume);
                    seq.copy = switch (uid.kind) {
                        .int => .{ .ints = src.ints[off..][0..seq.len] },
                        .bytes => .{ .bytes = .{
                            .entries = src.bytes.entries[off..][0..seq.len],
                            .table = src.bytes.table,
                        } },
                    };
                }
            }

            assert(!seq.kind.none);
            f.uid_data_i.items[uid_i] -= @intFromBool(seq.kind.class == .insert);
            seq.len -= 1;
            seq.kind.none |= seq.len == 0;
            f.mut_data.i[mut_i] += @intFromBool(seq.kind.class == .replace and seq.len != 0);

            if (!seq.kind.copy) {
                assert(!seq.kind.ordered_mutate);
                break :new_data;
            }
            if (seq.kind.ordered_mutate) {
                assert(seq.kind.class == .replace);
                seq.copy.order_i += @intFromBool(seq.len != 0);
                f.mut_data.i[mut_i] = data.order[seq.copy.order_i];
                break :new_data;
            }
            switch (uid.kind) {
                .int => {
                    const int = seq.copy.ints[0];
                    seq.copy.ints = seq.copy.ints[1..];
                    if (weightsContain(int, weights)) {
                        @branchHint(.likely);
                        return .{ .copy = .{ .int = int } };
                    }
                },
                .bytes => {
                    const entry = seq.copy.bytes.entries[0];
                    const bytes = seq.copy.bytes.table[entry.off..][0..entry.len];
                    seq.copy.bytes.entries = seq.copy.bytes.entries[1..];
                    if (weightsContainBytes(bytes, weights)) {
                        @branchHint(.likely);
                        return .{ .copy = .{ .bytes = bytes } };
                    }
                },
            }
            break;
        }

        const opts: packed struct(u10) {
            copy: u2,
            fresh: u2,
            splice: bool,
            local_far: bool,
            local_off: i4,
        } = @bitCast(small_entronopy.take(u10));

        if (opts.copy != 0) {
            if (opts.fresh == 0 or slice_i == data_slice.len) return .fresh;
            switch (uid.kind) {
                .int => {
                    const int = data.ints[data_i];
                    if (weightsContain(int, weights)) {
                        @branchHint(.likely);
                        return .{ .mutate = .{ .int = int } };
                    }
                },
                .bytes => {
                    const entry = data.bytes.entries[data_i];
                    const bytes = data.bytes.table[entry.off..][0..entry.len];
                    if (weightsContainBytes(bytes, weights)) {
                        @branchHint(.likely);
                        return .{ .mutate = .{ .bytes = bytes } };
                    }
                },
            }
        }

        if (!opts.splice) {
            const src_data_i = data_slice.base + if (!opts.local_far) i: {
                const off = opts.local_off;
                break :i if (off >= 0) @min(
                    f.uid_data_i.items[uid_i] +| @as(u4, @intCast(off)),
                    data_slice.len - 1,
                ) else f.uid_data_i.items[uid_i] -| @abs(off);
            } else f.rngLessThan(u32, data_slice.len);
            switch (uid.kind) {
                .int => {
                    const int = data.ints[src_data_i];
                    if (weightsContain(int, weights)) {
                        @branchHint(.likely);
                        return .{ .copy = .{ .int = int } };
                    }
                },
                .bytes => {
                    const entry = data.bytes.entries[src_data_i];
                    const bytes = data.bytes.table[entry.off..][0..entry.len];
                    if (weightsContainBytes(bytes, weights)) {
                        @branchHint(.likely);
                        return .{ .copy = .{ .bytes = bytes } };
                    }
                },
            }
        } else {
            const seen_uid_i = corpus.items(.seen_uid_i)[corpus_i][uid_i];
            const untyped_slices = t.seen_uids.values()[seen_uid_i].slices;
            switch (uid.kind) {
                .int => {
                    const slices = untyped_slices.ints.items;
                    const from = slices[f.rngLessThan(u32, @intCast(slices.len))];
                    const int = from[f.rngLessThan(u32, @intCast(from.len))];
                    if (weightsContain(int, weights)) {
                        @branchHint(.likely);
                        return .{ .copy = .{ .int = int } };
                    }
                },
                .bytes => {
                    const slices = untyped_slices.bytes.items;
                    const from = slices[f.rngLessThan(u32, @intCast(slices.len))];
                    const entry_i = f.rngLessThan(u32, @intCast(from.entries.len));
                    const entry = from.entries[entry_i];
                    const bytes = from.table[entry.off..][0..entry.len];
                    if (weightsContainBytes(bytes, weights)) {
                        @branchHint(.likely);
                        return .{ .copy = .{ .bytes = bytes } };
                    }
                },
            }
        }
        return .fresh;
    }

    pub fn nextInt(f: *Fuzzer, uid: Uid, weights: []const abi.Weight) u64 {
        const t = &f.tests[f.test_i];
        f.req_values += 1;
        if (@intFromEnum(t.corpus_pos) >= @intFromEnum(Input.Index.reserved_start)) {
            @branchHint(.unlikely);
            const int = f.bytes_input.valueWeightedWithHash(u64, weights, undefined);
            if (t.corpus_pos == .bytes_fresh) {
                f.input_builder.checkSmithedLen(8);
                f.input_builder.addInt(uid, int);
            }
            return int;
        }
        const int = f.nextIntInner(uid, weights);
        f.mmap_input.appendLittleInt(u64, int);
        return int;
    }

    fn nextIntInner(f: *Fuzzer, uid: Uid, weights: []const abi.Weight) u64 {
        return switch (f.nextUntyped(uid, weights)) {
            .copy => |u| u.int,
            .mutate, .fresh => f.weightedValue(weights, sumWeightsInclusive(weights)),
        };
    }

    pub fn nextEos(f: *Fuzzer, uid: Uid, weights: []const abi.Weight) bool {
        const t = &f.tests[f.test_i];
        f.req_values += 1;
        if (@intFromEnum(t.corpus_pos) >= @intFromEnum(Input.Index.reserved_start)) {
            @branchHint(.unlikely);
            const eos = f.bytes_input.eosWeightedWithHash(weights, undefined);
            if (t.corpus_pos == .bytes_fresh) {
                f.input_builder.checkSmithedLen(1);
                f.input_builder.addInt(uid, @intFromBool(eos));
            }
            return eos;
        }
        // `nextIntInner` is already gauraunteed to eventually return `1`
        const eos = @as(u1, @intCast(f.nextIntInner(uid, weights))) != 0;
        f.mmap_input.appendLittleInt(u8, @intFromBool(eos));
        return eos;
    }

    fn mutateBytes(f: *Fuzzer, in: []u8, out: []u8, weights: []const abi.Weight) void {
        assert(in.len != 0);
        const weights_incl_sum = sumWeightsInclusive(weights);

        var small_entronopy: SmallEntronopy = .{ .bits = f.rngInt(u64) };
        var muts = mutCount(small_entronopy.take(u16));
        var rem_out = out;
        var rem_copy = in;
        while (rem_out.len != 0 and muts != 0) {
            muts -= 1;
            const opts: packed struct(u4) {
                kind: enum(u2) {
                    random,
                    stream_copy,
                    stream_discard,
                    absolute_copy,
                },
                small: u2,

                pub fn limitSmall(o: @This(), n: usize) u32 {
                    return @min(
                        @as(u32, @intCast(n)),
                        @as(u32, if (o.small != 0) 8 else math.maxInt(u32)),
                    );
                }
            } = @bitCast(small_entronopy.take(u4));
            s: switch (opts.kind) {
                .random => {
                    const n = f.rngLessThan(u32, opts.limitSmall(rem_out.len)) + 1;
                    for (rem_out[0..n]) |*o| {
                        o.* = @intCast(f.weightedValue(weights, weights_incl_sum));
                    }
                    rem_out = rem_out[n..];
                },
                .stream_copy => {
                    if (rem_copy.len == 0) continue :s .random;
                    const n = @min(
                        f.rngLessThan(u32, opts.limitSmall(rem_copy.len)) + 1,
                        rem_out.len,
                    );
                    @memcpy(rem_out[0..n], rem_copy[0..n]);
                    rem_out = rem_out[n..];
                    rem_copy = rem_copy[n..];
                },
                .stream_discard => {
                    if (rem_copy.len == 0) continue :s .random;
                    const n = f.rngLessThan(u32, opts.limitSmall(rem_copy.len)) + 1;
                    rem_copy = rem_copy[n..];
                },
                .absolute_copy => {
                    const in_len: u32 = @intCast(in.len);
                    const off = f.rngLessThan(u32, in_len);
                    const len = @min(
                        f.rngLessThan(u32, in_len - off) + 1,
                        opts.limitSmall(rem_out.len),
                    );
                    @memcpy(rem_out[0..len], in[off..][0..len]);
                    rem_out = rem_out[len..];
                },
            }
        }

        const copy = @min(rem_out.len, rem_copy.len);
        @memcpy(rem_out[0..copy], rem_copy[0..copy]);
        for (rem_out[copy..]) |*o| {
            o.* = @intCast(f.weightedValue(weights, weights_incl_sum));
        }
    }

    fn nextBytesInner(f: *Fuzzer, uid: Uid, out: []u8, weights: []const abi.Weight) void {
        so: switch (f.nextUntyped(uid, weights)) {
            .copy => |u| {
                if (u.bytes.len >= out.len) {
                    @branchHint(.likely);
                    @memcpy(out, u.bytes[0..out.len]);
                    return;
                }

                @memcpy(out[0..u.bytes.len], u.bytes);
                const weights_incl_sum = sumWeightsInclusive(weights);
                for (out[u.bytes.len..]) |*o| {
                    o.* = @intCast(f.weightedValue(weights, weights_incl_sum));
                }
            },
            .mutate => |u| {
                if (u.bytes.len == 0) continue :so .fresh;
                f.mutateBytes(u.bytes, out, weights);
            },
            .fresh => {
                const weights_incl_sum = sumWeightsInclusive(weights);
                for (out) |*o| {
                    o.* = @intCast(f.weightedValue(weights, weights_incl_sum));
                }
            },
        }
    }

    pub fn nextBytes(f: *Fuzzer, uid: Uid, out: []u8, weights: []const abi.Weight) void {
        const t = &f.tests[f.test_i];
        f.req_values += 1;
        f.req_bytes +%= @truncate(out.len); // This function should panic since the 32-bit
        // data limit is exceeded, so wrapping is fine.
        if (@intFromEnum(t.corpus_pos) >= @intFromEnum(Input.Index.reserved_start)) {
            @branchHint(.unlikely);
            f.bytes_input.bytesWeightedWithHash(out, weights, undefined);
            if (t.corpus_pos == .bytes_fresh) {
                f.input_builder.checkSmithedLen(out.len);
                f.input_builder.addBytes(uid, out);
            }
            return;
        }

        f.nextBytesInner(uid, out, weights);
        f.mmap_input.appendSlice(out);
    }

    fn nextSliceInner(
        f: *Fuzzer,
        uid: Uid,
        buf: []u8,
        len_weights: []const abi.Weight,
        byte_weights: []const abi.Weight,
    ) u32 {
        so: switch (f.nextUntyped(uid, byte_weights)) {
            .copy => |u| {
                var len: u32 = @intCast(u.bytes.len);
                if (!weightsContain(len, len_weights)) {
                    @branchHint(.unlikely);
                    len = @intCast(f.weightedValue(len_weights, sumWeightsInclusive(len_weights)));
                }

                if (u.bytes.len >= len) {
                    @branchHint(.likely);
                    @memcpy(buf[0..len], u.bytes[0..len]);
                    return len;
                }

                @memcpy(buf[0..u.bytes.len], u.bytes);
                const weights_incl_sum = sumWeightsInclusive(byte_weights);
                for (buf[u.bytes.len..len]) |*o| {
                    o.* = @intCast(f.weightedValue(byte_weights, weights_incl_sum));
                }
                return len;
            },
            .mutate => |u| {
                if (u.bytes.len == 0) continue :so .fresh;
                const len: u32 = len: {
                    const offseted: packed struct {
                        is: u3,
                        sub: bool,
                        by: u3,
                    } = @bitCast(f.rngInt(u7));
                    if (offseted.is != 0) {
                        const len = if (offseted.sub)
                            @as(u32, @intCast(u.bytes.len)) -| offseted.by
                        else
                            @min(u.bytes.len + offseted.by, @as(u32, @intCast(buf.len)));
                        if (weightsContain(len, len_weights)) {
                            break :len len;
                        }
                    }
                    break :len @intCast(f.weightedValue(
                        len_weights,
                        sumWeightsInclusive(len_weights),
                    ));
                };
                f.mutateBytes(u.bytes, buf[0..len], byte_weights);
                return len;
            },
            .fresh => {
                const len: u32 = @intCast(f.weightedValue(
                    len_weights,
                    sumWeightsInclusive(len_weights),
                ));
                const weights_incl_sum = sumWeightsInclusive(byte_weights);
                for (buf[0..len]) |*o| {
                    o.* = @intCast(f.weightedValue(byte_weights, weights_incl_sum));
                }
                return len;
            },
        }
    }

    pub fn nextSlice(
        f: *Fuzzer,
        uid: Uid,
        buf: []u8,
        len_weights: []const abi.Weight,
        byte_weights: []const abi.Weight,
    ) u32 {
        const t = &f.tests[f.test_i];
        f.req_values += 1;
        if (@intFromEnum(t.corpus_pos) >= @intFromEnum(Input.Index.reserved_start)) {
            @branchHint(.unlikely);
            const n = f.bytes_input.sliceWeightedWithHash(
                buf,
                len_weights,
                byte_weights,
                undefined,
            );
            if (t.corpus_pos == .bytes_fresh) {
                f.input_builder.checkSmithedLen(@as(usize, 4) + n);
                f.input_builder.addBytes(uid, buf[0..n]);
            }
            return n;
        }

        const n = f.nextSliceInner(uid, buf, len_weights, byte_weights);
        f.mmap_input.appendLittleInt(u32, n);
        f.mmap_input.appendSlice(buf[0..n]);
        f.req_bytes += n;
        return n;
    }
};

export fn fuzzer_init(cache_dir_path: abi.Slice) void {
    exec = .init(cache_dir_path.toSlice());
}

export fn fuzzer_coverage() abi.Coverage {
    const coverage_id = exec.pc_digest;
    const header = @volatileCast(exec.seenPcsHeader());

    var seen_count: usize = 0;
    for (header.seenBits()) |chunk| {
        seen_count += @popCount(chunk);
    }

    return .{
        .id = coverage_id,
        .runs = header.n_runs,
        .unique = header.unique_runs,
        .seen = seen_count,
    };
}

export fn fuzzer_main(
    n_tests: u32,
    seed: u32,
    limit_kind: abi.LimitKind,
    amount_or_instance: u64,
) void {
    fuzzer = .init(
        n_tests,
        seed ^ amount_or_instance, // seed is otherwise the same for all instances
        if (limit_kind == .forever) @as(u32, @intCast(amount_or_instance)) else 0,
        if (limit_kind == .forever) null else amount_or_instance,
    );
    defer fuzzer.deinit();
    abi.runner_start_input_poller();
    defer abi.runner_stop_input_poller();

    if (n_tests == 1) {
        // no swapping between fuzz tests
        runTest(0);
    } else {
        while (fuzzer.select()) |i| {
            runTest(i);
        }
    }
}

export fn fuzzer_receive_input(test_i: u32, bytes_slice: abi.Slice) bool {
    const recv = &fuzzer.tests[test_i].received;
    if (recv.state.startWrite()) return true;
    defer recv.state.finishWrite();

    const bytes = bytes_slice.toSlice();
    const len: u32 = @intCast(bytes.len);
    recv.inputs.ensureUnusedCapacity(gpa, 4 + bytes.len) catch @panic("OOM");
    recv.inputs.appendSliceAssumeCapacity(@ptrCast(&len));
    recv.inputs.appendSliceAssumeCapacity(bytes);

    return false;
}

fn runTest(i: u32) void {
    fuzzer.test_i = i;
    fuzzer.mmap_input.setTest(i);
    current_test_name = abi.runner_test_name(i).toSlice();
    abi.runner_test_run(i);
}

export fn fuzzer_set_test(test_one: abi.TestOne) void {
    fuzzer.test_one = test_one;
}

export fn fuzzer_new_input(bytes: abi.Slice) void {
    if (bytes.len == 0) return; // An entry of length zero is always present
    if (fuzzer.tests[fuzzer.test_i].start_mut_corpus != math.maxInt(u32)) return; // Test ran previously
    fuzzer.newInputExternal(bytes.toSlice());
}

export fn fuzzer_start_test() void {
    fuzzer.ensureCorpusLoaded();
    fuzzer.batch();
}

export fn fuzzer_int(uid: Uid, weights: abi.Weights) u64 {
    assert(uid.kind == .int);
    return fuzzer.nextInt(uid, weights.toSlice());
}

export fn fuzzer_eos(uid: Uid, weights: abi.Weights) bool {
    assert(uid.kind == .int);
    return fuzzer.nextEos(uid, weights.toSlice());
}

export fn fuzzer_bytes(uid: Uid, out: abi.MutSlice, weights: abi.Weights) void {
    assert(uid.kind == .bytes);
    return fuzzer.nextBytes(uid, out.toSlice(), weights.toSlice());
}

export fn fuzzer_slice(
    uid: Uid,
    buf: abi.MutSlice,
    len_weights: abi.Weights,
    byte_weights: abi.Weights,
) u32 {
    assert(uid.kind == .bytes);
    return fuzzer.nextSlice(uid, buf.toSlice(), len_weights.toSlice(), byte_weights.toSlice());
}

export fn fuzzer_unslide_address(addr: usize) usize {
    const si = std.debug.getSelfDebugInfo() catch @compileError("unsupported");
    const slide = si.getModuleSlide(io, addr) catch |err| {
        // The LLVM backend seems to insert placeholder values of `1` in __sancov_pcs1
        if (addr == 1) return 1;
        panic("failed to find virtual address slide for address 0x{x}: {t}", .{ addr, err });
    };
    return addr - slide;
}

/// Helps determine run uniqueness in the face of recursion.
/// Currently not used by the fuzzer.
export threadlocal var __sancov_lowest_stack: usize = 0;

export fn __sanitizer_cov_trace_pc_indir(callee: usize) void {
    // Not valuable because we already have pc tracing via 8bit counters.
    _ = callee;
}
export fn __sanitizer_cov_8bit_counters_init(start: usize, end: usize) void {
    // clang will emit a call to this function when compiling with code coverage instrumentation.
    // however, fuzzer_init() does not need this information since it directly reads from the
    // symbol table.
    _ = start;
    _ = end;
}
export fn __sanitizer_cov_pcs_init(start: usize, end: usize) void {
    // clang will emit a call to this function when compiling with code coverage instrumentation.
    // however, fuzzer_init() does not need this information since it directly reads from the
    // symbol table.
    _ = start;
    _ = end;
}

/// Reusable and recoverable input.
///
/// Has a 32-bit limit on the input length. This has the nice side effect that `u32`
/// can be used in most placed in `fuzzer` with the last `@sizeOf(abi.MmapInputHeader)`
/// values reserved.
const MemoryMappedInput = struct {
    const Header = abi.MmapInputHeader;

    len: u32,
    /// Directly accessing `memory` is unsafe, use either `inputSlice` or `writeSlice`.
    mmap: Io.File.MemoryMap,
    in_i: u32,

    /// `file` becomes owned by the returned `MemoryMappedInput`
    pub fn init(file: Io.File, instance_id: u32, in_i: u32) MemoryMappedInput {
        var size = file.length(io) catch |e|
            panic("failed to get length of 'in{x}': {t}", .{ in_i, e });
        if (size < std.heap.page_size_max) {
            size = std.heap.page_size_max;
            file.setLength(io, size) catch |e|
                panic("failed to resize 'in{x}': {t}", .{ in_i, e });
        }
        const map = file.createMemoryMap(io, .{ .len = size }) catch |e|
            panic("failed to memmap input file 'in{x}': {t}", .{ in_i, e });
        @as(*volatile Header, @ptrCast(map.memory)).* = .{
            .pc_digest = mem.nativeToLittle(u64, exec.pc_digest),
            .instance_id = mem.nativeToLittle(u32, instance_id),
            .test_i = 0,
            .len = 0,
        };
        return .{
            .len = 0,
            .mmap = map,
            .in_i = in_i,
        };
    }

    pub fn deinit(l: *MemoryMappedInput) void {
        const f = l.mmap.file;
        l.mmap.write(io) catch |e| panic("failed to write memory map of 'in{x}': {t}", .{ l.in_i, e });
        l.mmap.destroy(io);
        f.close(io);
        l.* = undefined;
    }

    /// Modify the array so that it can hold at least `additional_count` **more** items.
    ///
    /// Invalidates element pointers if additional memory is needed.
    pub fn ensureUnusedCapacity(l: *MemoryMappedInput, additional_count: usize) void {
        return l.ensureSize(@sizeOf(Header) + l.len + additional_count);
    }

    fn ensureSize(l: *MemoryMappedInput, min_capacity: usize) void {
        if (l.mmap.memory.len < min_capacity) {
            @branchHint(.unlikely);

            const max_capacity = 1 << 32; // The size of the header is not added
            // in order to keep the capacity page aligned and to allow those values to
            // reserved for other places.
            if (min_capacity > max_capacity) @panic("too much smith data requested");

            const new_capacity = @min(growCapacity(min_capacity), max_capacity);
            l.mmap.file.setLength(io, new_capacity) catch |e|
                panic("failed to resize 'in{x}': {t}", .{ l.in_i, e });
            l.mmap.setLength(io, new_capacity) catch |se| switch (se) {
                error.OperationUnsupported => {
                    const f = l.mmap.file;
                    l.mmap.destroy(io);
                    l.mmap = f.createMemoryMap(io, .{ .len = new_capacity }) catch |e|
                        panic("failed to memory map 'in{x}': {t}", .{ l.in_i, e });
                },
                else => panic("failed to resize memory map of 'in{x}': {t}", .{ l.in_i, se }),
            };
        }
    }

    // Only writing has side effects, so volatile is not needed
    pub fn inputSlice(l: *MemoryMappedInput) []const u8 {
        return l.mmap.memory[@sizeOf(Header)..][0..l.len];
    }

    // Writing has side effectsd, so volatile is necessary
    pub fn writeSlice(l: *MemoryMappedInput) []volatile u8 {
        return l.mmap.memory;
    }

    fn writeLen(l: *MemoryMappedInput) void {
        l.writeSlice()[@offsetOf(Header, "len")..][0..4].* =
            @bitCast(mem.nativeToLittle(u32, l.len));
    }

    pub fn setTest(l: *MemoryMappedInput, i: u32) void {
        l.writeSlice()[@offsetOf(Header, "test_i")..][0..4].* =
            @bitCast(mem.nativeToLittle(u32, i));
    }

    /// Invalidates all element pointers.
    pub fn clearRetainingCapacity(l: *MemoryMappedInput) void {
        l.len = 0;
        l.writeLen();
    }

    /// Append the slice of items to the list.
    ///
    /// Invalidates item pointers if more space is required.
    pub fn appendSlice(l: *MemoryMappedInput, items: []const u8) void {
        l.ensureUnusedCapacity(items.len);
        @memcpy(l.writeSlice()[@sizeOf(Header) + l.len ..][0..items.len], items);
        l.len += @as(u32, @intCast(items.len));
        l.writeLen();
    }

    /// Append the little-endian integer to the list.
    ///
    /// Invalidates item pointers if more space is required.
    pub fn appendLittleInt(l: *MemoryMappedInput, T: type, x: T) void {
        l.ensureUnusedCapacity(@sizeOf(T));
        l.writeSlice()[@sizeOf(Header) + l.len ..][0..@sizeOf(T)].* =
            @bitCast(mem.nativeToLittle(T, x));
        l.len += @sizeOf(T);
        l.writeLen();
    }

    /// Called when memory growth is necessary. Returns a capacity larger than
    /// minimum that grows super-linearly.
    fn growCapacity(minimum: usize) usize {
        return mem.alignForward(
            usize,
            minimum +| (minimum / 2 + std.heap.page_size_max),
            std.heap.page_size_max,
        );
    }
};
