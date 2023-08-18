package main

import rl "vendor:raylib"

asset_id :: enum uint
{
    TEXTURE_SYMBOL_VALKNUT,
    TEXTURE_SYMBOL_WOW,
    TEXTURE_PLAYER,
}

asset :: struct
{
    texture: rl.Texture2D,
    origin: rl.Vector2,
    scale: f32,
}

assets := [len(asset_id)]asset {}

load_assets :: proc()
{
    for id in asset_id
    {
        a := &assets[id]; 

        switch id
        {
            case .TEXTURE_SYMBOL_VALKNUT:
                a.texture = rl.LoadTexture("assets/symbols/valknut.png")
                a.origin = { 194.0/420.0, 237.0/385.0 }
                a.scale = 0.16
            case .TEXTURE_SYMBOL_WOW:
                a.texture = rl.LoadTexture("assets/symbols/web_of_wyrd.png")
                a.origin = { 0.5, 0.5 }
                a.scale = 0.25
            case .TEXTURE_PLAYER:
                a.texture = rl.LoadTexture("assets/player.png")
                a.origin = { 0.5, 0.5757 }
                a.scale = 1
        }
    }
}

unload_assets :: proc()
{
    for id in asset_id
    {
        a := &assets[id]; 
        rl.UnloadTexture(a.texture)
        a^ = {}
    }
}

get_asset :: proc(id: asset_id) -> asset
{
    return assets[id]
}

get_symbol_id_interval :: proc() -> (first, last: asset_id)
{
    first = .TEXTURE_SYMBOL_VALKNUT
    last = .TEXTURE_SYMBOL_WOW
    return
}