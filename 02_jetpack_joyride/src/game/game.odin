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

WINDOW_WIDTH :: 1600
WINDOW_HEIGHT :: 900

GRAVITY :: 400
PLAYER_FORCE :: 500

BULLET_SPAWN_RATE :: 0.1
BULLET_SPEED :: 800

ENEMY_SPAWN_RATE :: 0.001
ENEMY_SPEED_MIN :: 300
ENEMY_SPEED_MAX :: 600

BULLET_COUNT :: 32
SOLDIER_COUNT :: 8
PLANE_COUNT :: 4
ENTITY_COUNT :: BULLET_COUNT + SOLDIER_COUNT + PLANE_COUNT

Entity_Type :: enum {
    Bullet,
    Soldier,
    Plane,
}

Entity :: struct {
    type:         Entity_Type,
    active:       bool,
    position:     rl.Vector2,
    size:         rl.Vector2,
    acceleration: rl.Vector2,
    texture_rect: rl.Rectangle,
}

Game_Memory :: struct {
    player:             rl.Rectangle,
    score:              int,
    score_timer:        f32,
    bounds:             [2]rl.Rectangle,
    entities:           [ENTITY_COUNT]Entity,
    bullets:            [BULLET_COUNT]^Entity,
    soldiers:           [SOLDIER_COUNT]^Entity,
    planes:             [PLANE_COUNT]^Entity,
    bullet_timer:       f32,
    enemy_staff_timer:  f32,
    enemy_planes_timer: f32,
}

g_mem: ^Game_Memory
g_textures: rl.Texture2D

player_animation: Sprite_Animation = animation_create(.Jetpack_Floor_Run)

background: Atlas_Texture = atlas_textures[.Sky_Color]

init :: proc() {
    g_textures = rl.LoadTexture("assets/texture_atlas.png")

    g_mem.player = rl.Rectangle{100, 700, 100, 100}
    g_mem.bounds[0] = rl.Rectangle{0, 0, WINDOW_WIDTH, 50}
    g_mem.bounds[1] = rl.Rectangle{0, WINDOW_HEIGHT - 50, WINDOW_WIDTH, 50}

    for &entity, index in g_mem.entities {
        if index < BULLET_COUNT {
            entity.type = .Bullet
            entity.active = false
            entity.position = {g_mem.player.x + g_mem.player.width / 2 - 12.5, g_mem.player.y}
            entity.size = {25, 25}
            entity.acceleration = {0, BULLET_SPEED}
            g_mem.bullets[index] = &entity
        } else if index < BULLET_COUNT + SOLDIER_COUNT {
            entity.type = .Soldier
            entity.active = false
            entity.position = {0, 0}
            entity.size = {75, 75}
            entity.acceleration = {-f32(rl.GetRandomValue(ENEMY_SPEED_MIN, ENEMY_SPEED_MAX)), 0}
            g_mem.soldiers[index - BULLET_COUNT] = &entity
        } else {
            plane_color := rl.GetRandomValue(0, 2)
            texture_rect := atlas_textures[Texture_Name(i32(Texture_Name.Plane_1_Blue) + plane_color)].rect
            texture_rect.width = -texture_rect.width

            entity.type = .Plane
            entity.active = false
            entity.position = {WINDOW_WIDTH, 400}
            entity.size = {texture_rect.width, texture_rect.height}
            entity.acceleration = {-f32(rl.GetRandomValue(ENEMY_SPEED_MIN, ENEMY_SPEED_MAX)), 0}
            entity.texture_rect = texture_rect
            g_mem.planes[index - BULLET_COUNT - SOLDIER_COUNT] = &entity
        }
    }
}

update :: proc() {
    delta_time := rl.GetFrameTime()

    g_mem.score_timer += delta_time
    if g_mem.score_timer > 1 {
        g_mem.score_timer = 0
        g_mem.score += 1
    }

    g_mem.enemy_staff_timer -= delta_time
    if g_mem.enemy_staff_timer < 0 {
        g_mem.enemy_staff_timer = f32(rl.GetRandomValue(1, 8))
        for &entity in g_mem.soldiers {
            if entity.type == .Soldier && !entity.active {
                entity.active = true
                entity.position = {WINDOW_WIDTH, g_mem.bounds[1].y - entity.size.x}
                break
            }
        }
    }

    g_mem.enemy_planes_timer -= delta_time
    if g_mem.enemy_planes_timer < 0 {
        g_mem.enemy_planes_timer = f32(rl.GetRandomValue(1, 4))
        for &entity in g_mem.planes {
            if entity.type == .Plane && !entity.active {
                entity.active = true
                plane_color := rl.GetRandomValue(0, 2)
                texture_rect := atlas_textures[Texture_Name(i32(Texture_Name.Plane_1_Blue) + plane_color)].rect
                texture_rect.width = -texture_rect.width
                entity.texture_rect = texture_rect
                entity.position = {WINDOW_WIDTH, 400}
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
                if bullet.type == .Bullet && !bullet.active {
                    bullet.active = true
                    bullet.position.x = g_mem.player.x + g_mem.player.width / 2 - 12.5
                    bullet.position.y = g_mem.player.y
                    bullet.acceleration.x = f32(rl.GetRandomValue(-100, 100))
                    break
                }
            }
        }
    }

    if g_mem.player.y < g_mem.bounds[1].y - g_mem.player.height {
        if player_animation.atlas_anim != .Jetpack_Flying {
            player_animation = animation_create(.Jetpack_Flying)
        }
    } else {
        if player_animation.atlas_anim != .Jetpack_Floor_Run {
            player_animation = animation_create(.Jetpack_Floor_Run)
        }
    }

    for &entity in g_mem.entities {
        if entity.active {
            entity.position += entity.acceleration * delta_time
        }
    }

    for &bullet in g_mem.bullets {
        if bullet.type == .Bullet && bullet.active {
            for &enemy in g_mem.soldiers {
                if enemy.type == .Soldier && enemy.active {
                    if rl.CheckCollisionRecs(
                        {bullet.position.x, bullet.position.y, bullet.size.x, bullet.size.y},
                        {enemy.position.x, enemy.position.y, enemy.size.x, enemy.size.y},
                    ) {
                        enemy.active = false
                        bullet.active = false
                    }
                }
            }

            if bullet.position.y > WINDOW_HEIGHT {
                bullet.active = false
            }
        }
    }

    animation_update(&player_animation, delta_time)
}

draw :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground({150, 190, 220, 255})

    rl.DrawTexturePro(g_textures, background.rect, {0, 0, WINDOW_WIDTH, WINDOW_HEIGHT}, {0, 0}, 0, {255, 255, 255, 255})

    for b in g_mem.bounds {
        rl.DrawRectangleRec(b, {0, 0, 255, 255})
    }

    for entity in g_mem.entities {
        if entity.active {
            switch entity.type {
            case .Bullet, .Soldier:
                rl.DrawRectangleV(entity.position, entity.size, {200, 0, 0, 255}) // TODO: Different colours
            case .Plane:
                rl.DrawTextureRec(g_textures, entity.texture_rect, entity.position, {255, 255, 255, 255})
            }
        }
    }

    //rl.DrawRectangleRec(g_mem.player, {255, 0, 0, 255})

    animation_draw(g_textures, player_animation, {g_mem.player.x - 130, g_mem.player.y - 160})

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
