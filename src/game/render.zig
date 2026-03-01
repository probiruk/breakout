const std = @import("std");
const r = @import("raylib");
const Config = @import("../config.zig").Config;
const Theme = @import("../config.zig").Theme;
const state = @import("./state.zig");

pub fn draw(ball_size: f32) void {
    r.beginDrawing();
    defer r.endDrawing();

    r.clearBackground(Theme.col(Theme.bg_hex));

    r.drawRectangle(
        @intFromFloat(state.paddle_pos.x),
        @intFromFloat(state.paddle_pos.y),
        @intFromFloat(Config.paddle_w),
        @intFromFloat(Config.paddle_h),
        Theme.col(Theme.paddle_hex),
    );

    r.drawCircle(
        @intFromFloat(state.ball_pos.x),
        @intFromFloat(state.ball_pos.y),
        ball_size,
        Theme.col(Theme.ball_hex),
    );

    for (state.bricks, 0..) |b, i| {
        if (!b.alive) continue;

        const row: usize = i / Config.brick_cols;

        const color = switch (row) {
            0 => Theme.col(Theme.brick0_hex),
            1 => Theme.col(Theme.brick1_hex),
            2 => Theme.col(Theme.brick2_hex),
            3 => Theme.col(Theme.brick3_hex),
            4 => Theme.col(Theme.brick4_hex),
            else => Theme.col(Theme.brick5_hex),
        };

        r.drawRectangle(
            @intFromFloat(b.x),
            @intFromFloat(b.y),
            @intFromFloat(b.w),
            @intFromFloat(b.h),
            color,
        );
    }

    var buf: [16]u8 = undefined;
    const text = std.fmt.bufPrintZ(&buf, "{}", .{state.score}) catch unreachable;
    r.drawText(text, Config.side_margin, 20, 30, .white);
}
