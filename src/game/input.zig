const std = @import("std");
const r = @import("raylib");
const Config = @import("../config.zig").Config;
const state = @import("./state.zig");

pub fn updatePaddle(dt: f32) void {
    if (r.isKeyDown(.space) and
        state.ball_vel.x == 0 and
        state.ball_vel.y == 0)
    {
        state.ball_vel.x = @sin(Config.launch_angle) * Config.ball_max_speed;
        state.ball_vel.y = -@cos(Config.launch_angle) * Config.ball_max_speed;
    }

    if (state.ball_vel.x == 0 and state.ball_vel.y == 0) return;

    var dir: f32 = 0.0;
    if (r.isKeyDown(.right)) dir += 1.0;
    if (r.isKeyDown(.left)) dir -= 1.0;

    const delta = dir * Config.paddle_speed * dt;
    const next_x = state.paddle_pos.x + delta;

    if (next_x > 0 and next_x < @as(f32, Config.screen_w - Config.paddle_w)) {
        state.paddle_pos.x = next_x;
    }
}
