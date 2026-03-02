const std = @import("std");
const Config = @import("../config.zig").Config;
const Brick = @import("../types.zig").Brick;
const Pickup = @import("../types.zig").Pickup;
const state = @import("./state.zig");
const effects = @import("./effects.zig");
const audio = @import("./audio.zig");

const drop_chance_percent: u8 = 20;
const pickup_fall_speed: f32 = 120.0;
const pickup_w: f32 = 54.0;
const pickup_h: f32 = 14.0;

pub fn spawnFromBrick(brick: Brick) std.mem.Allocator.Error!void {
    if (brick.effect == null) return;

    const roll = std.crypto.random.uintLessThan(u8, 100);
    if (roll >= drop_chance_percent) return;

    const effect = brick.effect.?;
    const pickup = Pickup{
        .x = brick.x + (brick.w - pickup_w) * 0.5,
        .y = brick.y + (brick.h - pickup_h) * 0.5,
        .w = pickup_w,
        .h = pickup_h,
        .vy = pickup_fall_speed,
        .effect = effect,
    };
    try state.pickups.append(std.heap.page_allocator, pickup);
}

pub fn update(dt: f32) std.mem.Allocator.Error!void {
    var i: usize = 0;
    while (i < state.pickups.items.len) {
        var pickup = state.pickups.items[i];
        pickup.y += pickup.vy * dt;

        if (pickup.y > @as(f32, @floatFromInt(Config.screen_h))) {
            _ = state.pickups.orderedRemove(i);
            continue;
        }

        const paddle_left = state.paddle_pos.x;
        const paddle_top = state.paddle_pos.y;
        const paddle_right = paddle_left + state.paddle_width;
        const paddle_bottom = paddle_top + Config.paddle_h;

        const pickup_left = pickup.x;
        const pickup_top = pickup.y;
        const pickup_right = pickup_left + pickup.w;
        const pickup_bottom = pickup_top + pickup.h;

        const overlaps = pickup_right >= paddle_left and
            pickup_left <= paddle_right and
            pickup_bottom >= paddle_top and
            pickup_top <= paddle_bottom;

        if (overlaps) {
            try effects.addEffect(pickup.effect);
            audio.playPowerupPickup();
            _ = state.pickups.orderedRemove(i);
            continue;
        }

        state.pickups.items[i] = pickup;
        i += 1;
    }
}
