const r = @import("raylib");

var paddle_hit: ?r.Sound = null;
var wall_hit: ?r.Sound = null;
var brick_hit: ?r.Sound = null;
var brick_break: ?r.Sound = null;
var life_lost: ?r.Sound = null;
var game_over: ?r.Sound = null;
var restart: ?r.Sound = null;
var powerup_pickup: ?r.Sound = null;

pub fn init() !void {
    paddle_hit = try r.loadSound("assets/audio/sfx/paddle_hit.ogg");
    wall_hit = try r.loadSound("assets/audio/sfx/wall_hit.ogg");
    brick_hit = try r.loadSound("assets/audio/sfx/brick_hit.ogg");
    brick_break = try r.loadSound("assets/audio/sfx/brick_break.ogg");
    life_lost = try r.loadSound("assets/audio/sfx/life_lost.ogg");
    game_over = try r.loadSound("assets/audio/sfx/game_over.ogg");
    restart = try r.loadSound("assets/audio/sfx/restart.ogg");
    powerup_pickup = try r.loadSound("assets/audio/sfx/powerup_pickup.ogg");
}

pub fn deinit() void {
    if (paddle_hit) |s| r.unloadSound(s);
    if (wall_hit) |s| r.unloadSound(s);
    if (brick_hit) |s| r.unloadSound(s);
    if (brick_break) |s| r.unloadSound(s);
    if (life_lost) |s| r.unloadSound(s);
    if (game_over) |s| r.unloadSound(s);
    if (restart) |s| r.unloadSound(s);
    if (powerup_pickup) |s| r.unloadSound(s);

    paddle_hit = null;
    wall_hit = null;
    brick_hit = null;
    brick_break = null;
    life_lost = null;
    game_over = null;
    restart = null;
    powerup_pickup = null;
}

inline fn play(sound: ?r.Sound) void {
    if (sound) |s| r.playSound(s);
}

pub fn playPaddleHit() void {
    play(paddle_hit);
}

pub fn playWallHit() void {
    play(wall_hit);
}

pub fn playBrickHit() void {
    play(brick_hit);
}

pub fn playBrickBreak() void {
    play(brick_break);
}

pub fn playLifeLost() void {
    play(life_lost);
}

pub fn playGameOver() void {
    play(game_over);
}

pub fn playRestart() void {
    play(restart);
}

pub fn playPowerupPickup() void {
    play(powerup_pickup);
}
