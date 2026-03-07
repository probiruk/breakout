const std = @import("std");
const Config = @import("../config.zig").Config;
const types = @import("../types.zig");
const Vec2 = types.Vec2;
const EffectType = types.EffectType;
const Ball = types.Ball;
const FireShot = types.FireShot;
const state = @import("./state.zig");
const paddle = @import("./paddle.zig");
const ball = @import("./ball.zig");
const collision = @import("./collision.zig");
const pickups = @import("./pickups.zig");

pub fn step(dt: f32) std.mem.Allocator.Error!void {
    const ball_size = Config.ball_radius;
    var ball_speed = Config.ball_max_speed;
    var paddle_width: f32 = Config.paddle_w;
    var slow_ball_active = false;
    var fast_ball_active = false;
    var expand_paddle_active = false;
    var shrink_paddle_active = false;
    var fire_paddle_active = false;

    var i: usize = 0;
    while (i < state.effects.items.len) {
        const effect = &state.effects.items[i];
        switch (effect.type) {
            EffectType.MultiBall => {},
            EffectType.FastBall => {
                fast_ball_active = true;
            },
            EffectType.SlowBall => {
                slow_ball_active = true;
            },
            EffectType.ExpandPaddle => {
                expand_paddle_active = true;
            },
            EffectType.ShrinkPaddle => {
                shrink_paddle_active = true;
            },
            EffectType.FirePaddle => {
                fire_paddle_active = true;
            },
        }

        effect.*.time += dt;
        if (effect.time >= effect.duration) {
            _ = state.effects.swapRemove(i);
            continue;
        }
        i += 1;
    }
    if (expand_paddle_active and !shrink_paddle_active) {
        paddle_width += @as(f32, 0.5) * paddle_width;
    } else if (shrink_paddle_active and !expand_paddle_active) {
        paddle_width = Config.paddle_shrink_w;
    }
    const movement_factor: f32 = if (slow_ball_active and !fast_ball_active)
        Config.slow_velocity_factor
    else if (fast_ball_active and !slow_ball_active)
        Config.fast_velocity_factor
    else
        1.0;
    const movement_dt: f32 = dt * movement_factor;
    ball_speed = @max(Config.ball_min_speed, ball_speed);
    state.ball_size = ball_size;
    state.paddle_width = paddle_width;
    const max_paddle_x = @as(f32, @floatFromInt(Config.screen_w)) - state.paddle_width;
    if (state.paddle_pos.x > max_paddle_x) {
        state.paddle_pos.x = @max(0.0, max_paddle_x);
    }

    if (fire_paddle_active and !state.fire_mode_was_active) {
        state.fire_shot_cooldown = 0.0;
    }

    if (fire_paddle_active) {
        state.fire_shot_cooldown -= dt;
        while (state.fire_shot_cooldown <= 0.0) {
            const next_interval = try spawnFireShots();
            state.fire_shot_cooldown += next_interval;
        }
    } else {
        state.fire_shot_cooldown = 0.0;
    }
    state.fire_mode_was_active = fire_paddle_active;

    var shot_i: usize = 0;
    while (shot_i < state.fire_shots.items.len) {
        var shot = state.fire_shots.items[shot_i];
        shot.y += shot.vy * movement_dt;

        if (shot.y + shot.h < 0) {
            _ = state.fire_shots.orderedRemove(shot_i);
            continue;
        }

        if (try collision.resolveFireShotCollision(&shot)) {
            _ = state.fire_shots.orderedRemove(shot_i);
            continue;
        }

        state.fire_shots.items[shot_i] = shot;
        shot_i += 1;
    }

    try pickups.update(movement_dt);

    if (state.ball_vel.x != 0 or state.ball_vel.y != 0) {
        var next_ball_pos: Vec2 = ball.nextPos(state.ball_pos, state.ball_vel, movement_dt);

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
        var next_extra_pos = ball.nextPos(eb.pos, eb.vel, movement_dt);

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

fn spawnFireShots() std.mem.Allocator.Error!f32 {
    const shot_cfg = Config.fire_mode;
    const shot_top = state.paddle_pos.y - shot_cfg.shot_h;
    const left_x = state.paddle_pos.x + shot_cfg.shot_spawn_inset;
    const right_x = state.paddle_pos.x + state.paddle_width - shot_cfg.shot_spawn_inset - shot_cfg.shot_w;
    const left_shot = FireShot{
        .x = left_x,
        .y = shot_top,
        .w = shot_cfg.shot_w,
        .h = shot_cfg.shot_h,
        .vy = shot_cfg.shot_speed_y,
    };
    try state.fire_shots.append(std.heap.page_allocator, left_shot);

    if (right_x - left_x > shot_cfg.shot_w * 1.5) {
        const right_shot = FireShot{
            .x = right_x,
            .y = shot_top,
            .w = shot_cfg.shot_w,
            .h = shot_cfg.shot_h,
            .vy = shot_cfg.shot_speed_y,
        };
        try state.fire_shots.append(std.heap.page_allocator, right_shot);
    }

    return shot_cfg.shot_interval;
}
