const std = @import("std");
const r = @import("raylib");
const Config = @import("../config.zig").Config;
const Theme = @import("../config.zig").Theme;
const BrickType = @import("../types.zig").BrickType;
const bricks = @import("./bricks.zig");
const effects = @import("./effects.zig");
const state = @import("./state.zig");

var brick_sheet: ?r.Texture2D = null;

pub fn initAssets() !void {
    brick_sheet = try r.loadTexture("assets/sprites/atlas/breakout_tile_free.png");
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
    const paddle_normal_anim_frames = [_]r.Rectangle{
        .{ .x = 1158, .y = 462, .width = 243, .height = 64 }, // 50
        .{ .x = 1158, .y = 528, .width = 243, .height = 64 }, // 51
        .{ .x = 1158, .y = 594, .width = 243, .height = 64 }, // 52
    };
    const paddle_fire_anim_frames = [_]r.Rectangle{
        .{ .x = 1158, .y = 660, .width = 243, .height = 64 }, // 53
        .{ .x = 839, .y = 846, .width = 243, .height = 64 }, // 54
        .{ .x = 772, .y = 780, .width = 243, .height = 64 }, // 55
    };
    const pickup_multiball_src = r.Rectangle{ .x = 594, .y = 910, .width = 243, .height = 64 }; // 43
    const pickup_fast_src = r.Rectangle{ .x = 349, .y = 910, .width = 243, .height = 64 }; // 42
    const paddle_expand_src = r.Rectangle{ .x = 0, .y = 910, .width = 347, .height = 64 }; // 56
    const pickup_slow_src = r.Rectangle{ .x = 1158, .y = 66, .width = 243, .height = 64 }; // 41
    const pickup_shrink_src = r.Rectangle{ .x = 1158, .y = 198, .width = 243, .height = 64 }; // 46
    const pickup_expand_src = r.Rectangle{ .x = 1158, .y = 264, .width = 243, .height = 64 }; // 47
    const pickup_fire_src = r.Rectangle{ .x = 1158, .y = 330, .width = 243, .height = 64 }; // 48
    const fire_shot_src = r.Rectangle{ .x = 0, .y = 990, .width = 10, .height = 21 }; // 61
    const anim_speed_factor: f32 = if (effects.hasEffect(.SlowBall)) Config.slow_velocity_factor else 1.0;
    const normal_anim_t = @as(usize, @intFromFloat(@floor(r.getTime() * (18.0 * anim_speed_factor))));
    const expanded_anim_t = @as(usize, @intFromFloat(@floor(r.getTime() * (12.0 * anim_speed_factor))));
    const is_fire_paddle = effects.hasEffect(.FirePaddle);
    const active_paddle_anim_frames = if (is_fire_paddle) paddle_fire_anim_frames else paddle_normal_anim_frames;
    const normal_anim_idx = normal_anim_t % active_paddle_anim_frames.len;
    const expanded_anim_idx = expanded_anim_t % active_paddle_anim_frames.len;
    const paddle_normal_src = active_paddle_anim_frames[normal_anim_idx];
    const paddle_expand_overlay_src = active_paddle_anim_frames[expanded_anim_idx];
    const is_expanded = state.paddle_width > Config.paddle_w;
    const paddle_dst = r.Rectangle{
        .x = state.paddle_pos.x,
        .y = state.paddle_pos.y,
        .width = state.paddle_width,
        .height = Config.paddle_h,
    };
    if (is_expanded) {
        r.drawTexturePro(sheet, paddle_expand_src, paddle_dst, .{ .x = 0, .y = 0 }, 0.0, .white);
        // Add clearly visible animated zigzag motion on top of the expanded base.
        r.drawTexturePro(
            sheet,
            paddle_expand_overlay_src,
            paddle_dst,
            .{ .x = 0, .y = 0 },
            0.0,
            .{ .r = 255, .g = 255, .b = 255, .a = 190 },
        );
    } else {
        r.drawTexturePro(sheet, paddle_normal_src, paddle_dst, .{ .x = 0, .y = 0 }, 0.0, .white);
    }

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
    for (state.extra_balls.items) |eb| {
        const extra_dst = r.Rectangle{
            .x = eb.pos.x,
            .y = eb.pos.y,
            .width = ball_d,
            .height = ball_d,
        };
        r.drawTexturePro(
            sheet,
            ball_src,
            extra_dst,
            .{ .x = ball_d * 0.5, .y = ball_d * 0.5 },
            0.0,
            .white,
        );
    }

    // Bricks
    for (state.bricks, 0..) |b, i| {
        if (b.hp == 0) continue;

        const row: usize = i / Config.brick_cols;
        const col: usize = i % Config.brick_cols;

        const normal_clean = switch (row) {
            0 => r.Rectangle{ .x = 772, .y = 260, .width = 384, .height = 128 }, // 07 red
            1 => r.Rectangle{ .x = 772, .y = 0, .width = 384, .height = 128 }, // 09 orange
            2 => r.Rectangle{ .x = 386, .y = 390, .width = 384, .height = 128 }, // 13 yellow
            3 => r.Rectangle{ .x = 386, .y = 130, .width = 384, .height = 128 }, // 15 green
            4 => r.Rectangle{ .x = 386, .y = 650, .width = 384, .height = 128 }, // 11 cyan
            else => r.Rectangle{ .x = 772, .y = 390, .width = 384, .height = 128 }, // 01 blue
        };
        const normal_cracked = switch (row) {
            0 => r.Rectangle{ .x = 772, .y = 130, .width = 384, .height = 128 }, // 08 red cracked
            1 => r.Rectangle{ .x = 772, .y = 650, .width = 384, .height = 128 }, // 10 orange cracked
            2 => r.Rectangle{ .x = 386, .y = 260, .width = 384, .height = 128 }, // 14 yellow cracked
            3 => r.Rectangle{ .x = 386, .y = 0, .width = 384, .height = 128 }, // 16 green cracked
            4 => r.Rectangle{ .x = 386, .y = 520, .width = 384, .height = 128 }, // 12 cyan cracked
            else => r.Rectangle{ .x = 0, .y = 0, .width = 384, .height = 128 }, // 02 blue cracked
        };
        const mini_tiles = [_]r.Rectangle{
            .{ .x = 1533, .y = 392, .width = 128, .height = 128 }, // 21
            .{ .x = 1403, .y = 132, .width = 128, .height = 128 }, // 22
            .{ .x = 1403, .y = 262, .width = 128, .height = 128 }, // 23
            .{ .x = 1403, .y = 392, .width = 128, .height = 128 }, // 24
            .{ .x = 1403, .y = 522, .width = 128, .height = 128 }, // 25
            .{ .x = 1507, .y = 652, .width = 128, .height = 128 }, // 26
            .{ .x = 1533, .y = 132, .width = 128, .height = 128 }, // 27
            .{ .x = 1533, .y = 262, .width = 128, .height = 128 }, // 28
            .{ .x = 1574, .y = 782, .width = 128, .height = 128 }, // 29
            .{ .x = 1533, .y = 522, .width = 128, .height = 128 }, // 30
        };

        if (b.type == BrickType.Mini) {
            const mini_layout = bricks.getMiniRowLayout(b);
            const base_idx = col * mini_layout.count_per_brick;
            var j: usize = 0;
            while (j < mini_layout.count_per_brick) : (j += 1) {
                const bit_shift: u3 = @intCast(j);
                if ((b.mini_mask & (@as(u8, 1) << bit_shift)) == 0) continue;
                const global_idx = base_idx + j;
                const idx_f: f32 = @floatFromInt(global_idx);
                const x = mini_layout.start_x + idx_f * (mini_layout.side + mini_layout.gap);
                const mini_src = mini_tiles[global_idx % mini_tiles.len];
                const mini_dst = r.Rectangle{
                    .x = x,
                    .y = mini_layout.start_y,
                    .width = mini_layout.side,
                    .height = mini_layout.side,
                };
                r.drawTexturePro(sheet, mini_src, mini_dst, .{ .x = 0, .y = 0 }, 0.0, .white);
            }
            continue;
        }

        const brick = if (b.max_hp == 2 and b.hp == 1) normal_cracked else normal_clean;
        const dst = r.Rectangle{ .x = b.x, .y = b.y, .width = b.w, .height = b.h };

        r.drawTexturePro(sheet, brick, dst, .{ .x = 0, .y = 0 }, 0.0, .white);
    }

    // pickups
    for (state.pickups.items) |pickup| {
        const pickup_src = switch (pickup.effect.type) {
            .MultiBall => pickup_multiball_src,
            .FastBall => pickup_fast_src,
            .SlowBall => pickup_slow_src,
            .ExpandPaddle => pickup_expand_src,
            .ShrinkPaddle => pickup_shrink_src,
            .FirePaddle => pickup_fire_src,
        };
        const pickup_dst = r.Rectangle{
            .x = pickup.x,
            .y = pickup.y,
            .width = pickup.w,
            .height = pickup.h,
        };
        r.drawTexturePro(
            sheet,
            pickup_src,
            pickup_dst,
            .{ .x = 0, .y = 0 },
            0.0,
            .white,
        );
    }

    for (state.fire_shots.items) |shot| {
        const shot_dst = r.Rectangle{
            .x = shot.x,
            .y = shot.y,
            .width = shot.w,
            .height = shot.h,
        };
        r.drawTexturePro(sheet, fire_shot_src, shot_dst, .{ .x = 0, .y = 0 }, 0.0, .white);
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
