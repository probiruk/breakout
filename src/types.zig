pub const Vec2 = struct { x: f32, y: f32 };

pub const Brick = struct { x: f32, y: f32, w: f32, h: f32, hp: u8, max_hp: u8, effect: ?Effect };

pub const EffectType = enum { BigBall, FastBall, ExpandPaddle };

pub const Effect = struct { type: EffectType, duration: f32, time: f32 = 0 };

pub const Pickup = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    vy: f32,
    effect: Effect,
};
