const std = @import("std");
const r = @import("raylib");
const Config = @import("./config.zig").Config;
const Effect = @import("./types.zig").Effect;
const game = @import("./game/mod.zig");

pub fn main() std.mem.Allocator.Error!void {
    r.initWindow(Config.screen_w, Config.screen_h, "Breakout");
    defer r.closeWindow();
    if (!r.isWindowReady()) {
        std.log.err("Failed to initialize window/OpenGL context. Check X11/GLX setup.", .{});
        return;
    }

    r.setTargetFPS(Config.fps);

    game.bricks.initBricks();

    var effects: std.ArrayList(Effect) = .{};

    while (!r.windowShouldClose()) {
        const dt: f32 = r.getFrameTime();
        game.input.updatePaddle(dt);
        const ball_size = try game.update.step(dt, &effects);
        game.render.draw(ball_size);
    }
}
