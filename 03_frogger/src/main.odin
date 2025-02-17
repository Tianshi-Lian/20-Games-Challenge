package frogger

import rl "vendor:raylib"

main :: proc() {
    window_width :: 1600
    window_height :: 900

    rl.InitWindow(window_width, window_height, "Frogger")
    defer rl.CloseWindow()

    for (!rl.WindowShouldClose()) {
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground(rl.LIGHTGRAY)

        msg_width := rl.MeasureText("Welcome to Frogger!", 20)
        rl.DrawText("Welcome to Frogger!", window_width / 2 - msg_width / 2, 450, 20, rl.BLACK)
    }
}
