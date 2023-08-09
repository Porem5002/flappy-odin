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

    player = {
        position = { WINDOW_WIDTH/3.0, WINDOW_HEIGHT/2.0 },
        velocity = {},
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
            update_player(delta_time)
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
    // Draw player
    player_texture := get_asset(.TEXTURE_PLAYER)
    player_shape := get_player_shape()
    player_display_center := get_shape_center(player_shape) + PLAYER_DISPLAY_OFFSET
    draw_texture_with_center(player_texture, player_display_center)
    
    // Draw obstacles
    obstacle_texture := get_asset(.TEXTURE_OBSTACLE)

    for e in obstacle_pool.pool
    {
        if(!e.active)
        {
            continue
        }

        upper_shape := get_upper_obstacle_shape(e.middle)
        lower_shape := get_lower_obstacle_shape(e.middle)

        upper_origin := get_shape_rect_rl_origin(upper_shape)
        lower_origin := get_shape_rect_rl_origin(lower_shape)

        rl.DrawTextureV(obstacle_texture, upper_origin, rl.WHITE)
        rl.DrawTextureV(obstacle_texture, lower_origin, rl.WHITE)
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

draw_texture_with_center :: proc(texture: rl.Texture2D, center: rl.Vector2)
{
    texture_size := rl.Vector2 { f32(texture.width), f32(texture.height) }
    texture_origin := center - texture_size/2
    rl.DrawTextureV(texture, texture_origin, rl.WHITE)
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