package engine

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

import rl "vendor:raylib"

Tile_Set :: struct {
    name:     string,
    filepath: string,
    texture:  rl.Texture2D,
    tiles:    [dynamic]rl.Rectangle,
}

Tile_Map :: struct {
    width:     i32,
    height:    i32,
    tile_size: i32,
    tile_set:  Tile_Set,
    tiles:     [dynamic]i32,
}

tile_set_load :: proc(filepath: string, tile_size: i32) -> Tile_Set {
    result: Tile_Set = {
        filepath = filepath,
        texture  = rl.LoadTexture("assets/graphics/test_tileset.png"),
    }

    name, ok := strings.substring(filepath, strings.last_index(filepath, "/") + 1, strings.last_index(filepath, "."))
    if ok {
        result.name = name
    }

    width := result.texture.width / tile_size
    height := result.texture.height / tile_size

    for y in 0 ..< height {
        for x in 0 ..< width {
            texture_rect := rl.Rectangle{f32(x * tile_size), f32(y * tile_size), f32(tile_size), f32(tile_size)}
            append(&result.tiles, texture_rect)
        }
    }

    return result
}

tile_map_load :: proc(path: string) -> Tile_Map {
    result: Tile_Map = {}

    data, file_read := os.read_entire_file_from_filename(path)
    if !file_read {
        fmt.eprintln("Failed to load file ", path)
        return result
    }
    defer delete(data)

    tileset_path := ""
    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        fields := strings.fields(line)
        // TODO: Error handling on bad input
        if len(fields) > 1 {
            switch fields[0] {
            case "t":
                tileset_path = strings.clone(fields[1])
            case "s":
                num, ok := strconv.parse_int(fields[1])
                if ok {
                    result.tile_size = i32(num)
                }

                num, ok = strconv.parse_int(fields[2])
                if ok {
                    result.width = i32(num)
                }

                num, ok = strconv.parse_int(fields[3])
                if ok {
                    result.height = i32(num)
                }
            case "d":
                for tile in fields {
                    if tile == "d" do continue
                    num, ok := strconv.parse_int(tile)
                    if ok {
                        append(&result.tiles, i32(num))
                    }
                }
            }
        }
    }

    result.tile_set = tile_set_load(tileset_path, result.tile_size)

    return result
}

main :: proc() {
    rl.InitWindow(1600, 900, "Engine")
    defer rl.CloseWindow()

    tilemap := tile_map_load("assets/test_level.tm")
    fmt.println(tilemap.width)
    fmt.println(tilemap.height)
    fmt.println(tilemap.tile_size)
    fmt.println(len(tilemap.tiles))
    fmt.println(tilemap.tile_set.name)
    fmt.println(tilemap.tile_set.filepath)
    fmt.println(len(tilemap.tile_set.tiles))

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground(rl.RAYWHITE)

        for i in 0 ..< i32(len(tilemap.tiles)) {
            x_pos := (i % tilemap.width) * tilemap.tile_size
            y_pos := (i32(i / tilemap.width) * tilemap.tile_size)
            rl.DrawTextureRec(
                tilemap.tile_set.texture,
                tilemap.tile_set.tiles[tilemap.tiles[i]],
                rl.Vector2{f32(x_pos), f32(y_pos)},
                rl.WHITE,
            )
        }

        //rl.DrawTextureRec(tilemap.tile_set.texture, tilemap.tile_set.tiles[0], rl.Vector2{0, 0}, rl.WHITE)
        //rl.DrawTextureRec(tilemap.tile_set.texture, tilemap.tile_set.tiles[1], rl.Vector2{32, 0}, rl.WHITE)
        //rl.DrawTextureRec(tilemap.tile_set.texture, tilemap.tile_set.tiles[4], rl.Vector2{0, 32}, rl.WHITE)
    }
}
