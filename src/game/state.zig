const Vec2 = @import("../types.zig").Vec2;
const Brick = @import("../types.zig").Brick;
const Config = @import("../config.zig").Config;

pub var paddle_pos: Vec2 = .{ .x = 350.0, .y = 400.0 };

pub var ball_pos: Vec2 = .{ .x = 375.0, .y = 392.0 };
pub var ball_vel: Vec2 = .{
    .x = @sin(Config.launch_angle) * Config.ball_max_speed,
    .y = -@cos(Config.launch_angle) * Config.ball_max_speed,
};

pub var bricks: [Config.brick_count]Brick = undefined;

pub var score: u32 = 0;
