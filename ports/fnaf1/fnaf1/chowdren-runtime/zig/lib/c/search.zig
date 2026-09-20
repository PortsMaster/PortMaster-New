const std = @import("std");
const builtin = @import("builtin");
const symbol = @import("../c.zig").symbol;

comptime {
    if (builtin.target.isMuslLibC() or builtin.target.isWasiLibC()) {
        symbol(&insque, "insque");
        symbol(&remque, "remque");
    }
}

const Node = extern struct {
    next: ?*Node,
    prev: ?*Node,
};

fn insque(element: *anyopaque, pred: ?*anyopaque) callconv(.c) void {
    const e: *Node = @ptrCast(@alignCast(element));

    if (pred) |p_ptr| {
        const p: *Node = @ptrCast(@alignCast(p_ptr));
        e.next = p.next;
        e.prev = p;
        p.next = e;

        if (e.next) |next| {
            next.prev = e;
        }
    } else {
        e.next = null;
        e.prev = null;
    }
}

fn remque(element: *anyopaque) callconv(.c) void {
    const e: *Node = @ptrCast(@alignCast(element));

    if (e.next) |next| next.prev = e.prev;
    if (e.prev) |prev| prev.next = e.next;
}

test "insque and remque" {
    var first = Node{ .next = null, .prev = null };
    var second = Node{ .next = null, .prev = null };
    var third = Node{ .next = null, .prev = null };

    insque(&first, null);
    try std.testing.expectEqual(@as(?*Node, null), first.next);
    try std.testing.expectEqual(@as(?*Node, null), first.prev);

    insque(&second, &first);
    try std.testing.expectEqual(@as(?*Node, &second), first.next);
    try std.testing.expectEqual(@as(?*Node, &first), second.prev);

    insque(&third, &first);
    try std.testing.expectEqual(@as(?*Node, &third), first.next);
    try std.testing.expectEqual(@as(?*Node, &second), third.next);
    try std.testing.expectEqual(@as(?*Node, &first), third.prev);
    try std.testing.expectEqual(@as(?*Node, &third), second.prev);

    remque(&third);
    try std.testing.expectEqual(@as(?*Node, &second), first.next);
    try std.testing.expectEqual(@as(?*Node, &first), second.prev);

    remque(&second);
    try std.testing.expectEqual(@as(?*Node, null), first.next);
}
