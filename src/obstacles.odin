package main

import "core:c"
import "core:fmt"

import rl "vendor:raylib"

score : uint = 0

OBSTACLE_WIDTH :: 100
OBSTACLE_HEIGHT :: 600
OBSTACLE_SIZE :: rl.Vector2 { OBSTACLE_WIDTH, OBSTACLE_HEIGHT }

OBSTACLE_SPAWN_COOLDOWN :: 1.5
OBSTACLE_SPEED :: 300
OBSTACLE_VERTICAL_SPACING :: 140

OBSTACLE_MAIN_COLOR :: rl.Color { 28, 27, 26, 255 }
OBSTACLE_SYMBOL_COUNT :: 4

// Linmits in percentage of the screen size of the position in the y  axis of an obstacle
OBSTACLE_MAX_Y_PERCENT :: 77
OBSTACLE_MIN_Y_PERCENT :: 25

ObstacleSymbolGroup :: distinct [OBSTACLE_SYMBOL_COUNT]asset_id

ObstacleColumn :: struct
{
    active: bool,
    player_inscore: bool,
    middle: rl.Vector2,
    
    upper_syms: ObstacleSymbolGroup,
    lower_syms: ObstacleSymbolGroup,
}

ObstaclePool :: struct
{
    pool : [dynamic]ObstacleColumn,
    cooldown : f32,
}

obstacle_pool := ObstaclePool { pool = {} }

update_obstacles :: proc(delta_time: f32)
{
    for _, i in obstacle_pool.pool
    {
        e := &obstacle_pool.pool[i]

        if(!e.active)
        {
            continue
        }

        e.middle += rl.Vector2 { -1, 0 } * OBSTACLE_SPEED * delta_time

        player_shape := get_player_shape()
        upper_shape := get_upper_obstacle_shape(e.middle)
        lower_shape := get_lower_obstacle_shape(e.middle)

        if(check_shape_collision(player_shape, upper_shape) ||
           check_shape_collision(player_shape, lower_shape))
        {
            state = .LOST
        }

        score_area := get_score_area_shape(e.middle)

        if(!e.player_inscore && check_shape_collision(player_shape, score_area))
        {
            e.player_inscore = true
        }
        else if(e.player_inscore && !check_shape_collision(player_shape, score_area))
        {
            e.player_inscore = false
            score += 1
        }

        if(e.middle.x <= -OBSTACLE_WIDTH)
        {
            e.active = false
        }
    }
}

update_obstacle_spawning :: proc(delta_time: f32)
{
    if(obstacle_pool.cooldown > 0)
    {
        obstacle_pool.cooldown -= delta_time
        return
    }

    obstacle_pool.cooldown = OBSTACLE_SPAWN_COOLDOWN
    
    rand_percent_y :=  f32(rl.GetRandomValue(OBSTACLE_MIN_Y_PERCENT, OBSTACLE_MAX_Y_PERCENT)) / 100.0
    mid := rl.Vector2 { WINDOW_WIDTH + OBSTACLE_WIDTH/2, rand_percent_y * WINDOW_HEIGHT }
    
    // Setup obstacle symbols
    first, last := get_symbol_id_interval()
    upper_syms, lower_syms: ObstacleSymbolGroup

    for _, i in upper_syms
    {
        upper_id := rl.GetRandomValue(c.int(first), c.int(last))
        upper_syms[i] = asset_id(upper_id)

        lower_id := rl.GetRandomValue(c.int(first), c.int(last))
        lower_syms[i] = asset_id(lower_id)
    }

    add_obstacle(mid, upper_syms, lower_syms)
}

clear_obstacles :: proc()
{
    for _, i in obstacle_pool.pool
    {
        e := &obstacle_pool.pool[i]
        e.active = false
    }
}

add_obstacle :: proc(mid: rl.Vector2, upper_syms, lower_syms: ObstacleSymbolGroup)
{
    o := ObstacleColumn {
        active = true,
        middle = mid,
        upper_syms = upper_syms,
        lower_syms = lower_syms,
    }

    for _, i in obstacle_pool.pool
    {
        e := &obstacle_pool.pool[i]

        if(!e.active)
        {
            e^ = o
            return
        }            
    }

    append_elem(&obstacle_pool.pool, o)
}

get_score_area_shape :: proc(mid: rl.Vector2) -> ShapeRect
{
    return {
        center = mid,
        size = { OBSTACLE_WIDTH, OBSTACLE_VERTICAL_SPACING },
    }
}

get_upper_obstacle_shape :: proc(mid: rl.Vector2) -> ShapeRect
{
    center := rl.Vector2 { 0, -OBSTACLE_VERTICAL_SPACING/2 - OBSTACLE_HEIGHT/2 } + mid

    return {
        center = center,
        size = OBSTACLE_SIZE,
    }
}

get_lower_obstacle_shape :: proc(mid: rl.Vector2) -> ShapeRect
{
    center := rl.Vector2 { 0, OBSTACLE_VERTICAL_SPACING/2 + OBSTACLE_HEIGHT/2 } + mid

    return {
        center = center,
        size = OBSTACLE_SIZE,
    }
}

get_obstacle_symbol_points :: proc() -> (points: [OBSTACLE_SYMBOL_COUNT]rl.Vector2)
{
    for i in 0..<OBSTACLE_SYMBOL_COUNT
    {
        multiplier : f32 = f32(i) - (OBSTACLE_SYMBOL_COUNT-1)/2.0
        p := rl.Vector2 { 0, multiplier * f32(OBSTACLE_HEIGHT) / OBSTACLE_SYMBOL_COUNT  }
        points[i] = p
    }

    return
}