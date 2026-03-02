const std = @import("std");
const Effect = @import("../types.zig").Effect;
const EffectType = @import("../types.zig").EffectType;
const state = @import("./state.zig");
const audio = @import("./audio.zig");
const Brick = @import("../types.zig").Brick;

pub fn hasEffect(etype: EffectType) bool {
    for (state.effects.items) |*eff| {
        if (eff.type == etype) {
            return true;
        }
    }

    return false;
}

pub fn addEffect(effect: Effect) std.mem.Allocator.Error!void {
    const alloc = std.heap.page_allocator;

    for (state.effects.items) |*eff| {
        if (eff.type == effect.type) {
            // Refresh timer while preserving remaining time, then extend.
            const remaining = @max(0.0, eff.duration - eff.time);
            eff.time = 0;
            eff.duration = remaining + effect.duration;
            return;
        }
    }

    try state.effects.append(alloc, effect);
}

pub fn newPotentialEffect(brick: Brick) std.mem.Allocator.Error!void {
    std.debug.print("{}", .{brick});
    // const randInt = std.crypto.random.uintLessThan(u8, 7);

    // if (randInt == 2) {
    //     try addEffect(.{ .type = EffectType.BigBall, .duration = 3.0, .time = 0.0 });
    //     audio.playPowerupPickup();
    // }
    // if (randInt == 3) {
    //     try addEffect(.{ .type = EffectType.FastBall, .duration = 3.0, .time = 0.0 });
    //     audio.playPowerupPickup();
    // }
    if (brick.effect) |effect| {
        try addEffect(effect);
    }
}
