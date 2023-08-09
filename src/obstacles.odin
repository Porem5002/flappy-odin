package main

import "core:fmt"

import rl "vendor:raylib"

score : uint = 0

OBSTACLE_VERTICAL_SPACING :: 180

OBSTACLE_WIDTH :: 100
OBSTACLE_HEIGHT :: 600
OBSTACLE_SIZE :: rl.Vector2 { OBSTACLE_WIDTH, OBSTACLE_HEIGHT }

OBSTACLE_SPEED :: 235
OBSTACLE_SPAWN_COOLDOWN :: 1.5

ObstacleColumn :: struct
{
    active: bool,
    player_inscore: bool,
    middle: rl.Vector2,
}

ObstaclePool :: struct
{
    pool : [dynamic]ObstacleColumn,
    cooldown : f32,
}

obstacle_pool := ObstaclePool { pool = {} }

update_obstacles :: proc(delta_time: f32)
{
    for i in 0..<len(obstacle_pool.pool)
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
    mid := rl.Vector2 { WINDOW_WIDTH + OBSTACLE_WIDTH/2, f32(rl.GetRandomValue(15, 95)) / 100.0 * WINDOW_HEIGHT }
    add_obstacle_at_pos(mid)
}

clear_obstacles :: proc()
{
    for i in 0..<len(obstacle_pool.pool)
    {
        e := &obstacle_pool.pool[i]
        e.active = false
    }
}

add_obstacle_at_pos :: proc(mid: rl.Vector2)
{
    o := ObstacleColumn {
        active = true,
        middle = mid,
    }

    for i in 0..<len(obstacle_pool.pool)
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