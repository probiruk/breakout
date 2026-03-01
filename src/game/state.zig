const std = @import("std");
const Vec2 = @import("../types.zig").Vec2;
const Brick = @import("../types.zig").Brick;
const Config = @import("../config.zig").Config;
const Effect = @import("../types.zig").Effect;

pub var paddle_pos: Vec2 = Config.paddle_start_pos;

pub var ball_pos: Vec2 = Config.ball_start_pos;
pub var ball_vel: Vec2 = .{
    .x = 0,
    .y = 0,
};
pub var ball_size: f32 = Config.ball_radius;

pub var bricks: [Config.brick_count]Brick = undefined;

pub var effects: std.ArrayList(Effect) = .{};

pub var score: u32 = 0;

pub var lives: u8 = 3;
