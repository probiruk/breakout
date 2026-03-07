const std = @import("std");
const Config = @import("../config.zig").Config;
const Brick = @import("../types.zig").Brick;
const Effect = @import("../types.zig").Effect;
const EffectType = @import("../types.zig").EffectType;
const Pickup = @import("../types.zig").Pickup;
const state = @import("./state.zig");
const effects = @import("./effects.zig");
const audio = @import("./audio.zig");

const pickup_fall_speed: f32 = 120.0;
const pickup_w: f32 = 54.0;
const pickup_h: f32 = 14.0;

const none_weight: u16 = 88; // default to no-drop most of the time
const effect_drop_table = [_]struct {
    etype: EffectType,
    duration: f32,
    weight: u16,
}{
    .{ .etype = .ExpandPaddle, .duration = 5.0, .weight = 5 },
    .{ .etype = .SlowBall, .duration = 5.0, .weight = 3 },
    .{ .etype = .FastBall, .duration = 5.0, .weight = 2 },
    .{ .etype = .MultiBall, .duration = 0.0, .weight = 10 },
};

fn chooseDropEffect(effect_mask: u8) ?Effect {
    var total_weight: u16 = none_weight;
    for (effect_drop_table) |entry| {
        if ((effect_mask & effects.effectBit(entry.etype)) == 0) continue;
        total_weight += entry.weight;
    }

    if (total_weight == none_weight) return null;

    const roll = std.crypto.random.uintLessThan(u16, total_weight);
    if (roll < none_weight) return null;

    var running: u16 = none_weight;
    for (effect_drop_table) |entry| {
        if ((effect_mask & effects.effectBit(entry.etype)) == 0) continue;
        running += entry.weight;
        if (roll < running) {
            return .{ .type = entry.etype, .duration = entry.duration };
        }
    }

    return null;
}

pub fn spawnFromBrick(brick: Brick) std.mem.Allocator.Error!void {
    const effect = chooseDropEffect(brick.effect_mask) orelse return;
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
