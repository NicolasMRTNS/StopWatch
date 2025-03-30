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
};

test "can_start_and_stop_stopwatch" {
    var stopWatch = try StopWatch.start();

    try std.testing.expectEqual(true, stopWatch.running);

    stopWatch.stop();

    try std.testing.expectEqual(false, stopWatch.running);
}
