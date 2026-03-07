pub const Vec2 = struct { x: f32, y: f32 };

pub const Ball = struct {
    pos: Vec2,
    vel: Vec2,
};

pub const Brick = struct {
    type: BrickType,
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    hp: u8,
    max_hp: u8,
    mini_count: u8 = 0, // number of mini tiles represented by this brick slot
    mini_mask: u8 = 0, // alive mini tiles bitset (1 = alive, 0 = broken)
    effect_mask: u8 = 0, // bitset of allowed pickup effects for this brick
};

pub const BrickType = enum { Normal, Mini };

pub const EffectType = enum { MultiBall, FastBall, SlowBall, ExpandPaddle, ShrinkPaddle, FirePaddle };

pub const Effect = struct { type: EffectType, duration: f32, time: f32 = 0 };

pub const Pickup = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    vy: f32,
    effect: Effect,
};

pub const FireShot = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    vy: f32,
};
