package main

import rl "vendor:raylib"

ShapeType :: enum
{
    RECTANGLE,
    CIRCLE,
}

ShapeRect :: struct
{
    center: rl.Vector2,
    size: rl.Vector2,
}

ShapeCircle :: struct
{
    center: rl.Vector2,
    radius: f32,
}

Shape :: union #no_nil
{
    ShapeRect,
    ShapeCircle,
}

get_shape_rect_rl_origin :: proc(shape: ShapeRect) -> rl.Vector2
{
    return shape.center - shape.size/2
}

shape_rect_to_rl_rect :: proc(shape: ShapeRect) -> rl.Rectangle
{
    rl_origin := get_shape_rect_rl_origin(shape)

    return {
        x = rl_origin.x,
        y = rl_origin.y,
        width = shape.size.x,
        height = shape.size.y,
    }
}

get_shape_center :: proc(shape: Shape) -> rl.Vector2
{
    switch s in shape 
    {
        case ShapeRect:
            return s.center
        case ShapeCircle:
            return s.center
    }

    panic("unreachable")
}

draw_shape :: proc(shape: Shape, color: rl.Color)
{
    switch s in shape 
    {
        case ShapeRect:
            rl_rect := shape_rect_to_rl_rect(s)
            rl.DrawRectangleRec(rl_rect, color)
        case ShapeCircle:
            rl.DrawCircleV(s.center, s.radius, color)
    }
}

check_shape_collision :: proc(a: Shape, b: Shape) -> bool
{
    switch va in a
    {
        case ShapeRect:
            rect_a := shape_rect_to_rl_rect(va)

            switch vb in b
            {
                case ShapeRect:
                    rect_b := shape_rect_to_rl_rect(vb)
                    return rl.CheckCollisionRecs(rect_a, rect_b)
                case ShapeCircle:
                    return rl.CheckCollisionCircleRec(vb.center, vb.radius, rect_a)
            }
        case ShapeCircle:
            switch vb in b
            {
                case ShapeRect:
                    rect_b := shape_rect_to_rl_rect(vb)
                    return rl.CheckCollisionCircleRec(va.center, va.radius, rect_b)
                case ShapeCircle:
                    return rl.CheckCollisionCircles(va.center, va.radius, vb.center, vb.radius)
            }
    }

    panic("unreachable")
}