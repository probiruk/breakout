const std = @import("std");
const Vec2 = @import("../types.zig").Vec2;
const Ball = @import("../types.zig").Ball;
const Brick = @import("../types.zig").Brick;
const Config = @import("../config.zig").Config;
const Effect = @import("../types.zig").Effect;
const FireShot = @import("../types.zig").FireShot;
const Pickup = @import("../types.zig").Pickup;

pub var paddle_pos: Vec2 = Config.paddle_start_pos;

pub var ball_pos: Vec2 = Config.ball_start_pos;
pub var ball_vel: Vec2 = .{
    .x = 0,
    .y = 0,
};
pub var ball_size: f32 = Config.ball_radius;
pub var extra_balls: std.ArrayList(Ball) = .{};

pub var bricks: std.ArrayList(Brick) = .{};

// pub const paddle_state: PaddleState = .Normal;

pub var paddle_width: f32 = Config.paddle_w;

pub var effects: std.ArrayList(Effect) = .{};
pub var pickups: std.ArrayList(Pickup) = .{};
pub var fire_shots: std.ArrayList(FireShot) = .{};
pub var fire_shot_cooldown: f32 = 0.0;
pub var fire_mode_was_active: bool = false;
pub var row_inject_timer: f32 = 0.0;
pub var row_shift_remaining: f32 = 0.0;
pub var survival_time: f32 = 0.0;

pub var score: u32 = 0;

pub var lives: u8 = 3;
