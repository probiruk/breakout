const std = @import("std");
const r = @import("raylib");
const Config = @import("../config.zig").Config;
const Theme = @import("../config.zig").Theme;
const state = @import("./state.zig");

var brick_sheet: ?r.Texture2D = null;

pub fn initAssets() !void {
    brick_sheet = try r.loadTexture("assets/breakout/sprites/sheets/breakout_tile_free.png");
}

pub fn deinitAssets() void {
    if (brick_sheet) |tex| {
        r.unloadTexture(tex);
        brick_sheet = null;
    }
}

pub fn draw() void {
    r.beginDrawing();
    defer r.endDrawing();

    const margin_x: i32 = @intFromFloat(Config.side_margin);

    r.clearBackground(Theme.col(Theme.bg_hex));
    const sheet = brick_sheet orelse return;

    // Paddle
    const paddle_src = r.Rectangle{ .x = 1574, .y = 912, .width = 115, .height = 64 };
    const paddle_dst = r.Rectangle{
        .x = state.paddle_pos.x,
        .y = state.paddle_pos.y,
        .width = Config.paddle_w,
        .height = Config.paddle_h,
    };
    r.drawTexturePro(sheet, paddle_src, paddle_dst, .{ .x = 0, .y = 0 }, 0.0, .white);

    // Ball
    const ball_src = r.Rectangle{ .x = 1403, .y = 652, .width = 64, .height = 64 };
    const ball_d = state.ball_size * 2.0;
    const ball_dst = r.Rectangle{
        .x = state.ball_pos.x,
        .y = state.ball_pos.y,
        .width = ball_d,
        .height = ball_d,
    };
    r.drawTexturePro(
        sheet,
        ball_src,
        ball_dst,
        .{ .x = ball_d * 0.5, .y = ball_d * 0.5 },
        0.0,
        .white,
    );

    for (state.bricks, 0..) |b, i| {
        if (b.hp == 0) continue;

        const row: usize = i / Config.brick_cols;

        const clean = switch (row) {
            0 => r.Rectangle{ .x = 772, .y = 260, .width = 384, .height = 128 }, // 07 red
            1 => r.Rectangle{ .x = 772, .y = 0, .width = 384, .height = 128 }, // 09 orange
            2 => r.Rectangle{ .x = 386, .y = 390, .width = 384, .height = 128 }, // 13 yellow
            3 => r.Rectangle{ .x = 386, .y = 130, .width = 384, .height = 128 }, // 15 green
            4 => r.Rectangle{ .x = 386, .y = 650, .width = 384, .height = 128 }, // 11 cyan
            else => r.Rectangle{ .x = 772, .y = 390, .width = 384, .height = 128 }, // 01 blue
        };
        const cracked = switch (row) {
            0 => r.Rectangle{ .x = 772, .y = 130, .width = 384, .height = 128 }, // 08 red cracked
            1 => r.Rectangle{ .x = 772, .y = 650, .width = 384, .height = 128 }, // 10 orange cracked
            2 => r.Rectangle{ .x = 386, .y = 260, .width = 384, .height = 128 }, // 14 yellow cracked
            3 => r.Rectangle{ .x = 386, .y = 0, .width = 384, .height = 128 }, // 16 green cracked
            4 => r.Rectangle{ .x = 386, .y = 520, .width = 384, .height = 128 }, // 12 cyan cracked
            else => r.Rectangle{ .x = 0, .y = 0, .width = 384, .height = 128 }, // 02 blue cracked
        };
        const brick = if (b.max_hp == 2 and b.hp == 1) cracked else clean;

        const dst = r.Rectangle{ .x = b.x, .y = b.y, .width = b.w, .height = b.h };

        r.drawTexturePro(
            sheet,
            brick,
            dst,
            .{ .x = 0, .y = 0 },
            0.0,
            .white,
        );
    }

    // score
    var score_buf: [24]u8 = undefined;
    const score_text = std.fmt.bufPrintZ(&score_buf, "Score: {}", .{state.score}) catch unreachable;
    r.drawText(score_text, margin_x, 22, 24, .white);

    // lives (heart icons)
    const heart_src = r.Rectangle{ .x = 1637, .y = 652, .width = 64, .height = 58 };
    const heart_w: f32 = 24;
    const heart_h: f32 = 22;
    const spacing: f32 = 6;

    const lives_f: f32 = @floatFromInt(state.lives);
    const total_w = if (state.lives == 0) 0 else (lives_f * heart_w) + ((lives_f - 1) * spacing);
    const start_x = @as(f32, @floatFromInt(Config.screen_w - margin_x)) - total_w;

    var i: u8 = 0;
    while (i < state.lives) : (i += 1) {
        const idx: f32 = @floatFromInt(i);
        const x = start_x + idx * (heart_w + spacing);
        const dst = r.Rectangle{ .x = x, .y = 24, .width = heart_w, .height = heart_h };
        r.drawTexturePro(sheet, heart_src, dst, .{ .x = 0, .y = 0 }, 0.0, .white);
    }

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
