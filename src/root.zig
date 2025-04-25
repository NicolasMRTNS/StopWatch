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

    pub fn prettyPrint(self: *StopWatch, writer: anytype) !void {
        if (!self.running) {
            const elapsed_ns = self.elapsed_ns;
            const elapsed_ms = @divTrunc(elapsed_ns, 1_000_000);
            const elapsed_us = @divTrunc(elapsed_ns, 1_000);
            const elapsed_s = @divTrunc(elapsed_ns, 1_000_000_000);

            if (elapsed_ns >= 1_000_000_000) {
                try std.fmt.format(writer, "{d}.{03d} s\n", .{
                    elapsed_s,
                    (elapsed_ns % 1_000_000_000) / 1_000_000,
                });
            } else if (elapsed_ns >= 1_000_000) {
                try std.fmt.format(writer, "{d}.{03d} ms\n", .{
                    elapsed_ms,
                    (elapsed_ns % 1_000_000) / 1_000,
                });
            } else {
                try std.fmt.format(writer, "{d}.{03d} µs\n", .{
                    elapsed_us,
                    elapsed_ns % 1_000,
                });
            }
        }
    }
};

test "can_start_and_stop_stopwatch" {
    var stopWatch = try StopWatch.start();

    try std.testing.expectEqual(true, stopWatch.running);

    stopWatch.stop();

    try std.testing.expectEqual(false, stopWatch.running);
}

test "prettyPrint outputs human readable time" {
    var sw = StopWatch{
        .start_time = 0,
        .elapsed_ns = 1_234_567,
        .running = false,
    };

    var buf = std.ArrayList(u8).init(std.testing.allocator);
    defer buf.deinit();

    const writer = buf.writer();
    try sw.prettyPrint(writer);

    const output = buf.items;
    try std.testing.expect(std.mem.indexOf(u8, output, "µs") != null);
}
