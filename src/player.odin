package main

import "core:math"

import rl "vendor:raylib"

PLAYER_GRAVITY_FORCE :: 36
PLAYER_JUMP_FORCE :: 8

PLAYER_RADIUS :: 25
PLAYER_ROTATION_SPEED :: math.TAU

Player :: struct
{
    position: rl.Vector2,
    velocity_y: f32,
    current_rotation: f32,
}

player := Player {}

fixed_update_player :: proc()
{
    // Handle Movement
    if is_key_pressed_once(.SPACE)
    {
        player.velocity_y = PLAYER_JUMP_FORCE
    }
    else
    {
        player.velocity_y -= PLAYER_GRAVITY_FORCE * FIXED_DELTA_TIME
    }

    player.position += rl.Vector2 { 0, -1 } * player.velocity_y

    // Lose if player is out of the screen
    if(player.position.y+PLAYER_RADIUS*2 <= 0 ||
       player.position.y-PLAYER_RADIUS*2 >= WINDOW_HEIGHT)
    {
        state = .LOST
    }

    // Update rotation
    target_rotation := math.atan2_f32(player.velocity_y, FIXED_DELTA_TIME * OBSTACLE_SPEED)
    player.current_rotation += (target_rotation - player.current_rotation) * PLAYER_ROTATION_SPEED * FIXED_DELTA_TIME
}

get_player_shape :: proc() -> Shape
{
    return ShapeCircle {
        center = player.position,
        radius = PLAYER_RADIUS,
    }
}