package main

import "core:fmt"
import c "core:c/libc"

import rl "vendor:raylib"

GRAVITY_FORCE :: 18
JUMP_FORCE :: 5

BIRD_WIDTH :: 40
BIRD_HEIGHT :: 40
BIRD_SIZE :: rl.Vector2 { BIRD_WIDTH, BIRD_HEIGHT }

Bird :: struct
{
    position: rl.Vector2,
    velocity: rl.Vector2,
}

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

TARGET_FPS :: 60
WINDOW_WIDTH :: 700
WINDOW_HEIGHT :: 700

bird := Bird {}
obstacle_pool := ObstaclePool { pool = {} }

main :: proc()
{
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Raylib wth Odin!")

    rl.SetTargetFPS(TARGET_FPS)

    for !rl.WindowShouldClose()
    {
        update()

        rl.ClearBackground(rl.LIGHTGRAY)
        rl.BeginDrawing()
        
        draw()

        rl.EndDrawing()
    }

    rl.CloseWindow()
}

draw :: proc()
{
    // Draw bird
    rl.DrawRectangleV(bird.position, BIRD_SIZE, rl.BLACK)
    
    // Draw obstacles
    for e in obstacle_pool.pool
    {
        if(!e.active)
        {
            continue
        }

        rl.DrawRectangleV(e.position, OBSTACLE_SIZE, rl.RED)
    }
}

update :: proc()
{
    delta_time := rl.GetFrameTime()
    update_player(delta_time)
    update_obstacle_spawning(delta_time)
    update_obstacles(delta_time)
}

update_player :: proc(delta_time: f32)
{
    if rl.IsKeyPressed(.SPACE)
    {
        bird.velocity = rl.Vector2 { 0, -1 } * JUMP_FORCE
    }
    else
    {
        bird.velocity += rl.Vector2 { 0, 1 } * GRAVITY_FORCE * delta_time
    }

    bird.position += bird.velocity
}

update_obstacles :: proc(delta_time: f32)
{
    // Update currently registered obstacles
    for i in 0..<len(obstacle_pool.pool)
    {
        e := &obstacle_pool.pool[i]

        if(!e.active)
        {
            continue
        }

        e.position += rl.Vector2 { -1, 0 } * OBSTACLE_SPEED * delta_time

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
