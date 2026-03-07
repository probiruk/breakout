const std = @import("std");
const Config = @import("../config.zig").Config;
const types = @import("../types.zig");
const Vec2 = types.Vec2;
const BrickType = types.BrickType;
const FireShot = types.FireShot;
const state = @import("./state.zig");
const bricks = @import("./bricks.zig");
const pickups = @import("./pickups.zig");
const audio = @import("./audio.zig");

pub fn resolveBrickCollision(
    ball_vel: *Vec2,
    ball_size: f32,
    next_ball_pos: *Vec2,
) std.mem.Allocator.Error!void {
    const ball_top: f32 = next_ball_pos.y - ball_size;
    const ball_bottom: f32 = next_ball_pos.y + ball_size;
    const ball_left: f32 = next_ball_pos.x - ball_size;
    const ball_right: f32 = next_ball_pos.x + ball_size;

    for (state.bricks, 0..) |brick, i| {
        if (brick.hp == 0) continue;
        const col: usize = i % Config.brick_cols;
        var brick_top: f32 = brick.y;
        var brick_bottom: f32 = brick.y + brick.h;
        var brick_left: f32 = brick.x;
        var brick_right: f32 = brick.x + brick.w;
        if (brick.type == BrickType.Mini) {
            const mini_layout = bricks.getMiniRowLayout(brick);
            const base_idx = col * mini_layout.count_per_brick;
            const left_idx_f: f32 = @floatFromInt(base_idx);
            const right_idx_f: f32 = @floatFromInt(base_idx + mini_layout.count_per_brick - 1);
            brick_left = mini_layout.start_x + left_idx_f * (mini_layout.side + mini_layout.gap);
            brick_right = mini_layout.start_x + right_idx_f * (mini_layout.side + mini_layout.gap) + mini_layout.side;
            brick_top = mini_layout.start_y;
            brick_bottom = mini_layout.start_y + mini_layout.side;
        }

        const ball_below_brick_top = ball_bottom >= brick_top;
        const ball_above_brick_bottom = ball_top <= brick_bottom;
        const ball_right_past_brick_left = ball_right >= brick_left;
        const ball_left_before_brick_right = ball_left <= brick_right;

        if (ball_below_brick_top and
            ball_above_brick_bottom and
            ball_right_past_brick_left and
            ball_left_before_brick_right)
        {
            if (brick.type == BrickType.Mini) {
                const mini_layout = bricks.getMiniRowLayout(brick);
                const base_idx = col * mini_layout.count_per_brick;
                var hit_mini = false;
                var j: usize = 0;
                while (j < mini_layout.count_per_brick) : (j += 1) {
                    const bit_shift: u3 = @intCast(j);
                    const bit = @as(u8, 1) << bit_shift;
                    if ((state.bricks[i].mini_mask & bit) == 0) continue;

                    const global_idx = base_idx + j;
                    const idx_f: f32 = @floatFromInt(global_idx);
                    const mini_left = mini_layout.start_x + idx_f * (mini_layout.side + mini_layout.gap);
                    const mini_right = mini_left + mini_layout.side;
                    const mini_top = mini_layout.start_y;
                    const mini_bottom = mini_top + mini_layout.side;
                    const overlaps_mini = ball_bottom >= mini_top and
                        ball_top <= mini_bottom and
                        ball_right >= mini_left and
                        ball_left <= mini_right;
                    if (!overlaps_mini) continue;

                    state.bricks[i].mini_mask &= ~bit;
                    state.bricks[i].hp -= 1;
                    hit_mini = true;
                    break;
                }

                if (!hit_mini) continue;
            } else {
                state.bricks[i].hp -= 1;
            }

            if (state.bricks[i].hp == 0) {
                audio.playBrickBreak();
            } else {
                audio.playBrickHit();
            }

            state.score += 1;
            if (state.bricks[i].hp == 0) {
                try pickups.spawnFromBrick(brick);
            }

            const overlap_x = @min(ball_right - brick_left, brick_right - ball_left);
            const overlap_y = @min(ball_bottom - brick_top, brick_bottom - ball_top);

            const brick_cx = (brick_left + brick_right) * 0.5;
            const brick_cy = (brick_top + brick_bottom) * 0.5;

            if (overlap_x < overlap_y) {
                ball_vel.x = -ball_vel.x;
                next_ball_pos.x += if (next_ball_pos.x < brick_cx) -overlap_x else overlap_x;
            } else {
                ball_vel.y = -ball_vel.y;
                next_ball_pos.y += if (next_ball_pos.y < brick_cy) -overlap_y else overlap_y;
            }
            break;
        }
    }
}

pub fn resolveFireShotCollision(shot: *FireShot) std.mem.Allocator.Error!bool {
    const shot_top: f32 = shot.y;
    const shot_bottom: f32 = shot.y + shot.h;
    const shot_left: f32 = shot.x;
    const shot_right: f32 = shot.x + shot.w;

    for (state.bricks, 0..) |brick, i| {
        if (brick.hp == 0) continue;
        const col: usize = i % Config.brick_cols;
        var brick_top: f32 = brick.y;
        var brick_bottom: f32 = brick.y + brick.h;
        var brick_left: f32 = brick.x;
        var brick_right: f32 = brick.x + brick.w;
        if (brick.type == BrickType.Mini) {
            const mini_layout = bricks.getMiniRowLayout(brick);
            const base_idx = col * mini_layout.count_per_brick;
            const left_idx_f: f32 = @floatFromInt(base_idx);
            const right_idx_f: f32 = @floatFromInt(base_idx + mini_layout.count_per_brick - 1);
            brick_left = mini_layout.start_x + left_idx_f * (mini_layout.side + mini_layout.gap);
            brick_right = mini_layout.start_x + right_idx_f * (mini_layout.side + mini_layout.gap) + mini_layout.side;
            brick_top = mini_layout.start_y;
            brick_bottom = mini_layout.start_y + mini_layout.side;
        }

        const overlaps = shot_bottom >= brick_top and
            shot_top <= brick_bottom and
            shot_right >= brick_left and
            shot_left <= brick_right;

        if (!overlaps) continue;

        if (brick.type == BrickType.Mini) {
            const mini_layout = bricks.getMiniRowLayout(brick);
            const base_idx = col * mini_layout.count_per_brick;
            var hit_mini = false;
            var j: usize = 0;
            while (j < mini_layout.count_per_brick) : (j += 1) {
                const bit_shift: u3 = @intCast(j);
                const bit = @as(u8, 1) << bit_shift;
                if ((state.bricks[i].mini_mask & bit) == 0) continue;

                const global_idx = base_idx + j;
                const idx_f: f32 = @floatFromInt(global_idx);
                const mini_left = mini_layout.start_x + idx_f * (mini_layout.side + mini_layout.gap);
                const mini_right = mini_left + mini_layout.side;
                const mini_top = mini_layout.start_y;
                const mini_bottom = mini_top + mini_layout.side;
                const overlaps_mini = shot_bottom >= mini_top and
                    shot_top <= mini_bottom and
                    shot_right >= mini_left and
                    shot_left <= mini_right;
                if (!overlaps_mini) continue;

                state.bricks[i].mini_mask &= ~bit;
                state.bricks[i].hp -= 1;
                hit_mini = true;
                break;
            }

            if (!hit_mini) continue;
        } else {
            state.bricks[i].hp -= 1;
        }

        if (state.bricks[i].hp == 0) {
            audio.playBrickBreak();
        } else {
            audio.playBrickHit();
        }

        state.score += 1;
        if (state.bricks[i].hp == 0) {
            try pickups.spawnFromBrick(brick);
        }
        return true;
    }

    return false;
}
