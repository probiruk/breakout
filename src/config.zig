const std = @import("std");
const r = @import("raylib");

// -----------------------------
// Game configuration
// -----------------------------

pub const Config = struct {
    // Window / timing
    pub const screen_w: i32 = 800;
    pub const screen_h: i32 = 450;
    pub const fps: i32 = 60;

    // Paddle
    pub const paddle_w: f32 = 70.0;
    pub const paddle_h: f32 = 5.0;
    pub const paddle_speed: f32 = 400.0; // pixels per second

    // Ball
    pub const ball_radius: f32 = 6.5;
    pub const ball_max_speed: f32 = 300.0; // clamp target speed after paddle bounce
    pub const max_bounce_angle: f32 = 65.0 * (std.math.pi / 180.0); // radians
    pub const launch_angle: f32 = 30.0 * (std.math.pi / 180.0); // radians

    // Bricks layout
    pub const side_margin: f32 = 30.0;
    pub const top_margin: f32 = 60.0;
    pub const brick_gap: f32 = 6.0;
    pub const brick_h: f32 = 18.0;

    pub const brick_cols: usize = 10;
    pub const brick_rows: usize = 6;
    pub const brick_count: usize = brick_cols * brick_rows;
};

// -----------------------------
// Theme
// -----------------------------

pub const Theme = struct {
    // Backgrounds
    pub const bg_hex: u32 = 0x000000FF; // pure black

    // Player objects
    pub const paddle_hex: u32 = 0xFFFFFFFF; // white paddle
    pub const ball_hex: u32 = 0xFFFFFFFF; // white ball

    pub const brick0_hex: u32 = 0xFF0000FF; // red
    pub const brick1_hex: u32 = 0xFF7F00FF; // orange
    pub const brick2_hex: u32 = 0xFFFF00FF; // yellow
    pub const brick3_hex: u32 = 0x00FF00FF; // green
    pub const brick4_hex: u32 = 0x00FF00FF; // green (repeat for band effect)
    pub const brick5_hex: u32 = 0xFFFF00FF; // yellow (repeat for band effect)

    // Convert hex RGBA (0xRRGGBBAA) to raylib Color at runtime
    pub inline fn col(hex: u32) r.Color {
        return r.getColor(hex);
    }
};
