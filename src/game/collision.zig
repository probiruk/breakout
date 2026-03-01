const std = @import("std");
const types = @import("../types.zig");
const Vec2 = types.Vec2;
const Effect = types.Effect;
const EffectType = types.EffectType;
const state = @import("./state.zig");
const game_effects = @import("./effects.zig");

pub fn resolveBrickCollision(
    ball_size: f32,
    next_ball_pos: *Vec2,
) std.mem.Allocator.Error!void {
    const ball_top: f32 = next_ball_pos.y - ball_size;
    const ball_bottom: f32 = next_ball_pos.y + ball_size;
    const ball_left: f32 = next_ball_pos.x - ball_size;
    const ball_right: f32 = next_ball_pos.x + ball_size;

    for (state.bricks, 0..) |brick, i| {
        if (brick.hp == 0) continue;
        const brick_top: f32 = brick.y;
        const brick_bottom: f32 = brick.y + brick.h;
        const brick_left: f32 = brick.x;
        const brick_right: f32 = brick.x + brick.w;

        const ball_below_brick_top = ball_bottom >= brick_top;
        const ball_above_brick_bottom = ball_top <= brick_bottom;
        const ball_right_past_brick_left = ball_right >= brick_left;
        const ball_left_before_brick_right = ball_left <= brick_right;

        if (ball_below_brick_top and
            ball_above_brick_bottom and
            ball_right_past_brick_left and
            ball_left_before_brick_right)
        {
            const has_big_ball = game_effects.hasEffect(EffectType.BigBall);

            if (has_big_ball) {
                state.bricks[i].hp = 0;
            } else {
                state.bricks[i].hp -= 1;
            }
            state.score += 1;

            try game_effects.newPotentialEffect();

            if (has_big_ball) continue;

            const overlap_x = @min(ball_right - brick_left, brick_right - ball_left);
            const overlap_y = @min(ball_bottom - brick_top, brick_bottom - ball_top);

            const brick_cx = (brick_left + brick_right) * 0.5;
            const brick_cy = (brick_top + brick_bottom) * 0.5;

            if (overlap_x < overlap_y) {
                state.ball_vel.x = -state.ball_vel.x;
                next_ball_pos.x += if (next_ball_pos.x < brick_cx) -overlap_x else overlap_x;
            } else {
                state.ball_vel.y = -state.ball_vel.y;
                next_ball_pos.y += if (next_ball_pos.y < brick_cy) -overlap_y else overlap_y;
            }
            break;
        }
    }
}
