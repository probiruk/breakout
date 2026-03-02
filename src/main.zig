const std = @import("std");
const r = @import("raylib");
const Config = @import("./config.zig").Config;
const game = @import("./game/mod.zig");
const state = @import("./game/state.zig");

fn restartGame() void {
    state.score = 0;
    state.lives = 3;
    state.paddle_pos = Config.paddle_start_pos;
    state.paddle_width = Config.paddle_w;
    state.ball_pos = Config.ball_start_pos;
    state.ball_vel = .{ .x = 0, .y = 0 };
    state.ball_size = Config.ball_radius;
    state.effects.clearRetainingCapacity();
    state.pickups.clearRetainingCapacity();
    game.bricks.initBricks();
}

pub fn main() !void {
    r.initWindow(Config.screen_w, Config.screen_h, "Breakout");
    defer r.closeWindow();
    if (!r.isWindowReady()) {
        std.log.err("Failed to initialize window/OpenGL context. Check X11/GLX setup.", .{});
        return;
    }

    r.setTargetFPS(Config.fps);
    r.initAudioDevice();
    defer r.closeAudioDevice();

    try game.audio.init();
    defer game.audio.deinit();

    try game.render.initAssets();
    defer game.render.deinitAssets();

    game.bricks.initBricks();
    var was_game_over = false;

    while (!r.windowShouldClose()) {
        const dt: f32 = r.getFrameTime();
        const is_game_over = state.lives == 0;

        if (is_game_over and !was_game_over) {
            game.audio.playGameOver();
        }

        if (is_game_over) {
            if (r.isKeyPressed(.r)) {
                game.audio.playRestart();
                restartGame();
            }
        } else {
            game.input.updatePaddle(dt);
            try game.update.step(dt);
        }
        game.render.draw();
        was_game_over = is_game_over;
    }
}
