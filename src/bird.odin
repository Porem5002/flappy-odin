package main

import rl "vendor:raylib"

BIRD_GRAVITY_FORCE :: 36
BIRD_JUMP_FORCE :: 8

BIRD_WIDTH :: 40
BIRD_HEIGHT :: 40
BIRD_SIZE :: rl.Vector2 { BIRD_WIDTH, BIRD_HEIGHT }

Bird :: struct
{
    position: rl.Vector2,
    velocity: rl.Vector2,
}

bird := Bird {}

update_bird :: proc(delta_time: f32)
{
    if rl.IsKeyPressed(.SPACE)
    {
        bird.velocity = rl.Vector2 { 0, -1 } * BIRD_JUMP_FORCE
    }
    else
    {
        bird.velocity += rl.Vector2 { 0, 1 } * BIRD_GRAVITY_FORCE * delta_time
    }

    bird.position += bird.velocity
}

get_bird_shape :: proc() -> Shape
{
    return ShapeRect {
        center = bird.position,
        size = BIRD_SIZE,
    }
}