package main

import "core:fmt"
import c "core:c/libc"

import rl "vendor:raylib"

TARGET_FPS :: 60
WINDOW_WIDTH :: 700
WINDOW_HEIGHT :: 700

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

update :: proc()
{
    delta_time := rl.GetFrameTime()
    
    update_bird(delta_time)
    update_obstacle_spawning(delta_time)
    update_obstacles(delta_time)
}

draw :: proc()
{
    // Draw bird
    bird_rect := get_bird_rect()
    rl.DrawRectangleRec(bird_rect, rl.BLACK)
    
    // Draw obstacles
    for e in obstacle_pool.pool
    {
        if(!e.active)
        {
            continue
        }

        rect := get_obstacle_rect(e)
        rl.DrawRectangleRec(rect, rl.RED)
    }
}