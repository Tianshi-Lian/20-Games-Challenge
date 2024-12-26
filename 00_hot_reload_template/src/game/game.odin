// This file is compiled as part of the `odin.dll` file. It contains the
// procs that `game_hot_reload.exe` will call, such as:
//
// game_init: Sets up the game state
// game_update: Run once per frame
// game_shutdown: Shuts down game and frees memory
// game_memory: Run just before a hot reload, so game.exe has a pointer to the
//		game's memory.
// game_hot_reloaded: Run after a hot reload so that the `g_mem` global variable
//		can be set to whatever pointer it was in the old DLL.
//
// Note: When compiled as part of the release executable this whole package is imported as a normal
// odin package instead of a DLL.

package game

import rl "vendor:raylib"

Rect :: rl.Rectangle

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720

Game_Memory :: struct {
    texture:  rl.Texture2D,
    position: rl.Vector2,
}
g_mem: ^Game_Memory

update :: proc() {
}

draw :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground({150, 190, 220, 255})

    rl.DrawTexture(g_mem.texture, i32(g_mem.position.x), i32(g_mem.position.y), {255, 255, 255, 255})
    rl.DrawFPS(WINDOW_WIDTH - 100, 10)
}

@(export)
game_update :: proc() -> bool {
    update()
    draw()
    return !rl.WindowShouldClose()
}

@(export)
game_init_window :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Game")
    rl.InitAudioDevice()
    rl.SetTargetFPS(300)
}

@(export)
game_init :: proc() {
    g_mem = new(Game_Memory)

    g_mem^ = Game_Memory {
        texture  = rl.LoadTexture("assets/test.png"),
        position = {0, 0},
    }

    game_hot_reloaded(g_mem)
}

@(export)
game_shutdown :: proc() {
    free(g_mem)
}

@(export)
game_shutdown_window :: proc() {
    rl.CloseAudioDevice()
    rl.CloseWindow()
}

@(export)
game_memory :: proc() -> rawptr {
    return g_mem
}

@(export)
game_memory_size :: proc() -> int {
    return size_of(Game_Memory)
}

@(export)
game_hot_reloaded :: proc(mem: rawptr) {
    g_mem = (^Game_Memory)(mem)
}

@(export)
game_force_reload :: proc() -> bool {
    return rl.IsKeyPressed(.F5)
}

@(export)
game_force_restart :: proc() -> bool {
    return rl.IsKeyPressed(.F6)
}
