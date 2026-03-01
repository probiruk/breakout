const std = @import("std");
const r = @import("raylib");
const Config = @import("../config.zig").Config;
const Theme = @import("../config.zig").Theme;
const state = @import("./state.zig");

pub fn draw() void {
    r.beginDrawing();
    defer r.endDrawing();

    const margin_x: i32 = @intFromFloat(Config.side_margin);

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
        state.ball_size,
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

        r.drawRectangleRec(.{
            .x = b.x,
            .y = b.y,
            .width = b.w,
            .height = b.h,
        }, color);
    }

    // score
    var score_buf: [16]u8 = undefined;
    const score_text = std.fmt.bufPrintZ(&score_buf, "{}", .{state.score}) catch unreachable;
    r.drawText(score_text, margin_x, 20, 30, .white);

    // lives
    var lives_buf: [16]u8 = undefined;
    const lives_text = std.fmt.bufPrintZ(&lives_buf, "{}", .{state.lives}) catch unreachable;
    const lives_w = r.measureText(lives_text, 30);
    r.drawText(lives_text, Config.screen_w - margin_x - lives_w, 20, 30, .white);

    // game over text
    if (state.lives == 0) {
        const game_over_text = "Game over";
        const game_over_size = 20;
        const game_over_w = r.measureText(game_over_text, game_over_size);
        const game_over_x = @divTrunc(Config.screen_w - game_over_w, 2);
        const game_over_y = @divTrunc(Config.screen_h - game_over_size, 2);
        r.drawText(game_over_text, game_over_x, game_over_y, game_over_size, .white);

        const restart_text = "Press R to restart";
        const restart_size = 16;
        const restart_w = r.measureText(restart_text, restart_size);
        const restart_x = @divTrunc(Config.screen_w - restart_w, 2);
        const restart_y = game_over_y + 30;
        r.drawText(restart_text, restart_x, restart_y, restart_size, .white);
    }
}
