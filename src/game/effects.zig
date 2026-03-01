const std = @import("std");
const Effect = @import("../types.zig").Effect;
const EffectType = @import("../types.zig").EffectType;

pub fn hasEffect(list: *std.ArrayList(Effect), etype: EffectType) bool {
    for (list.items) |*eff| {
        if (eff.type == etype) {
            return true;
        }
    }

    return false;
}

pub fn addEffect(list: *std.ArrayList(Effect), effect: Effect) std.mem.Allocator.Error!void {
    const alloc = std.heap.page_allocator;

    for (list.items) |*eff| {
        if (eff.type == effect.type) {
            eff.duration += effect.duration;
            return;
        }
    }

    try list.append(alloc, effect);
}

pub fn newPotentialEffect(list: *std.ArrayList(Effect)) std.mem.Allocator.Error!void {
    const randInt = std.crypto.random.uintLessThan(u8, 7);

    if (randInt == 2) {
        try addEffect(list, .{ .type = EffectType.BigBall, .duration = 3.0, .time = 0.0 });
    }
    if (randInt == 3) {
        try addEffect(list, .{ .type = EffectType.FastBall, .duration = 3.0, .time = 0.0 });
    }
}
