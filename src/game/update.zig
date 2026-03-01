const std = @import("std");
const Config = @import("../config.zig").Config;
const types = @import("../types.zig");
const Vec2 = types.Vec2;
const Effect = types.Effect;
const EffectType = types.EffectType;
const state = @import("./state.zig");
const paddle = @import("./paddle.zig");
const ball = @import("./ball.zig");
const collision = @import("./collision.zig");

pub fn step(dt: f32, effects: *std.ArrayList(Effect)) std.mem.Allocator.Error!f32 {
    var ball_size = Config.ball_radius;
    var ball_speed = Config.ball_max_speed;

    for (effects.items, 0..) |*effect, index| {
        switch (effect.type) {
            EffectType.BigBall => {
                ball_size += 10;
            },
            EffectType.FastBall => {
                ball_speed += 10;
            },
        }

        effect.time += dt;
        if (effect.time >= effect.duration) {
            if (effects.items.len <= index) continue;
            _ = effects.orderedRemove(index);
        }
    }

    var next_ball_pos: Vec2 = ball.nextPos(dt);

    ball.resolveWallBounce(ball_size, &next_ball_pos);

    paddle.resolveBallCollision(ball_size, ball_speed, &next_ball_pos);

    try collision.resolveBrickCollision(ball_size, &next_ball_pos, effects);

    state.ball_pos = next_ball_pos;
    return ball_size;
}
