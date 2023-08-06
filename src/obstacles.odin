package main

import "core:fmt"

import rl "vendor:raylib"

OBSTACLE_VERTICAL_SPACING :: 68

OBSTACLE_WIDTH :: 100
OBSTACLE_HEIGHT :: 600
OBSTACLE_SIZE :: rl.Vector2 { OBSTACLE_WIDTH, OBSTACLE_HEIGHT }

OBSTACLE_SPEED :: 100
OBSTACLE_SPAWN_COOLDOWN :: 2.28

Obstacle :: struct
{
    active: bool,
    index: int,
    position: rl.Vector2,
}

ObstaclePool :: struct
{
    pool : [dynamic]Obstacle,
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

        e.position += rl.Vector2 { -1, 0 } * OBSTACLE_SPEED * delta_time

        bird_rect := get_bird_rect()
        obstacle_rect := get_obstacle_rect(e)

        if(rl.CheckCollisionRecs(bird_rect, obstacle_rect))
        {
            state = .LOST
        }

        if(e.position.x < 0)
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
    center_pos := rl.Vector2 { WINDOW_WIDTH, f32(rl.GetRandomValue(15, 95)) / 100.0 * WINDOW_HEIGHT }

    up_pos := center_pos + rl.Vector2 { 0, -1 } * (OBSTACLE_VERTICAL_SPACING + OBSTACLE_HEIGHT)
    down_pos := center_pos + rl.Vector2 { 0, 1 } * OBSTACLE_VERTICAL_SPACING

    add_obstacle_at_pos(up_pos)
    add_obstacle_at_pos(down_pos)
}

clear_obstacles :: proc()
{
    for i in 0..<len(obstacle_pool.pool)
    {
        e := &obstacle_pool.pool[i]
        e.active = false
    }
}

add_obstacle_at_pos :: proc(pos: rl.Vector2)
{
    o := Obstacle {
        active = true,
        position = pos
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

get_obstacle_rect_ptr :: proc(obstacle: ^Obstacle) -> rl.Rectangle
{
    return rl.Rectangle {
        x = obstacle.position.x,
        y = obstacle.position.y,
        width = OBSTACLE_WIDTH,
        height = OBSTACLE_HEIGHT,
    }
}

get_obstacle_rect_struct :: proc(obstacle: Obstacle) -> rl.Rectangle
{
    return rl.Rectangle {
        x = obstacle.position.x,
        y = obstacle.position.y,
        width = OBSTACLE_WIDTH,
        height = OBSTACLE_HEIGHT,
    }
}

get_obstacle_rect :: proc { get_obstacle_rect_ptr, get_obstacle_rect_struct }