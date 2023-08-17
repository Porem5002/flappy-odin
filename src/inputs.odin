package main

import "core:fmt"

import rl "vendor:raylib"

key_cache := [u64(max(rl.KeyboardKey))+1]bool {}

fill_key_cache :: proc()
{
    for key in rl.KeyboardKey
    {
        if(rl.IsKeyPressed(key))
        {
            key_cache[key] = true
        }
    }
}

clear_key_cache :: proc()
{
    key_cache = {}
}

is_key_pressed_once :: proc(key: rl.KeyboardKey) -> bool
{
    return key_cache[key]
}