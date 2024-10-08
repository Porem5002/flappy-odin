package main

import "core:math"
import "core:fmt"
import "core:strings"
import c "core:c/libc"

import rl "vendor:raylib"

SCREEN_TINT_ON_PAUSE := rl.Color { 0, 0, 0, 100 }
BACKGROUND_COLOR := rl.Color { 201, 213, 233, 255 }
UI_TEXT_COLOR := rl.Color { 255, 180, 0, 255 }

TARGET_FPS :: 60
FIXED_STEP :: 1.0 / 60.0

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
    rl.SetConfigFlags({ rl.ConfigFlag.VSYNC_HINT });
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
    rl.SetTargetFPS(TARGET_FPS)

    load_assets()

    icon_texture := get_asset(.TEXTURE_PLAYER).texture
    icon := rl.LoadImageFromTexture(icon_texture)
    rl.SetWindowIcon(icon)

    setup_game()

    for !rl.WindowShouldClose()
    {
        gather_inputs()

        frame_time := rl.GetFrameTime()
        
        for frame_time > 0
        {
            delta_time := min(frame_time, FIXED_STEP)
            update(delta_time)
            frame_time -= delta_time
        }

        rl.BeginDrawing()
            rl.ClearBackground(BACKGROUND_COLOR)
            rl.BeginMode2D(game_camera)
                draw()
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

            rl.DrawFPS(10, 10)
        rl.EndDrawing()
    }

    rl.UnloadImage(icon)
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
    if(inputs.fullscreen)
    {
        toggle_fullscreen()
        inputs.fullscreen = false
    }

    switch(state)
    {
        case .START:
            if(inputs.proceed)
            {
                state = .PLAY
                inputs.proceed = false
            }
        case .PLAY:
            update_obstacle_spawning(delta_time)
            update_player(delta_time)
            update_obstacles(delta_time)
        case .LOST:
            if(inputs.proceed)
            {
                setup_game()
                inputs.proceed = false
            }
    }
}

draw :: proc()
{
    WINDOW_CENTER :: rl.Vector2 { WINDOW_WIDTH/2.0, WINDOW_HEIGHT/2.0 }

    // Draw Background
    background_asset := get_asset(.TEXTURE_BACKGROUND)
    draw_asset(background_asset, WINDOW_CENTER)

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
        draw_text(rl.GetFontDefault(), "Press ENTER to start the game", WINDOW_CENTER, 35, 3, UI_TEXT_COLOR)
    }
    else if(state == .LOST)
    {
        rl.DrawRectangle(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, SCREEN_TINT_ON_PAUSE)
        draw_text(rl.GetFontDefault(), "YOU LOST", WINDOW_CENTER, 55, 5, UI_TEXT_COLOR)

        LOST_STATE_HINT_TEXT_POSITION := WINDOW_CENTER + rl.Vector2 { 0, 1 } * 50
        draw_text(rl.GetFontDefault(), "Press ENTER to continue", LOST_STATE_HINT_TEXT_POSITION, 22, 3.1, UI_TEXT_COLOR)
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

draw_text :: proc(font: rl.Font, text: cstring, position: rl.Vector2, font_size: f32, spacing: f32, color: rl.Color)
{
    text_size := rl.MeasureTextEx(font, text, font_size, spacing)
    text_position := position - text_size / 2.0
    rl.DrawTextEx(font, text, text_position, font_size, spacing, color)
}