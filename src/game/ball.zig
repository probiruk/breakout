const Config = @import("../config.zig").Config;
const Vec2 = @import("../types.zig").Vec2;
const state = @import("./state.zig");

pub fn nextPos(dt: f32) Vec2 {
    return .{
        .x = state.ball_pos.x + state.ball_vel.x * dt,
        .y = state.ball_pos.y + state.ball_vel.y * dt,
    };
}

pub fn resolveWallBounce(ball_size: f32, next_ball_pos: *Vec2) void {
    const ball_top: f32 = next_ball_pos.y - ball_size;
    const ball_left: f32 = next_ball_pos.x - ball_size;
    const ball_right: f32 = next_ball_pos.x + ball_size;

    // top wall
    if (ball_top <= 0) {
        next_ball_pos.y = ball_size;
        state.ball_vel.y = -state.ball_vel.y;
    }

    // left / right wall
    const sw = @as(f32, Config.screen_w);
    if (ball_left <= 0) {
        next_ball_pos.x = ball_size;
        state.ball_vel.x = -state.ball_vel.x;
    } else if (ball_right >= sw) {
        next_ball_pos.x = sw - ball_size;
        state.ball_vel.x = -state.ball_vel.x;
    }
}
