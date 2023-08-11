package main

import c "core:c/libc"

import rl "vendor:raylib"

game_camera := rl.Camera2D { zoom = 1 }

toggle_fullscreen :: proc()
{
    if(!rl.IsWindowFullscreen())
    {
        monitor := rl.GetCurrentMonitor()
        mwidth, mheight := get_monitor_dimensions(monitor)

        rl.SetWindowSize(mwidth, mheight)
        rl.ToggleFullscreen()

        bar_width, _ := get_black_bar_size(mwidth, mheight)
        
        game_camera = rl.Camera2D {
            offset = { f32(bar_width), 0 },
            zoom = f32(mheight) / WINDOW_HEIGHT,
        }
    }
    else
    {
        rl.ToggleFullscreen()
        rl.SetWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT)
        game_camera = rl.Camera2D { zoom = 1 }
    }
}

get_monitor_dimensions :: proc(monitor: c.int) -> (width: c.int, height: c.int)
{
    width = rl.GetMonitorWidth(monitor)
    height = rl.GetMonitorHeight(monitor)
    return
} 

get_black_bar_size :: proc(monitor_width, monitor_height: c.int) -> (bar_width, bar_height: c.int)
{
    bar_width = (monitor_width  - monitor_height) / 2
    bar_height = monitor_height
    return
}