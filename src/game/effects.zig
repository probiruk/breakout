const std = @import("std");
const Effect = @import("../types.zig").Effect;
const EffectType = @import("../types.zig").EffectType;
const state = @import("./state.zig");

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
            eff.duration += effect.duration;
            return;
        }
    }

    try state.effects.append(alloc, effect);
}

pub fn newPotentialEffect() std.mem.Allocator.Error!void {
    const randInt = std.crypto.random.uintLessThan(u8, 7);

    if (randInt == 2) {
        try addEffect(.{ .type = EffectType.BigBall, .duration = 3.0, .time = 0.0 });
    }
    if (randInt == 3) {
        try addEffect(.{ .type = EffectType.FastBall, .duration = 3.0, .time = 0.0 });
    }
}
