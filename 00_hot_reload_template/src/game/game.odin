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

import "core:c/libc"
import "core:os"

import rl "vendor:raylib"

Rect :: rl.Rectangle

Game_Memory :: struct {}

g_mem: ^Game_Memory
g_textures: rl.Texture2D

WINDOW_WIDTH :: 1600
WINDOW_HEIGHT :: 900


update :: proc() {
}

draw :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground({150, 190, 220, 255})

    rl.DrawTextureRec(g_textures, atlas_textures[.Test].rect, {0, 0}, rl.WHITE)

    rl.DrawFPS(WINDOW_WIDTH - 100, 10)
}

@(export)
game_update :: proc() -> bool {
    if ODIN_DEBUG {
        for f in file_versions {
            if mod, mod_err := os.last_write_time_by_name(f.path); mod_err == os.ERROR_NONE {
                if mod != f.modification_time {
                    libc.system("pushd .. && build_hot_reload.bat && popd")
                    break
                }
            }
        }
    }
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

    g_mem^ = Game_Memory{}
    g_textures = rl.LoadTexture("assets/texture_atlas.png")

    game_hot_reloaded(g_mem)
}

@(export)
game_shutdown :: proc() {
    rl.UnloadTexture(g_textures)
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

    new_textures := rl.LoadTexture("assets/texture_atlas.png")
    if new_textures.width != g_textures.width || new_textures.height != g_textures.height {
        rl.UnloadTexture(g_textures)
        g_textures = new_textures
    }
}

@(export)
game_force_reload :: proc() -> bool {
    return rl.IsKeyPressed(.F5)
}

@(export)
game_force_restart :: proc() -> bool {
    return rl.IsKeyPressed(.F6)
}
