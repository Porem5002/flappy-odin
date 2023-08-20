package main

import "core:math"
import "core:fmt"
import "core:strings"
import c "core:c/libc"

import rl "vendor:raylib"

SCREEN_TINT_ON_PAUSE := rl.Color { a = 100 }
UI_TEXT_COLOR := rl.YELLOW

TARGET_FPS :: 60
FIXED_DELTA_TIME :: 1.0 / 60.0

WINDOW_NAME :: "Flappy Odin"
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
    rl.SetTraceLogLevel(ODIN_DEBUG ? .ALL : .NONE)

    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
    rl.SetTargetFPS(TARGET_FPS)

    load_assets()
    setup_game()

    fixed_timer : f32 = 0

    for !rl.WindowShouldClose()
    {
        delta_time := rl.GetFrameTime()
        fixed_timer -= delta_time

        fill_key_cache()

        if fixed_timer <= 0
        {
            fixed_timer = FIXED_DELTA_TIME
            fixed_update()
            clear_key_cache()
        }

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

fixed_update :: proc()
{
    if(state == .PLAY)
    {
        fixed_update_player()
        fixed_update_obstacles()
    }
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
            update_obstacle_spawning(delta_time)
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
    player_asset := get_asset(.TEXTURE_PLAYER)
    player_rotation := -math.to_degrees(player.current_rotation)
    draw_asset(player_asset, player.position, player_rotation)

    // Draw obstacles
    for e in obstacle_pool.pool
    {
        if(!e.active)
        {
            continue
        }

        upper_shape := get_upper_obstacle_shape(e.middle)
        lower_shape := get_lower_obstacle_shape(e.middle)

        draw_shape(upper_shape, OBSTACLE_MAIN_COLOR)
        draw_shape(lower_shape, OBSTACLE_MAIN_COLOR)

        for point, i in get_obstacle_symbol_points()
        {
            up_id := e.upper_syms[i]
            draw_asset(get_asset(up_id), upper_shape.center + point)
            
            low_id := e.lower_syms[i]
            draw_asset(get_asset(low_id), lower_shape.center + point)
        }
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

draw_asset :: proc(asset: asset, position: rl.Vector2, rotation: f32 = 0)
{
    width := f32(asset.texture.width)
    height := f32(asset.texture.height)

    scaled_width := width * asset.scale
    scaled_height := height * asset.scale

    source_rect := rl.Rectangle { x = 0, y = 0, width = width, height = height }
    dest_rect := rl.Rectangle { x = position.x, y = position.y, width = scaled_width, height = scaled_height }
    origin := asset.origin * rl.Vector2 { scaled_width, scaled_height }

    rl.DrawTexturePro(asset.texture, source_rect, dest_rect, origin, rotation, rl.WHITE)
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