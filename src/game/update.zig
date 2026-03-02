const std = @import("std");
const Config = @import("../config.zig").Config;
const types = @import("../types.zig");
const Vec2 = types.Vec2;
const EffectType = types.EffectType;
const state = @import("./state.zig");
const paddle = @import("./paddle.zig");
const ball = @import("./ball.zig");
const collision = @import("./collision.zig");
const pickups = @import("./pickups.zig");

pub fn step(dt: f32) std.mem.Allocator.Error!void {
    var ball_size = Config.ball_radius;
    var ball_speed = Config.ball_max_speed;
    var paddle_width: f32 = Config.paddle_w;

    var i: usize = 0;
    while (i < state.effects.items.len) {
        const effect = &state.effects.items[i];
        switch (effect.type) {
            EffectType.BigBall => {
                ball_size += 10;
            },
            EffectType.FastBall => {
                ball_speed += 10;
            },
            EffectType.ExpandPaddle => {
                paddle_width += @as(f32, 0.5) * paddle_width;
            },
        }

        effect.*.time += dt;
        if (effect.time >= effect.duration) {
            _ = state.effects.swapRemove(i);
            continue;
        }
        i += 1;
    }
    state.ball_size = ball_size;
    state.paddle_width = paddle_width;
    const max_paddle_x = @as(f32, @floatFromInt(Config.screen_w)) - state.paddle_width;
    if (state.paddle_pos.x > max_paddle_x) {
        state.paddle_pos.x = @max(0.0, max_paddle_x);
    }

    try pickups.update(dt);

    if (state.ball_vel.x != 0 or state.ball_vel.y != 0) {
        var next_ball_pos: Vec2 = ball.nextPos(dt);

        ball.resolveWallBounce(ball_size, &next_ball_pos);

        paddle.resolveBallCollision(ball_size, ball_speed, &next_ball_pos);

        try collision.resolveBrickCollision(ball_size, &next_ball_pos);

        state.ball_pos = next_ball_pos;
    }
}
