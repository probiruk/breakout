const Config = @import("../config.zig").Config;
const Vec2 = @import("../types.zig").Vec2;
const state = @import("./state.zig");

pub fn resolveBallCollision(ball_size: f32, ball_speed: f32, next_ball_pos: *Vec2) void {
    const pw: f32 = @as(f32, Config.paddle_w);
    const ph: f32 = @as(f32, Config.paddle_h);

    const paddle_top: f32 = state.paddle_pos.y;
    const paddle_bottom: f32 = state.paddle_pos.y + ph;
    const paddle_left: f32 = state.paddle_pos.x;
    const paddle_right: f32 = state.paddle_pos.x + pw;
    const paddle_center_x: f32 = paddle_left + (pw * 0.5);

    const ball_top: f32 = next_ball_pos.y - ball_size;
    const ball_bottom: f32 = next_ball_pos.y + ball_size;
    const ball_left: f32 = next_ball_pos.x - ball_size;
    const ball_right: f32 = next_ball_pos.x + ball_size;

    const ball_moving_down = state.ball_vel.y > 0;
    const ball_below_paddle_top = ball_bottom >= paddle_top;
    const ball_right_of_paddle_left = ball_right >= paddle_left;
    const ball_left_of_paddle_right = ball_left <= paddle_right;
    const ball_above_paddle_bottom = ball_top <= paddle_bottom;

    if (ball_moving_down and
        ball_below_paddle_top and
        ball_right_of_paddle_left and
        ball_left_of_paddle_right and
        ball_above_paddle_bottom)
    {
        next_ball_pos.y = paddle_top - ball_size;

        var hit: f32 = (next_ball_pos.x - paddle_center_x) / (pw * 0.5);
        if (hit < -1) hit = -1;
        if (hit > 1) hit = 1;

        const angle: f32 = hit * Config.max_bounce_angle;
        state.ball_vel.x = @sin(angle) * ball_speed;
        state.ball_vel.y = -@cos(angle) * ball_speed;
    }
}
