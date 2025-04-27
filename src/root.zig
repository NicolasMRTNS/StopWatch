const std = @import("std");

pub const StopWatch = struct {
    start_time: i64,
    elapsed_ns: i64,
    running: bool,

    pub fn start() !StopWatch {
        return StopWatch{
            .start_time = @as(i64, @truncate(std.time.nanoTimestamp())),
            .elapsed_ns = 0,
            .running = true,
        };
    }

    pub fn stop(self: *StopWatch) void {
        if (self.running) {
            self.elapsed_ns += @as(i64, @truncate(std.time.nanoTimestamp())) - self.start_time;
            self.running = false;
        }
    }

    pub fn elapsedMillis(self: *StopWatch) i64 {
        if (self.running) {
            return (self.elapsed_ns + (@as(i64, @truncate(std.time.nanoTimestamp())) - self.start_time)) / 1_000_000;
        }
        return self.elapsed_ns / 1_000_000;
    }

    pub fn prettyString(self: *const StopWatch, allocator: std.mem.Allocator) ![]const u8 {
        const elapsed_ns = if (self.running)
            self.elapsed_ns + (@as(i64, @truncate(std.time.nanoTimestamp())) - self.start_time)
        else
            self.elapsed_ns;

        const elapsed_ms = @divTrunc(elapsed_ns, 1_000_000);
        const elapsed_us = @divTrunc(elapsed_ns, 1_000);
        const elapsed_s = @divTrunc(elapsed_ns, 1_000_000_000);

        var buf = try std.ArrayList(u8).initCapacity(allocator, 32);
        defer buf.deinit();
        const writer = buf.writer();

        if (elapsed_ns >= 1_000_000_000) {
            try std.fmt.format(writer, "{d}.{03d} s", .{
                elapsed_s,
                (@divTrunc(@rem(elapsed_ns, 1_000_000_000), 1_000_000)),
            });
        } else if (elapsed_ns >= 1_000_000) {
            try std.fmt.format(writer, "{d}.{03d} ms", .{
                elapsed_ms,
                (@divTrunc(@rem(elapsed_ns, 1_000_000), 1_000)),
            });
        } else {
            try std.fmt.format(writer, "{d}.{03d} µs", .{
                elapsed_us,
                (@rem(elapsed_ns, 1_000)),
            });
        }

        return buf.toOwnedSlice();
    }
};

test "can_start_and_stop_stopwatch" {
    var stopWatch = try StopWatch.start();

    try std.testing.expectEqual(true, stopWatch.running);

    stopWatch.stop();

    try std.testing.expectEqual(false, stopWatch.running);
}

test "pretty string elapsed time" {
    const stopWatch = @This().StopWatch;

    var gpa = std.testing.allocator;
    var sw = stopWatch{
        .start_time = 0,
        .elapsed_ns = 1_234_567, // 1.234 ms
        .running = false,
    };

    const str = try sw.prettyString(gpa);
    defer gpa.free(str);

    try std.testing.expectEqualStrings("1.234 ms", str);
}
