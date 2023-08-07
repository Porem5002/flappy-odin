package main

import "core:fmt"
import "core:strings"
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
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Raylib wth Odin!")
    rl.SetTargetFPS(TARGET_FPS)

    load_assets()
    setup_game()

    for !rl.WindowShouldClose()
    {
        update()

        rl.ClearBackground(rl.LIGHTGRAY)
        rl.BeginDrawing()
        
        draw()

        rl.EndDrawing()
    }

    unload_assets()
    rl.CloseWindow()
}

setup_game :: proc()
{
    state = .START
    score = 0

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
    obstacle_texture := get_asset(.TEXTURE_OBSTACLE)

    for e in obstacle_pool.pool
    {
        if(!e.active)
        {
            continue
        }

        upper_rect := get_upper_obstacle_rect(e.middle)
        lower_rect := get_lower_obstacle_rect(e.middle)

        rl.DrawTextureV(obstacle_texture, rl.Vector2 { upper_rect.x, upper_rect.y }, rl.WHITE)
        rl.DrawTextureV(obstacle_texture, rl.Vector2 { lower_rect.x, lower_rect.y }, rl.WHITE)
    }

    s := fmt.tprint(score)
    cs := strings.clone_to_cstring(s)

    draw_text_centered_horizontaly(25, rl.GetFontDefault(), cs, 55, 3, rl.YELLOW) 

    if(state == .START)
    {
        draw_text_centered(rl.GetFontDefault(), "Press ENTER to start the game", 35, 3, rl.YELLOW)
    }
    else if(state == .LOST)
    {
        draw_text_centered(rl.GetFontDefault(), "YOU LOST", 55, 5, rl.YELLOW)
    }
}

draw_text_centered_horizontaly :: proc(y: f32, font: rl.Font, text: cstring, font_size: f32, spacing: f32, color: rl.Color)
{
    text_size := rl.MeasureTextEx(font, text, font_size, spacing)

    text_position := rl.Vector2 { (WINDOW_WIDTH - text_size.x)/2, y }
    
    rl.DrawTextEx(font, text, text_position, font_size, spacing, color)
}

draw_text_centered :: proc(font: rl.Font, text: cstring, font_size: f32, spacing: f32, color: rl.Color)
{
    text_size := rl.MeasureTextEx(font, text, font_size, spacing)

    text_position := rl.Vector2 { WINDOW_WIDTH, WINDOW_HEIGHT } - text_size
    text_position /= 2
    
    rl.DrawTextEx(font, text, text_position, font_size, spacing, color)
}