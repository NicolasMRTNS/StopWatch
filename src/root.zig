const std = @import("std");

pub const StopWatch = struct {
    start_time: i64,
    elapsed_ns: i64,
    running: bool,

    pub fn start() !StopWatch {
        return StopWatch{
            .start_time = try std.time.Timer.start().read(),
            .elapsed_ns = 0,
            .running = true,
        };
    }

    pub fn stop(self: *StopWatch) void {
        if (self.running) {
            self.elapsed_ns += std.time.nanoTimestamp() - self.start_time;
            self.running = false;
        }
    }

    pub fn elapsedMillis(self: *StopWatch) i64 {
        if (self.running) {
            return (self.elapsed_ns + (std.time.nanoTimestamp() - self.start_time)) / 1_000_000;
        }
        return self.elapsed_ns / 1_000_000;
    }
};
