package main

import rl "vendor:raylib"

KEY_JUMP :: rl.KeyboardKey.SPACE
KEY_PROCEED :: rl.KeyboardKey.ENTER
KEY_FULLSCREEN :: rl.KeyboardKey.F

input_data :: struct
{
    jump: bool,
    proceed: bool,
    fullscreen: bool,
}

inputs := input_data {}

gather_inputs :: proc()
{
    inputs.jump = rl.IsKeyPressed(KEY_JUMP)
    inputs.proceed = rl.IsKeyPressed(KEY_PROCEED)
    inputs.fullscreen = rl.IsKeyPressed(KEY_FULLSCREEN)
}