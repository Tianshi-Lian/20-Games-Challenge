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

WINDOW_WIDTH :: 1600
WINDOW_HEIGHT :: 900

WALL_GAP_MIN :: 250
WALL_GAP_MAX :: 400
WALL_MIN_HEIGHT :: 16
WALL_MAX_HEIGHT :: WINDOW_HEIGHT - WALL_GAP_MAX - WALL_MIN_HEIGHT * 2
WALL_SPEED :: 120
WALL_COUNT :: 6

GRAVITY: f32 : 6
JUMP_STRENGTH: f32 : 1400

Game_State :: enum {
    menu,
    playing,
    game_over,
}

bounds :: [2]rl.Rectangle {
    {x = 0, y = 0, width = WINDOW_WIDTH, height = 16},
    {x = 0, y = WINDOW_HEIGHT - 16, width = WINDOW_WIDTH, height = 16},
}

game_state: Game_State

player_rect: rl.Rectangle
player_velocity: f32
player_score: int

walls: [WALL_COUNT]rl.Rectangle
walls_cleared: [WALL_COUNT / 2]bool

Game_Memory :: struct {
    texture_atlas: rl.Texture2D,
    point_sound:   rl.Sound,
    fail_sound:    rl.Sound,
    elapsed_time:  f32,
    player_frame:  i32,
}
g_mem: ^Game_Memory

generate_obstacles :: proc(index: int) {
    top_wall := &walls[index]
    bottom_wall := &walls[index + 1]

    top_wall.x = WINDOW_WIDTH
    top_wall.y = 0
    top_wall.width = 50
    top_wall.height = f32(rl.GetRandomValue(WALL_MIN_HEIGHT, WALL_MAX_HEIGHT))

    bottom_wall.x = WINDOW_WIDTH
    bottom_wall.y = min(top_wall.height + f32(rl.GetRandomValue(WALL_GAP_MIN, WALL_GAP_MAX)), WINDOW_HEIGHT - WALL_MIN_HEIGHT)
    bottom_wall.width = 50
    bottom_wall.height = WINDOW_HEIGHT - bottom_wall.y

    walls_cleared[index / 2] = false
}

restart_game :: proc() {
    player_rect = rl.Rectangle {
        x      = WINDOW_WIDTH / 3,
        y      = WINDOW_HEIGHT / 2 - 25,
        width  = atlas_textures[.Owl0].rect.width,
        height = atlas_textures[.Owl0].rect.height,
    }
    player_velocity = 0
    player_score = 0

    for i := 0; i < WALL_COUNT; i += 2 {
        generate_obstacles(i)

        // Override the initial position of the walls to ensure they are generated with gaps.
        walls[i].x = f32(WINDOW_WIDTH + (WINDOW_WIDTH / WALL_COUNT) * i)
        walls[i + 1].x = f32(WINDOW_WIDTH + (WINDOW_WIDTH / WALL_COUNT) * i)
    }

    for i := 0; i < WALL_COUNT / 2; i += 1 {
        walls_cleared[i] = false
    }

    game_state = .playing
}

update :: proc() {
    delta_time: f32 = 1.0 / 60.0
    g_mem.elapsed_time += delta_time

    if g_mem.elapsed_time > 0.2 {
        g_mem.elapsed_time = 0
        g_mem.player_frame += 1
        g_mem.player_frame = g_mem.player_frame % 3
    }

    if game_state == .menu {
        if rl.IsKeyReleased(rl.KeyboardKey.SPACE) {
            restart_game()
        }
        return
    } else if game_state == .game_over {
        if rl.IsKeyReleased(rl.KeyboardKey.R) {
            game_state = .menu
        }
        return
    }

    for i := 0; i < WALL_COUNT; i += 2 {
        top_wall := &walls[i]
        bottom_wall := &walls[i + 1]

        top_wall.x -= 100 * delta_time
        bottom_wall.x -= 100 * delta_time

        if rl.CheckCollisionRecs(player_rect, top_wall^) || rl.CheckCollisionRecs(player_rect, bottom_wall^) {
            rl.PlaySound(g_mem.fail_sound)
            game_state = .game_over
        }

        if top_wall.x + top_wall.width < player_rect.x && !walls_cleared[i / 2] {
            player_score += 1
            walls_cleared[i / 2] = true
            rl.PlaySound(g_mem.point_sound)
        }

        if top_wall.x + top_wall.width <= 0 {
            generate_obstacles(i)
        }
    }

    for bound in bounds {
        if rl.CheckCollisionRecs(player_rect, bound) {
            rl.PlaySound(g_mem.fail_sound)
            game_state = .game_over
        }
    }

    player_acceleration := GRAVITY

    if rl.IsKeyReleased(rl.KeyboardKey.SPACE) {
        player_acceleration -= JUMP_STRENGTH
    }

    player_velocity += player_acceleration
    player_velocity = clamp(player_velocity, -JUMP_STRENGTH / 4, JUMP_STRENGTH / 4)
    player_rect.y += player_velocity * delta_time
}

draw :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground({150, 190, 220, 255})

    switch game_state {
    case .menu:
        text_size := rl.MeasureText("Press Space to Start", 20)
        rl.DrawText(
            rl.TextFormat("Press Space to Start"),
            WINDOW_WIDTH / 2 - text_size / 2,
            WINDOW_HEIGHT / 2 - 10,
            20,
            rl.WHITE,
        )
    case .playing:
        for bound in bounds {
            rl.DrawRectangleRec(bound, rl.BLUE)
        }
        for wall in walls {
            rl.DrawRectangleRec(wall, rl.BLUE)
        }

        // Draw the player frame
        texture := atlas_textures[Texture_Name(i32(Texture_Name.Owl0) + g_mem.player_frame)]
        rl.DrawTexturePro(g_mem.texture_atlas, texture.rect, player_rect, {0, 0}, 0, rl.WHITE)

        rl.DrawText(rl.TextFormat("Score: %d", player_score), 10, 20, 20, rl.WHITE)
    case .game_over:
        text_size := rl.MeasureText("Game Over", 32)
        rl.DrawText(rl.TextFormat("Game Over"), WINDOW_WIDTH / 2 - text_size / 2, WINDOW_HEIGHT / 2 - 10, 32, rl.WHITE)

        text_size = rl.MeasureText(rl.TextFormat("Score: %d", player_score), 20)
        rl.DrawText(
            rl.TextFormat("Score: %d", player_score),
            WINDOW_WIDTH / 2 - text_size / 2,
            WINDOW_HEIGHT / 2 + 30,
            20,
            rl.WHITE,
        )

        text_size = rl.MeasureText("Press R to return to menu", 20)
        rl.DrawText(
            rl.TextFormat("Press R to return to menu"),
            WINDOW_WIDTH / 2 - text_size / 2,
            WINDOW_HEIGHT / 2 + 80,
            20,
            rl.WHITE,
        )
    }
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
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Flappy Bird")
    rl.InitAudioDevice()
    rl.SetTargetFPS(300)
}

@(export)
game_init :: proc() {
    g_mem = new(Game_Memory)

    g_mem^ = Game_Memory {
        texture_atlas = rl.LoadTexture("assets/atlas.png"),
        point_sound   = rl.LoadSound("assets/sfx/point.wav"),
        fail_sound    = rl.LoadSound("assets/sfx/fail.wav"),
        elapsed_time  = 0,
        player_frame  = 0,
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
