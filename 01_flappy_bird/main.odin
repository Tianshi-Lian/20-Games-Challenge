package flappy_bird

import rl "vendor:raylib"

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
        width  = 50,
        height = 50,
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

update :: proc(delta_time: f32) {
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
            game_state = .game_over
        }

        if top_wall.x + top_wall.width < player_rect.x && !walls_cleared[i / 2] {
            player_score += 1
            walls_cleared[i / 2] = true
        }

        if top_wall.x + top_wall.width <= 0 {
            generate_obstacles(i)
        }
    }

    for bound in bounds {
        if rl.CheckCollisionRecs(player_rect, bound) {
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
        rl.DrawRectangleRec(player_rect, rl.RED)

        for bound in bounds {
            rl.DrawRectangleRec(bound, rl.BLUE)
        }
        for wall in walls {
            rl.DrawRectangleRec(wall, rl.BLUE)
        }

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
}

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Flappy Bird")
    defer rl.CloseWindow()

    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()

    rl.SetTargetFPS(300)

    game_state = .menu

    for !rl.WindowShouldClose() {
        delta_time: f32 = 1.0 / 60.0
        update(delta_time)

        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground({150, 190, 220, 255})

        draw()

        rl.DrawFPS(WINDOW_WIDTH - 100, 10)
    }
}
