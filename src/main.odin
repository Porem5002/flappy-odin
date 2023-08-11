package main

import "core:math"
import "core:fmt"
import "core:strings"
import c "core:c/libc"

import rl "vendor:raylib"

SCREEN_TINT_ON_PAUSE := rl.Color { a = 100 }
UI_TEXT_COLOR := rl.YELLOW

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
        delta_time := rl.GetFrameTime()

        update(delta_time)

        rl.ClearBackground(rl.LIGHTGRAY)
        rl.BeginDrawing()

            rl.BeginMode2D(game_camera)
                draw(delta_time)
            rl.EndMode2D()

            // Draw Side Bars
            if(rl.IsWindowFullscreen())
            {
                monitor := rl.GetCurrentMonitor()
                mwidth, mheight := get_monitor_dimensions(monitor)
                bar_width, bar_height := get_black_bar_size(mwidth, mheight)

                rl.DrawRectangle(0, 0, bar_width, bar_height, rl.BLACK)
                rl.DrawRectangle(mwidth - bar_width, mheight - bar_height, bar_width, bar_height, rl.BLACK)
            }

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
        velocity_y = 0,
        current_rotation = 0,
    }

    obstacle_pool.cooldown = 0
    clear_obstacles()
}

update :: proc(delta_time: f32)
{
    if(rl.IsKeyPressed(.F))
    {
        toggle_fullscreen()
    }

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

draw :: proc(delta_time: f32)
{
    // Draw player
    player_texture := get_asset(.TEXTURE_PLAYER)
    player_rotation := -math.to_degrees(player.current_rotation)
    origin_offset := rl.Vector2 { 0.5, 0.5757 }
    draw_texture_with_center(player_texture, player.position, origin_offset, player_rotation)

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

        draw_texture_with_center(obstacle_texture, upper_shape.center)
        draw_texture_with_center(obstacle_texture, lower_shape.center)
    }

    // Darken screen and draw state specific text
    if(state == .START)
    {
        rl.DrawRectangle(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, SCREEN_TINT_ON_PAUSE)
        draw_text_centered(rl.GetFontDefault(), "Press ENTER to start the game", 35, 3, UI_TEXT_COLOR)
    }
    else if(state == .LOST)
    {
        rl.DrawRectangle(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, SCREEN_TINT_ON_PAUSE)
        draw_text_centered(rl.GetFontDefault(), "YOU LOST", 55, 5, UI_TEXT_COLOR)
    }

    // Draw Score Displayer
    s := fmt.tprint(score)
    cs := strings.clone_to_cstring(s)
    draw_text_centered_horizontaly(25, rl.GetFontDefault(), cs, 55, 3, UI_TEXT_COLOR) 
}

draw_texture_with_center :: proc(texture: rl.Texture2D, center: rl.Vector2, origin_offset: rl.Vector2 = { 0.5, 0.5 }, rotation: f32 = 0)
{
    source_rect := rl.Rectangle { x = 0, y = 0, width = f32(texture.width), height = f32(texture.height) }
    dest_rect := rl.Rectangle { x = center.x, y = center.y, width = f32(texture.width), height = f32(texture.height) }
    origin_offset := origin_offset * rl.Vector2 { f32(texture.width), f32(texture.height) }

    rl.DrawTexturePro(texture, source_rect, dest_rect, origin_offset, rotation, rl.WHITE)
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