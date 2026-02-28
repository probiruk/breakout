const std = @import("std");
const r = @import("raylib");

// -----------------------------
// Game configuration
// -----------------------------
const Config = struct {
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
    pub const ball_max_speed: f32 = 220.0; // clamp target speed after paddle bounce
    pub const max_bounce_angle: f32 = 50.0 * (std.math.pi / 180.0); // radians
    pub const launch_angle: f32 = 25.0 * (std.math.pi / 180.0); // radians

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
const Theme = struct {
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

// -----------------------------
// Types
// -----------------------------

const Vec2 = struct { x: f32, y: f32 };

const Brick = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    alive: bool,
};

// -----------------------------
// Game state (changes at runtime)
// -----------------------------

var paddle_pos: Vec2 = .{ .x = 350.0, .y = 400.0 };

var ball_pos: Vec2 = .{ .x = 375.0, .y = 392.0 };
var ball_vel: Vec2 = .{
    .x = @sin(Config.launch_angle) * Config.ball_max_speed,
    .y = -@cos(Config.launch_angle) * Config.ball_max_speed,
};

var bricks: [Config.brick_count]Brick = undefined;

pub fn main() void {
    r.initWindow(Config.screen_w, Config.screen_h, "Breakout");
    defer r.closeWindow();

    r.setTargetFPS(Config.fps);

    initBricks();

    while (!r.windowShouldClose()) {
        const dt: f32 = r.getFrameTime();

        // paddle movement
        var dir: f32 = 0.0;
        if (r.isKeyDown(.right)) dir += 1.0;
        if (r.isKeyDown(.left)) dir -= 1.0;

        // Move in pixels/second * seconds = pixels this frame
        const delta = dir * Config.paddle_speed * dt;
        const next_x = paddle_pos.x + delta;

        if (next_x > 0 and next_x < @as(f32, Config.screen_w - Config.paddle_w)) {
            paddle_pos.x = next_x; // keep paddle inside screen bounds
        }

        const pw: f32 = @as(f32, Config.paddle_w);
        const ph: f32 = @as(f32, Config.paddle_h);

        const paddle_left: f32 = paddle_pos.x;
        const paddle_right: f32 = paddle_pos.x + pw;
        const paddle_top: f32 = paddle_pos.y;
        const paddle_bottom: f32 = paddle_pos.y + ph;

        // bounce

        // top wall
        if (ball_pos.y - Config.ball_radius <= 0) {
            ball_pos.y = Config.ball_radius;
            ball_vel.y = -ball_vel.y;
        }

        // left / right wall
        const sw = @as(f32, Config.screen_w);

        if (ball_pos.x - Config.ball_radius <= 0) {
            ball_pos.x = Config.ball_radius;
            ball_vel.x = -ball_vel.x;
        } else if (ball_pos.x + Config.ball_radius >= sw) {
            ball_pos.x = sw - Config.ball_radius;
            ball_vel.x = -ball_vel.x;
        }

        // paddle collision
        const paddle_center_x: f32 = paddle_left + (pw * 0.5);

        // Paddle collision: only bounce when the ball is moving downward
        const ball_moving_down = ball_vel.y > 0;

        // Circle vs paddle AABB overlap checks
        const ball_below_top = (ball_pos.y + Config.ball_radius) >= paddle_top; // ball's bottom passed paddle top
        const ball_right_of_left = (ball_pos.x + Config.ball_radius) >= paddle_left; // ball's right passed paddle left edge
        const ball_left_of_right = (ball_pos.x - Config.ball_radius) <= paddle_right; // ball's left passed paddle right edge
        const ball_above_bottom = ball_pos.y <= paddle_bottom; // ball center not below paddle bottom

        if (ball_moving_down and
            ball_below_top and
            ball_right_of_left and
            ball_left_of_right and
            ball_above_bottom)
        {
            ball_pos.y = paddle_top - Config.ball_radius;

            // keep hit in [-1, 1]
            var hit: f32 = (ball_pos.x - paddle_center_x) / (pw * 0.5);
            if (hit < -1) hit = -1;
            if (hit > 1) hit = 1;

            // map hit position [-1..1] to bounce angle [-max_angle..max_angle]
            const angle: f32 = hit * Config.max_bounce_angle;

            ball_vel.x = @sin(angle) * Config.ball_max_speed;
            ball_vel.y = -@cos(angle) * Config.ball_max_speed;
        }

        // TODO: brick collision (AABB vs circle) and mark bricks[i].alive = fa

        // ball
        ball_pos.x += ball_vel.x * dt;
        ball_pos.y += ball_vel.y * dt;

        // draw

        r.beginDrawing();
        defer r.endDrawing();

        r.clearBackground(Theme.col(Theme.bg_hex));

        r.drawRectangle(
            @intFromFloat(paddle_pos.x),
            @intFromFloat(paddle_pos.y),
            @intFromFloat(Config.paddle_w),
            @intFromFloat(Config.paddle_h),
            Theme.col(Theme.paddle_hex),
        );

        r.drawCircle(
            @intFromFloat(ball_pos.x),
            @intFromFloat(ball_pos.y),
            Config.ball_radius,
            Theme.col(Theme.ball_hex),
        );

        for (bricks, 0..) |b, i| {
            if (!b.alive) continue;

            const row: usize = i / Config.brick_cols;

            const color = switch (row) {
                0 => Theme.col(Theme.brick0_hex),
                1 => Theme.col(Theme.brick1_hex),
                2 => Theme.col(Theme.brick2_hex),
                3 => Theme.col(Theme.brick3_hex),
                4 => Theme.col(Theme.brick4_hex),
                else => Theme.col(Theme.brick5_hex),
            };

            r.drawRectangle(
                @intFromFloat(b.x),
                @intFromFloat(b.y),
                @intFromFloat(b.w),
                @intFromFloat(b.h),
                color,
            );
        }
    }
}

fn initBricks() void {
    const sw: f32 = @as(f32, Config.screen_w);
    const play_w: f32 = sw - (2.0 * Config.side_margin);

    const cols_f: f32 = @as(f32, @floatFromInt(Config.brick_cols));
    const gaps_f: f32 = @as(f32, @floatFromInt(Config.brick_cols - 1)); // gaps between bricks in one row (N-1)

    const total_gaps: f32 = Config.brick_gap * gaps_f; // total horizontal gap space per row
    const brick_w: f32 = (play_w - total_gaps) / cols_f; // single block width

    var i: usize = 0;
    var row: usize = 0;
    while (row < Config.brick_rows) : (row += 1) {
        var col: usize = 0;

        while (col < Config.brick_cols) : (col += 1) {
            const col_f: f32 = @as(f32, @floatFromInt(col));
            const row_f: f32 = @as(f32, @floatFromInt(row));

            const x: f32 = Config.side_margin + col_f * (brick_w + Config.brick_gap); // left edge: start at margin, step right by (brick+gap) per column
            const y: f32 = Config.top_margin + row_f * (Config.brick_h + Config.brick_gap); // top edge: start at top margin, step down by (brick+gap) per row

            bricks[i] = .{ .x = x, .y = y, .w = brick_w, .h = Config.brick_h, .alive = true };
            i += 1;
        }
    }
}
