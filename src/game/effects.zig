const std = @import("std");
const Effect = @import("../types.zig").Effect;
const EffectType = @import("../types.zig").EffectType;
const state = @import("./state.zig");
const ball = @import("./ball.zig");

pub fn effectBit(etype: EffectType) u8 {
    const shift: u3 = @intCast(@intFromEnum(etype));
    return @as(u8, 1) << shift;
}

pub const all_effect_mask: u8 = effectBit(.MultiBall) |
    effectBit(.FastBall) |
    effectBit(.SlowBall) |
    effectBit(.ExpandPaddle) |
    effectBit(.FirePaddle);

pub fn hasEffect(etype: EffectType) bool {
    for (state.effects.items) |*eff| {
        if (eff.type == etype) {
            return true;
        }
    }

    return false;
}

pub fn addEffect(effect: Effect) std.mem.Allocator.Error!void {
    if (effect.type == .MultiBall) {
        try ball.spawnExtraBalls(2);
        return;
    }

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
