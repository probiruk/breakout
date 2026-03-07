const std = @import("std");
const r = @import("raylib");
const Vec2 = @import("./types.zig").Vec2;

// -----------------------------
// Game configuration
// -----------------------------

pub const Config = struct {
    // Window / timing
    pub const screen_w: i32 = 800;
    pub const screen_h: i32 = 600;
    pub const fps: i32 = 60;

    // Paddle
    pub const paddle_w: f32 = 76.0;
    pub const paddle_shrink_w: f32 = 57.0;
    pub const paddle_h: f32 = 13.0;
    pub const paddle_speed: f32 = 400.0; // pixels per second
    pub const paddle_start_pos: Vec2 = .{ .x = Config.screen_w / 2 - Config.paddle_w / 2, .y = @as(f32, 0.9) * @as(f32, Config.screen_h) };

    // Fire mode
    pub const fire_mode = struct {
        // Projectile shape
        pub const shot_w: f32 = 6.0;
        pub const shot_h: f32 = 14.0;
        pub const shot_spawn_inset: f32 = 2.0; // smaller inset -> shots spawn closer to paddle edges

        // Projectile speed (negative means up)
        pub const shot_speed_y: f32 = -220.0;

        // Firing cadence
        pub const shot_interval: f32 = 0.32;
    };

    // Pickup drop chances (relative weights)
    pub const pickup_drop_weights = struct {
        pub const none: u16 = 88; // default to no-drop most of the time
        pub const fire_paddle: u16 = 20;
        pub const expand_paddle: u16 = 5;
        pub const shrink_paddle: u16 = 5;
        pub const slow_ball: u16 = 3;
        pub const fast_ball: u16 = 2;
        pub const multi_ball: u16 = 10;
    };

    // Pickup effect durations in seconds
    pub const pickup_effect_durations = struct {
        pub const fire_paddle: f32 = 6.0;
        pub const expand_paddle: f32 = 5.0;
        pub const shrink_paddle: f32 = 5.0;
        pub const slow_ball: f32 = 5.0;
        pub const fast_ball: f32 = 5.0;
        pub const multi_ball: f32 = 0.0;
    };

    // Pickup movement and size
    pub const pickup = struct {
        pub const fall_speed: f32 = 120.0;
        pub const w: f32 = 54.0;
        pub const h: f32 = 14.0;
    };

    // Ball
    pub const ball_radius: f32 = 6.0;
    pub const ball_min_speed: f32 = 140.0; // lower clamp after speed-modifying effects
    pub const ball_max_speed: f32 = 300.0; // clamp target speed after paddle bounce
    pub const max_bounce_angle: f32 = 65.0 * (std.math.pi / 180.0); // radians
    pub const launch_angle: f32 = 30.0 * (std.math.pi / 180.0); // radians
    pub const ball_start_pos: Vec2 = .{ .x = (screen_w / 2) - (paddle_w / 2), .y = (@as(f32, 0.9) * @as(f32, screen_h) - @as(f32, 10)) };

    // Bricks layout
    pub const side_margin: f32 = 32.0;
    pub const top_margin: f32 = 68.0;
    pub const brick_gap: f32 = 5.0;
    pub const brick_h: f32 = 24.0;

    pub const brick_cols: usize = 10;
    pub const brick_rows: usize = 6;
    pub const brick_count: usize = brick_cols * brick_rows;

    // Row behavior
    pub const row_hp = [_]u8{ 2, 2, 1, 1, 1, 1 };

    pub const mini_bricks = struct {
        pub const rows = [_]usize{3};
        pub const row_h: f32 = 36.0;
        pub const count_per_slot: u8 = 2; // mini bricks inside one normal brick column slot
        pub const gap_factor: f32 = 0.24; // min mini gap = brick_gap * gap_factor (higher => wider)
    };

    pub inline fn isMiniRow(row: usize) bool {
        for (mini_bricks.rows) |mini_row| {
            if (mini_row == row) return true;
        }
        return false;
    }

    pub inline fn hpForRow(row: usize) u8 {
        return if (row < row_hp.len) row_hp[row] else 1;
    }
};

// -----------------------------
// Theme
// -----------------------------

pub const Theme = struct {
    // Backgrounds
    pub const bg_hex: u32 = 0x221D23FF; // dark aubergine

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
