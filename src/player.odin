package main

import rl "vendor:raylib"

PLAYER_GRAVITY_FORCE :: 36
PLAYER_JUMP_FORCE :: 8

PLAYER_DISPLAY_OFFSET :: rl.Vector2 { 0, -6 }
PLAYER_RADIUS :: 23

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
    return ShapeCircle {
        center = player.position,
        radius = PLAYER_RADIUS,
    }
}