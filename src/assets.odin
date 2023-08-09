package main

import rl "vendor:raylib"

asset_id :: enum uint
{
    TEXTURE_OBSTACLE,
    TEXTURE_PLAYER,
}

assets := [len(asset_id)]rl.Texture2D {}

load_assets :: proc()
{
    for id in asset_id
    {
        switch id
        {
            case .TEXTURE_OBSTACLE:
                assets[id] = rl.LoadTexture("assets/obstacle.png")
            case .TEXTURE_PLAYER:
                assets[id] = rl.LoadTexture("assets/player.png")
        }
    }
}

unload_assets :: proc()
{
    for id in asset_id
    {
        rl.UnloadTexture(assets[id])
        assets[id] = {}
    }
}

get_asset :: proc(id: asset_id) -> rl.Texture2D
{
    return assets[id]
}