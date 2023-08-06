package main

import "core:fmt"
import c "core:c/libc"

import rl "vendor:raylib"

TARGET_FPS :: 60
WINDOW_WIDTH :: 700
WINDOW_HEIGHT :: 700

State :: enum
{
    START,
    PLAY,
    LOST,
}

state : State = {}

main :: proc()
{
    setup_game()

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

setup_game :: proc()
{
    state = .START
    
    bird = {
        position = rl.Vector2 { 0, (WINDOW_HEIGHT - BIRD_HEIGHT) / 2.0 },
        velocity = {}
    }

    obstacle_pool.cooldown = 0
    clear_obstacles()
}

update :: proc()
{
    delta_time := rl.GetFrameTime()
    
    switch(state)
    {
        case .START:
            if(rl.IsKeyPressed(.ENTER))
            {
                state = .PLAY
            }
        case .PLAY:
            update_bird(delta_time)
            update_obstacle_spawning(delta_time)
            update_obstacles(delta_time)
        case .LOST:
            if(rl.IsKeyPressed(.ENTER))
            {
                setup_game()
            }
    }
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

    if(state == .START)
    {
        draw_text_centered(rl.GetFontDefault(), "Press ENTER to start the game", 35, 3, rl.YELLOW)
    }
    else if(state == .LOST)
    {
        draw_text_centered(rl.GetFontDefault(), "YOU LOST", 55, 5, rl.YELLOW)
    }
}

draw_text_centered :: proc(font: rl.Font, text: cstring, font_size: f32, spacing: f32, color: rl.Color)
{
    text_size := rl.MeasureTextEx(font, text, font_size, spacing)

    text_position := rl.Vector2 { WINDOW_WIDTH, WINDOW_HEIGHT } - text_size
    text_position /= 2
    
    rl.DrawTextEx(font, text, text_position, font_size, spacing, color)
}