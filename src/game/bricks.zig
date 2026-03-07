const Config = @import("../config.zig").Config;
const state = @import("./state.zig");
const Brick = @import("../types.zig").Brick;
const BrickType = @import("../types.zig").BrickType;
const effects = @import("./effects.zig");

/// Build an all-alive mini bitmask for count tiles.
fn fullMiniMask(count: u8) u8 {
    if (count == 0) return 0;
    if (count >= 8) return 0xFF;
    const shift: u3 = @intCast(count);
    return (@as(u8, 1) << shift) - 1;
}

/// Returns mini row layout values: tiles per slot, tile size, tile gap, and row start.
/// Mini row spans exactly from `side_margin` to `screen_w - side_margin`.
/// Mini tiles are vertically centered inside the mini row height.
pub fn getMiniRowLayout(brick: Brick) struct {
    count_per_brick: usize,
    side: f32,
    gap: f32,
    start_x: f32,
    start_y: f32,
} {
    const count_per_brick: usize = @max(1, @as(usize, brick.mini_count));
    const total_count: usize = Config.brick_cols * count_per_brick;
    const play_w: f32 = @as(f32, Config.screen_w) - (2.0 * Config.side_margin);
    const total_count_f: f32 = @floatFromInt(total_count);
    const gaps_f: f32 = @floatFromInt(total_count - 1);
    const min_gap: f32 = Config.brick_gap * Config.mini_bricks.gap_factor;
    const side: f32 = @min(brick.h, (play_w - (gaps_f * min_gap)) / total_count_f);
    const gap: f32 = (play_w - (total_count_f * side)) / gaps_f;
    const start_x: f32 = Config.side_margin; // lock mini row edges to normal grid edges
    const start_y: f32 = brick.y + (brick.h - side) * 0.5; // center minis vertically in mini row
    return .{
        .count_per_brick = count_per_brick,
        .side = side,
        .gap = gap,
        .start_x = start_x,
        .start_y = start_y,
    };
}

pub fn initBricks() void {
    const sw: f32 = @as(f32, Config.screen_w);
    const play_w: f32 = sw - (2.0 * Config.side_margin);

    const cols_f: f32 = @as(f32, @floatFromInt(Config.brick_cols));
    const gaps_f: f32 = @as(f32, @floatFromInt(Config.brick_cols - 1)); // gaps between bricks in one row (N-1)

    const total_gaps: f32 = Config.brick_gap * gaps_f; // total horizontal gap space per row
    const brick_w: f32 = (play_w - total_gaps) / cols_f; // single block width

    var i: usize = 0;
    var row: usize = 0;
    var row_y: f32 = Config.top_margin;
    while (row < Config.brick_rows) : (row += 1) {
        const is_mini_row = Config.isMiniRow(row);
        const row_h: f32 = if (is_mini_row) Config.mini_bricks.row_h else Config.brick_h;
        var col: usize = 0;

        while (col < Config.brick_cols) : (col += 1) {
            const col_f: f32 = @as(f32, @floatFromInt(col));
            const x: f32 = Config.side_margin + col_f * (brick_w + Config.brick_gap);
            const y: f32 = row_y;

            const is_mini = is_mini_row;
            const brick_type: BrickType = if (is_mini) .Mini else .Normal;
            const mini_count: u8 = if (is_mini) Config.mini_bricks.count_per_slot else 0;
            const max_hp: u8 = if (is_mini) mini_count else Config.hpForRow(row);
            const mini_mask: u8 = fullMiniMask(mini_count);

            state.bricks[i] = .{
                .type = brick_type,
                .x = x,
                .y = y,
                .w = brick_w,
                .h = row_h,
                .hp = max_hp,
                .max_hp = max_hp,
                .mini_count = mini_count,
                .mini_mask = mini_mask,
                .effect_mask = effects.all_effect_mask,
            };
            i += 1;
        }
        row_y += row_h + Config.brick_gap;
    }
}
