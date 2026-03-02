const std = @import("std");
const Vec2 = @import("../types.zig").Vec2;
const Brick = @import("../types.zig").Brick;
const Config = @import("../config.zig").Config;
const Effect = @import("../types.zig").Effect;
const Pickup = @import("../types.zig").Pickup;

pub var paddle_pos: Vec2 = Config.paddle_start_pos;

pub var ball_pos: Vec2 = Config.ball_start_pos;
pub var ball_vel: Vec2 = .{
    .x = 0,
    .y = 0,
};
pub var ball_size: f32 = Config.ball_radius;

pub var bricks: [Config.brick_count]Brick = undefined;

// pub const paddle_state: PaddleState = .Normal;

pub var paddle_width: f32 = Config.paddle_w;

pub var effects: std.ArrayList(Effect) = .{};
pub var pickups: std.ArrayList(Pickup) = .{};

pub var score: u32 = 0;

pub var lives: u8 = 3;
