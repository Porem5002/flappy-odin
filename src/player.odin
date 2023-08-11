package main

import "core:math"

import rl "vendor:raylib"

PLAYER_GRAVITY_FORCE :: 36
PLAYER_JUMP_FORCE :: 8

PLAYER_DISPLAY_OFFSET :: rl.Vector2 { 0, -6 }
PLAYER_RADIUS :: 23

PLAYER_ROTATION_SPEED :: math.TAU

Player :: struct
{
    position: rl.Vector2,
    velocity_y: f32,
    current_rotation: f32,
}

player := Player {}

update_player :: proc(delta_time: f32)
{
    // Handle Movement
    if rl.IsKeyPressed(.SPACE)
    {
        player.velocity_y = PLAYER_JUMP_FORCE
    }
    else
    {
        player.velocity_y -= PLAYER_GRAVITY_FORCE * delta_time
    }

    player.position += rl.Vector2 { 0, -1 } * player.velocity_y

    // Lose if player is out of the screen
    if(player.position.y+PLAYER_RADIUS*2 <= 0 ||
       player.position.y-PLAYER_RADIUS*2 >= WINDOW_HEIGHT)
    {
        state = .LOST
    }

    // Update rotation
    target_rotation := math.atan2_f32(player.velocity_y, delta_time * OBSTACLE_SPEED)
    player.current_rotation += (target_rotation - player.current_rotation) * PLAYER_ROTATION_SPEED * delta_time
}

get_player_shape :: proc() -> Shape
{
    return ShapeCircle {
        center = player.position,
        radius = PLAYER_RADIUS,
    }
}