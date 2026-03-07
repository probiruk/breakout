const std = @import("std");
const Config = @import("../config.zig").Config;
const types = @import("../types.zig");
const Vec2 = types.Vec2;
const EffectType = types.EffectType;
const Ball = types.Ball;
const state = @import("./state.zig");
const paddle = @import("./paddle.zig");
const ball = @import("./ball.zig");
const collision = @import("./collision.zig");
const pickups = @import("./pickups.zig");

pub fn step(dt: f32) std.mem.Allocator.Error!void {
    const ball_size = Config.ball_radius;
    var ball_speed = Config.ball_max_speed;
    var paddle_width: f32 = Config.paddle_w;

    var i: usize = 0;
    while (i < state.effects.items.len) {
        const effect = &state.effects.items[i];
        switch (effect.type) {
            EffectType.MultiBall => {},
            EffectType.FastBall => {
                ball_speed += 10;
            },
            EffectType.SlowBall => {
                ball_speed -= 120;
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
    ball_speed = @max(@as(f32, 140), ball_speed);
    state.ball_size = ball_size;
    state.paddle_width = paddle_width;
    const max_paddle_x = @as(f32, @floatFromInt(Config.screen_w)) - state.paddle_width;
    if (state.paddle_pos.x > max_paddle_x) {
        state.paddle_pos.x = @max(0.0, max_paddle_x);
    }

    try pickups.update(dt);

    if (state.ball_vel.x != 0 or state.ball_vel.y != 0) {
        var next_ball_pos: Vec2 = ball.nextPos(state.ball_pos, state.ball_vel, dt);

        if (ball.resolveWallBounce(&state.ball_vel, ball_size, &next_ball_pos)) {
            ball.handleMainBallLoss(&next_ball_pos);
        } else {
            paddle.resolveBallCollision(&state.ball_vel, ball_size, ball_speed, &next_ball_pos);
            try collision.resolveBrickCollision(&state.ball_vel, ball_size, &next_ball_pos);
            state.ball_pos = next_ball_pos;
        }
    }

    var extra_i: usize = 0;
    while (extra_i < state.extra_balls.items.len) {
        var eb: Ball = state.extra_balls.items[extra_i];
        var next_extra_pos = ball.nextPos(eb.pos, eb.vel, dt);

        if (ball.resolveWallBounce(&eb.vel, ball_size, &next_extra_pos)) {
            _ = state.extra_balls.orderedRemove(extra_i);
            continue;
        }

        paddle.resolveBallCollision(&eb.vel, ball_size, ball_speed, &next_extra_pos);
        try collision.resolveBrickCollision(&eb.vel, ball_size, &next_extra_pos);
        eb.pos = next_extra_pos;
        state.extra_balls.items[extra_i] = eb;
        extra_i += 1;
    }
}
