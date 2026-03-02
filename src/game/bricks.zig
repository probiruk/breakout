const Config = @import("../config.zig").Config;
const state = @import("./state.zig");
const EffectType = @import("../types.zig").EffectType;

pub fn initBricks() void {
    const sw: f32 = @as(f32, Config.screen_w);
    const play_w: f32 = sw - (2.0 * Config.side_margin);

    const cols_f: f32 = @as(f32, @floatFromInt(Config.brick_cols));
    const gaps_f: f32 = @as(f32, @floatFromInt(Config.brick_cols - 1)); // gaps between bricks in one row (N-1)

    const total_gaps: f32 = Config.brick_gap * gaps_f; // total horizontal gap space per row
    const brick_w: f32 = (play_w - total_gaps) / cols_f; // single block width

    var i: usize = 0;
    var row: usize = 0;
    while (row < Config.brick_rows) : (row += 1) {
        var col: usize = 0;

        while (col < Config.brick_cols) : (col += 1) {
            const col_f: f32 = @as(f32, @floatFromInt(col));
            const row_f: f32 = @as(f32, @floatFromInt(row));

            const x: f32 = Config.side_margin + col_f * (brick_w + Config.brick_gap); // left edge: start at margin, step right by (brick+gap) per column
            const y: f32 = Config.top_margin + row_f * (Config.brick_h + Config.brick_gap); // top edge: start at top margin, step down by (brick+gap) per row

            const max_hp: u8 = if (row <= 1) 2 else 1;
            state.bricks[i] = .{ .x = x, .y = y, .w = brick_w, .h = Config.brick_h, .hp = max_hp, .max_hp = max_hp, .effect = .{ .type = EffectType.ExpandPaddle, .duration = 5.0 } };
            i += 1;
        }
    }
}
