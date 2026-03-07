const std = @import("std");
const Config = @import("../config.zig").Config;
const Vec2 = @import("../types.zig").Vec2;
const Ball = @import("../types.zig").Ball;
const state = @import("./state.zig");
const audio = @import("./audio.zig");

fn rotate(v: Vec2, angle: f32) Vec2 {
    const c = std.math.cos(angle);
    const s = std.math.sin(angle);
    return .{
        .x = v.x * c - v.y * s,
        .y = v.x * s + v.y * c,
    };
}

pub fn spawnExtraBalls(count: usize) std.mem.Allocator.Error!void {
    if (count == 0) return;
    if (state.ball_vel.x == 0 and state.ball_vel.y == 0) return;

    const alloc = std.heap.page_allocator;
    const count_f: f32 = @floatFromInt(count);
    const mid = (count_f - 1.0) * 0.5;

    var i: usize = 0;
    while (i < count) : (i += 1) {
        const idx_f: f32 = @floatFromInt(i);
        const offset = idx_f - mid;
        const angle = offset * 0.32; // ~18 degrees spread between adjacent balls
        const spawned = Ball{
            .pos = state.ball_pos,
            .vel = rotate(state.ball_vel, angle),
        };
        try state.extra_balls.append(alloc, spawned);
    }
}

pub fn nextPos(ball_pos: Vec2, ball_vel: Vec2, dt: f32) Vec2 {
    return .{
        .x = ball_pos.x + ball_vel.x * dt,
        .y = ball_pos.y + ball_vel.y * dt,
    };
}

/// Returns true if the ball is below screen bottom and should be removed.
pub fn resolveWallBounce(ball_vel: *Vec2, ball_size: f32, next_ball_pos: *Vec2) bool {
    const ball_top: f32 = next_ball_pos.y - ball_size;
    const ball_left: f32 = next_ball_pos.x - ball_size;
    const ball_right: f32 = next_ball_pos.x + ball_size;

    // top wall
    if (ball_top <= 0) {
        next_ball_pos.y = ball_size;
        ball_vel.y = -ball_vel.y;
        audio.playWallHit();
    }

    // left / right wall
    const sw = @as(f32, Config.screen_w);
    if (ball_left <= 0) {
        next_ball_pos.x = ball_size;
        ball_vel.x = -ball_vel.x;
        audio.playWallHit();
    } else if (ball_right >= sw) {
        next_ball_pos.x = sw - ball_size;
        ball_vel.x = -ball_vel.x;
        audio.playWallHit();
    }

    return ball_top >= @as(f32, @floatFromInt(Config.screen_h));
}

pub fn handleMainBallLoss(next_ball_pos: *Vec2) void {
    if (state.extra_balls.items.len > 0) {
        const promoted = state.extra_balls.pop().?;
        state.ball_pos = promoted.pos;
        state.ball_vel = promoted.vel;
        next_ball_pos.* = promoted.pos;
        return;
    }

    if (state.lives > 0) {
        state.lives -= 1;
    }
    audio.playLifeLost();

    state.ball_vel = .{ .x = 0, .y = 0 };
    state.ball_pos = Config.ball_start_pos;
    next_ball_pos.* = Config.ball_start_pos;
    state.paddle_pos = Config.paddle_start_pos;
    state.paddle_width = Config.paddle_w;

    state.extra_balls.clearRetainingCapacity();
    state.effects.clearRetainingCapacity();
    state.pickups.clearRetainingCapacity();
}
