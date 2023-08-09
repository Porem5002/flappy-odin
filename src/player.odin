package main

import rl "vendor:raylib"

PLAYER_GRAVITY_FORCE :: 36
PLAYER_JUMP_FORCE :: 8

PLAYER_WIDTH :: 40
PLAYER_HEIGHT :: 40
PLAYER_SIZE :: rl.Vector2 { PLAYER_WIDTH, PLAYER_HEIGHT }

Player :: struct
{
    position: rl.Vector2,
    velocity: rl.Vector2,
}

player := Player {}

update_player :: proc(delta_time: f32)
{
    if rl.IsKeyPressed(.SPACE)
    {
        player.velocity = rl.Vector2 { 0, -1 } * PLAYER_JUMP_FORCE
    }
    else
    {
        player.velocity += rl.Vector2 { 0, 1 } * PLAYER_GRAVITY_FORCE * delta_time
    }

    player.position += player.velocity
}

get_player_shape :: proc() -> Shape
{
    return ShapeRect {
        center = player.position,
        size = PLAYER_SIZE,
    }
}