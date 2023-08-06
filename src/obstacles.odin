package main

import "core:fmt"

import rl "vendor:raylib"

score : uint = 0

OBSTACLE_VERTICAL_SPACING :: 140

OBSTACLE_WIDTH :: 100
OBSTACLE_HEIGHT :: 600
OBSTACLE_SIZE :: rl.Vector2 { OBSTACLE_WIDTH, OBSTACLE_HEIGHT }

OBSTACLE_SPEED :: 100
OBSTACLE_SPAWN_COOLDOWN :: 2.55

ObstacleColumn :: struct
{
    active: bool,
    bird_inscore: bool,
    index: int,
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

        bird_rect := get_bird_rect()
        upper_rect := get_upper_obstacle_rect(e.middle)
        lower_rect := get_lower_obstacle_rect(e.middle)

        if(rl.CheckCollisionRecs(bird_rect, upper_rect) ||
           rl.CheckCollisionRecs(bird_rect, lower_rect))
        {
            state = .LOST
        }

        mid_rect := get_middle_obstacle_rect(e.middle)

        if(!e.bird_inscore && rl.CheckCollisionRecs(bird_rect, mid_rect))
        {
            e.bird_inscore = true
        }
        else if(e.bird_inscore && !rl.CheckCollisionRecs(bird_rect, mid_rect))
        {
            e.bird_inscore = false
            score += 1
        }

        if(e.middle.x <= -OBSTACLE_WIDTH/2)
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
        middle = mid
    }

    for i in 0..<len(obstacle_pool.pool)
    {
        e := &obstacle_pool.pool[i]

        if(!e.active)
        {
            o.index = i
            e^ = o
            return
        }            
    }

    o.index = len(obstacle_pool.pool)
    append_elem(&obstacle_pool.pool, o)
}

get_middle_obstacle_rect :: proc(mid: rl.Vector2) -> rl.Rectangle
{
    pos := rl.Vector2 { -OBSTACLE_WIDTH/2, -OBSTACLE_VERTICAL_SPACING/2 } + mid

    return rl.Rectangle {
        x = pos.x,
        y = pos.y,
        width = OBSTACLE_WIDTH,
        height = OBSTACLE_VERTICAL_SPACING,
    }
}

get_upper_obstacle_rect :: proc(mid: rl.Vector2) -> rl.Rectangle
{
    pos := rl.Vector2 { -OBSTACLE_WIDTH/2, -(OBSTACLE_VERTICAL_SPACING/2+OBSTACLE_HEIGHT) } + mid

    return rl.Rectangle {
        x = pos.x,
        y = pos.y,
        width = OBSTACLE_WIDTH,
        height = OBSTACLE_HEIGHT,
    }
}

get_lower_obstacle_rect :: proc(mid: rl.Vector2) -> rl.Rectangle
{
    pos := rl.Vector2 { -OBSTACLE_WIDTH/2, OBSTACLE_VERTICAL_SPACING/2 } + mid

    return rl.Rectangle {
        x = pos.x,
        y = pos.y,
        width = OBSTACLE_WIDTH,
        height = OBSTACLE_HEIGHT,
    }
}