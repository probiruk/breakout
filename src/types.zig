pub const Vec2 = struct { x: f32, y: f32 };

pub const Brick = struct { x: f32, y: f32, w: f32, h: f32, hp: u8, max_hp: u8 };

pub const EffectType = enum { BigBall, FastBall };

pub const Effect = struct { type: EffectType, duration: f32, time: f32 };
