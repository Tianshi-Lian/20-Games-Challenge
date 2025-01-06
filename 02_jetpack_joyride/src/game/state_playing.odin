package game

import rl "vendor:raylib"

GRAVITY :: 400
PLAYER_FORCE :: 500

BULLET_SPAWN_RATE :: 0.1
BULLET_SPEED :: 800

ENEMY_SPAWN_RATE :: 0.001
ENEMY_SPEED_MIN :: 300
ENEMY_SPEED_MAX :: 600

BULLET_COUNT :: 32
SOLDIER_COUNT :: 10
PLANE_COUNT :: 6
ENTITY_COUNT :: BULLET_COUNT + SOLDIER_COUNT + PLANE_COUNT

Entity_Type :: enum {
    Bullet,
    Soldier,
    Plane,
}

Transform :: struct #raw_union {
    _v:      [4]f32,
    using _: struct {
        position: rl.Vector2,
        size:     rl.Vector2,
    },
    using _: struct {
        x, y, w, h: f32,
    },
    rect:    rl.Rectangle,
}

Entity :: struct {
    type:         Entity_Type,
    active:       bool,
    transform:    Transform,
    acceleration: rl.Vector2,
    texture_rect: rl.Rectangle,
}

player_animation: Sprite_Animation = animation_create(.Jetpack_Floor_Run)
background: Atlas_Texture = atlas_textures[.Sky_Color]

bullet_reset :: proc(entity: ^Entity) {
    entity.type = .Bullet
    entity.active = false
    entity.transform.position = {g_mem.player.x + g_mem.player.width / 2 - 12.5, g_mem.player.y}
    entity.transform.size = {25, 25}
    entity.acceleration = {f32(rl.GetRandomValue(-100, 100)), BULLET_SPEED}
}

soldier_reset :: proc(entity: ^Entity) {
    entity.type = .Soldier
    entity.active = false
    entity.transform.size = {75, 75}
    entity.transform.position = {WINDOW_WIDTH, g_mem.bounds[1].y - entity.transform.w}
    entity.acceleration = {-f32(rl.GetRandomValue(ENEMY_SPEED_MIN, ENEMY_SPEED_MAX)), 0}
}

plane_reset :: proc(entity: ^Entity) {
    plane_color := rl.GetRandomValue(0, 2)
    texture_rect := atlas_textures[Texture_Name(i32(Texture_Name.Plane_1_Blue) + plane_color)].rect

    entity.type = .Plane
    entity.active = false
    entity.transform.size = {texture_rect.width, texture_rect.height}
    entity.transform.position = {WINDOW_WIDTH, f32(rl.GetRandomValue(100, WINDOW_HEIGHT - 100 - i32(entity.transform.h)))}
    entity.acceleration = {-f32(rl.GetRandomValue(ENEMY_SPEED_MIN, ENEMY_SPEED_MAX)), 0}
    entity.texture_rect = {texture_rect.x, texture_rect.y, -texture_rect.width, texture_rect.height}
}

state_playing_init :: proc(state: ^Game_Memory) {
    g_mem.player = rl.Rectangle{100, 700, 100, 100}
    g_mem.bounds[0] = rl.Rectangle{0, 0, WINDOW_WIDTH, 50}
    g_mem.bounds[1] = rl.Rectangle{0, WINDOW_HEIGHT - 50, WINDOW_WIDTH, 50}

    for &entity, index in g_mem.entities {
        if index < BULLET_COUNT {
            bullet_reset(&entity)
            g_mem.bullets[index] = &entity
        } else if index < BULLET_COUNT + SOLDIER_COUNT {
            soldier_reset(&entity)
            g_mem.soldiers[index - BULLET_COUNT] = &entity
        } else {
            plane_reset(&entity)
            g_mem.planes[index - BULLET_COUNT - SOLDIER_COUNT] = &entity
        }
    }
}

state_playing_update :: proc() {
    delta_time := rl.GetFrameTime()

    g_mem.score_timer += delta_time
    if g_mem.score_timer > 1 {
        g_mem.score_timer = 0
        g_mem.score += 1
    }

    random_spawner := rl.GetRandomValue(0, 400)
    if random_spawner == 0 {
        for &entity in g_mem.soldiers {
            if !entity.active {
                entity.active = true
                break
            }
        }
    } else if random_spawner < 3 {
        for &entity in g_mem.planes {
            if !entity.active {
                entity.active = true
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
                    bullet.transform.y = g_mem.player.y
                    bullet.active = true
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
            entity.transform.position += entity.acceleration * delta_time

            if entity.transform.x + abs(entity.transform.w) < 0 {
                if entity.type == .Plane {
                    plane_reset(&entity)
                } else if entity.type == .Soldier {
                    soldier_reset(&entity)
                }
            }

            if entity.type == .Bullet {
                for &enemy in g_mem.soldiers {
                    if enemy.active {
                        if rl.CheckCollisionRecs(entity.transform.rect, enemy.transform.rect) {
                            soldier_reset(enemy)
                            bullet_reset(&entity)
                        }
                    }
                }

                if entity.transform.y > WINDOW_HEIGHT {
                    bullet_reset(&entity)
                }
            } else if entity.type == .Plane {
                if rl.CheckCollisionRecs(entity.transform.rect, g_mem.player) {
                    g_mem.game_state = .Gameover
                }
            }
        }
    }

    animation_update(&player_animation, delta_time)
}

state_playing_draw :: proc() {
    rl.DrawTexturePro(g_textures, background.rect, {0, 0, WINDOW_WIDTH, WINDOW_HEIGHT}, {0, 0}, 0, {255, 255, 255, 255})

    for b in g_mem.bounds {
        rl.DrawRectangleRec(b, {0, 0, 255, 255})
    }

    for entity in g_mem.entities {
        if entity.active {
            switch entity.type {
            case .Bullet, .Soldier:
                rl.DrawRectangleRec(entity.transform.rect, {200, 0, 0, 255}) // TODO: Different colours
            case .Plane:
                rl.DrawTextureRec(g_textures, entity.texture_rect, entity.transform.position, {255, 255, 255, 255})
            }
        }
    }

    animation_draw(g_textures, player_animation, {g_mem.player.x - 45, g_mem.player.y - 30})

    rl.DrawText(rl.TextFormat("Score: %d", g_mem.score), 10, 60, 20, {255, 255, 255, 255})
}
