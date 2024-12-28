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

Bullet :: struct {
    active: bool,
    rect:   rl.Rectangle,
    angle:  f32,
}

Enemy :: struct {
    active: bool,
    rect:   rl.Rectangle,
}

Game_Memory :: struct {
    player:       rl.Rectangle,
    score:        int,
    score_timer:  f32,
    bounds:       [2]rl.Rectangle,
    bullets:      [32]Bullet,
    bullet_timer: f32,
    enemies:      [8]Enemy,
    enemy_timer:  f32,
}

WINDOW_WIDTH :: 1600
WINDOW_HEIGHT :: 900

GRAVITY :: 400
PLAYER_FORCE :: 500

BULLET_SPAWN_RATE :: 0.1
BULLET_SPEED :: 800

ENEMY_SPAWN_RATE :: 0.001
ENEMY_SPEED :: 400

g_mem: ^Game_Memory
g_textures: rl.Texture2D

init :: proc() {
    g_textures = rl.LoadTexture("assets/texture_atlas.png")

    g_mem.player = rl.Rectangle{100, 700, 100, 100}
    g_mem.bounds[0] = rl.Rectangle{0, 0, WINDOW_WIDTH, 50}
    g_mem.bounds[1] = rl.Rectangle{0, WINDOW_HEIGHT - 50, WINDOW_WIDTH, 50}

    for &bullet in g_mem.bullets {
        bullet.active = false
        bullet.rect = rl.Rectangle {
            x      = g_mem.player.x + g_mem.player.width / 2 - 12.5,
            y      = g_mem.player.y,
            width  = 25,
            height = 25,
        }
    }

    for &enemy in g_mem.enemies {
        enemy.active = false
        enemy.rect = rl.Rectangle{0, 0, 0, 0}
    }
}

update :: proc() {
    delta_time := rl.GetFrameTime()

    g_mem.score_timer += delta_time
    if g_mem.score_timer > 1 {
        g_mem.score_timer = 0
        g_mem.score += 1
    }

    g_mem.enemy_timer -= delta_time
    if g_mem.enemy_timer < 0 {
        g_mem.enemy_timer = f32(rl.GetRandomValue(1, 8))
        for &enemy in g_mem.enemies {
            if !enemy.active {
                enemy.active = true
                enemy.rect = rl.Rectangle{WINDOW_WIDTH, g_mem.bounds[1].y - 75, 75, 75}
                break
            }
        }
    }

    player_velocity: f32 = GRAVITY

    if rl.IsKeyDown(.SPACE) {
        player_velocity = -PLAYER_FORCE
    }

    g_mem.player.y += player_velocity * delta_time
    g_mem.player.y = clamp(g_mem.player.y, g_mem.bounds[0].height, g_mem.bounds[1].y - g_mem.player.height)

    if g_mem.player.y < g_mem.bounds[1].y - (g_mem.player.height * 2) {
        g_mem.bullet_timer += delta_time
        if g_mem.bullet_timer > BULLET_SPAWN_RATE {
            g_mem.bullet_timer = 0
            for &bullet in g_mem.bullets {
                if !bullet.active {
                    bullet.active = true
                    bullet.rect.x = g_mem.player.x + g_mem.player.width / 2 - 12.5
                    bullet.rect.y = g_mem.player.y
                    bullet.angle = f32(rl.GetRandomValue(-3, 3)) / 10
                    break
                }
            }
        }
    }

    for &bullet in g_mem.bullets {
        if bullet.active {
            bullet_velocity := BULLET_SPEED * delta_time * rl.Vector2{bullet.angle, 1}
            bullet.rect.x += bullet_velocity.x
            bullet.rect.y += bullet_velocity.y

            for &enemy in g_mem.enemies {
                if enemy.active {
                    if rl.CheckCollisionRecs(bullet.rect, enemy.rect) {
                        enemy.active = false
                        bullet.active = false
                    }
                }
            }

            if bullet.rect.y > WINDOW_HEIGHT {
                bullet.active = false
            }
        }
    }

    for &enemy in g_mem.enemies {
        if enemy.active {
            enemy.rect.x -= ENEMY_SPEED * delta_time
        }

        if enemy.rect.x < 0 - enemy.rect.width {
            enemy.active = false
        }
    }
}

draw :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground({150, 190, 220, 255})

    for bullet in g_mem.bullets {
        if bullet.active {
            rl.DrawRectangleRec(bullet.rect, {200, 0, 0, 255})
        }
    }

    for b in g_mem.bounds {
        rl.DrawRectangleRec(b, {0, 0, 255, 255})
    }

    for enemy in g_mem.enemies {
        if enemy.active {
            rl.DrawRectangleRec(enemy.rect, {0, 255, 0, 255})
        }
    }

    rl.DrawRectangleRec(g_mem.player, {255, 0, 0, 255})


    rl.DrawText(rl.TextFormat("Score: %d", g_mem.score), 10, 60, 20, {255, 255, 255, 255})
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
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Jetpack Jump")
    rl.InitAudioDevice()
    rl.SetTargetFPS(300)
}

@(export)
game_init :: proc() {
    g_mem = new(Game_Memory)

    g_mem^ = Game_Memory{}
    init()

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
