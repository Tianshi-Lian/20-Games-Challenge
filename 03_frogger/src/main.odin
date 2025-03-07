package frogger

import rl "vendor:raylib"

main :: proc() {
    window_width :: 1600
    window_height :: 832
    tile_size :: 64
    tile_count_x :: window_width / tile_size
    tile_count_y :: window_height / tile_size

    tilemap: [tile_count_y][tile_count_x]int = {
        {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
        {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
        {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
        {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
        {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
        {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    }

    rl.InitWindow(window_width, window_height, "Frogger")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    frog_position := rl.Vector2{12, 12}

    for (!rl.WindowShouldClose()) {
        movement := rl.Vector2{0, 0}
        if rl.IsKeyPressed(rl.KeyboardKey.D) || rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
            movement.x += 1
        } else if rl.IsKeyPressed(rl.KeyboardKey.A) || rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
            movement.x -= 1
        } else if rl.IsKeyPressed(rl.KeyboardKey.W) || rl.IsKeyPressed(rl.KeyboardKey.UP) {
            movement.y -= 1
        } else if rl.IsKeyPressed(rl.KeyboardKey.S) || rl.IsKeyPressed(rl.KeyboardKey.DOWN) {
            movement.y += 1
        }

        frog_position.x = clamp(frog_position.x + movement.x, 0, tile_count_x - 1)
        frog_position.y = clamp(frog_position.y + movement.y, 0, tile_count_y - 1)

        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground(rl.LIGHTGRAY)

        for y in 0 ..< tile_count_y {
            for x in 0 ..< tile_count_x {
                color: rl.Color = rl.VIOLET
                switch tile := tilemap[y][x]; tile {
                case 0:
                    color = rl.BROWN
                case 1:
                    color = rl.DARKGRAY
                case 2:
                    color = rl.BLUE
                case 3:
                    color = rl.LIME
                case 4:
                    color = rl.DARKBLUE
                }
                rl.DrawRectangle(i32(x * tile_size), i32(y * tile_size), tile_size, tile_size, color)
            }
        }

        rl.DrawRectangle(i32(frog_position.x * tile_size), i32(frog_position.y * tile_size), tile_size, tile_size, rl.GREEN)
    }
}
