// This file is generated by running the atlas_builder.
package game

/*
Note: This file assumes the existence of a type Rect that defines a rectangle in the same package, it can defined as:

	Rect :: rl.Rectangle

or if you don't use raylib:

	Rect :: struct {
		x, y, width, height: f32,
	}

or if you want to use integers (or any other numeric type):

	Rect :: struct {
		x, y, width, height: int,
	}

Just make sure you have something along those lines the same package as this file.
*/

TEXTURE_ATLAS_FILENAME :: "assets/texture_atlas.png"
ATLAS_FONT_SIZE :: 32
LETTERS_IN_FONT :: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890?!&.,_:[]-+"

// A generated square in the atlas you can use with rl.SetShapesTexture to make
// raylib shapes such as rl.DrawRectangleRec() use the atlas.
SHAPES_TEXTURE_RECT :: Rect {648, 17, 10, 10}

Texture_Name :: enum {
	None,
	Test,
}

Atlas_Texture :: struct {
	rect: Rect,
	// These offsets tell you how much space there is between the rect and the edge of the original document.
	// The atlas is tightly packed, so empty pixels are removed. This can be especially apparent in animations where
	// frames can have different offsets due to different amount of empty pixels around the frames.
	// In many cases you need to add {offset_left, offset_top} to your position. But if you are
	// flipping a texture, then you might need offset_bottom or offset_right.
	offset_top: f32,
	offset_right: f32,
	offset_bottom: f32,
	offset_left: f32,
	document_size: [2]f32,
	duration: f32,
}

atlas_textures: [Texture_Name]Atlas_Texture = {
	.None = {},
	.Test = { rect = {0, 0, 276, 276}, offset_top = 0, offset_right = 0, offset_bottom = 0, offset_left = 0, document_size = {276, 276}, duration = 0.000},
}

Animation_Name :: enum {
	None,
}

Tag_Loop_Dir :: enum {
	Forward,
	Reverse,
	Ping_Pong,
	Ping_Pong_Reverse,
}

// Any aseprite file with frames will create new animations. Also, any tags
// within the aseprite file will make that that into a separate animation.
Atlas_Animation :: struct {
	first_frame: Texture_Name,
	last_frame: Texture_Name,
	document_size: [2]f32,
	loop_direction: Tag_Loop_Dir,
	repeat: u16,
}

atlas_animations := [Animation_Name]Atlas_Animation {
	.None = {},
}

// All these are pre-generated so you can save tile IDs to data without
// worrying about their order changing later.
Tile_Id :: enum {
	T0Y0X0,
	T0Y0X1,
	T0Y0X2,
	T0Y0X3,
	T0Y0X4,
	T0Y0X5,
	T0Y0X6,
	T0Y0X7,
	T0Y0X8,
	T0Y0X9,
	T0Y1X0,
	T0Y1X1,
	T0Y1X2,
	T0Y1X3,
	T0Y1X4,
	T0Y1X5,
	T0Y1X6,
	T0Y1X7,
	T0Y1X8,
	T0Y1X9,
	T0Y2X0,
	T0Y2X1,
	T0Y2X2,
	T0Y2X3,
	T0Y2X4,
	T0Y2X5,
	T0Y2X6,
	T0Y2X7,
	T0Y2X8,
	T0Y2X9,
	T0Y3X0,
	T0Y3X1,
	T0Y3X2,
	T0Y3X3,
	T0Y3X4,
	T0Y3X5,
	T0Y3X6,
	T0Y3X7,
	T0Y3X8,
	T0Y3X9,
	T0Y4X0,
	T0Y4X1,
	T0Y4X2,
	T0Y4X3,
	T0Y4X4,
	T0Y4X5,
	T0Y4X6,
	T0Y4X7,
	T0Y4X8,
	T0Y4X9,
	T0Y5X0,
	T0Y5X1,
	T0Y5X2,
	T0Y5X3,
	T0Y5X4,
	T0Y5X5,
	T0Y5X6,
	T0Y5X7,
	T0Y5X8,
	T0Y5X9,
	T0Y6X0,
	T0Y6X1,
	T0Y6X2,
	T0Y6X3,
	T0Y6X4,
	T0Y6X5,
	T0Y6X6,
	T0Y6X7,
	T0Y6X8,
	T0Y6X9,
	T0Y7X0,
	T0Y7X1,
	T0Y7X2,
	T0Y7X3,
	T0Y7X4,
	T0Y7X5,
	T0Y7X6,
	T0Y7X7,
	T0Y7X8,
	T0Y7X9,
	T0Y8X0,
	T0Y8X1,
	T0Y8X2,
	T0Y8X3,
	T0Y8X4,
	T0Y8X5,
	T0Y8X6,
	T0Y8X7,
	T0Y8X8,
	T0Y8X9,
	T0Y9X0,
	T0Y9X1,
	T0Y9X2,
	T0Y9X3,
	T0Y9X4,
	T0Y9X5,
	T0Y9X6,
	T0Y9X7,
	T0Y9X8,
	T0Y9X9,
}

atlas_tiles := #partial [Tile_Id]Rect {
}

Atlas_Glyph :: struct {
	rect: Rect,
	value: rune,
	offset_x: int,
	offset_y: int,
	advance_x: int,
}

atlas_glyphs: []Atlas_Glyph = {
	{ rect = {658, 1, 13, 15}, value = 'A', offset_x = 0, offset_y = 8, advance_x = 12},
	{ rect = {770, 1, 11, 15}, value = 'B', offset_x = 2, offset_y = 8, advance_x = 13},
	{ rect = {373, 1, 12, 17}, value = 'C', offset_x = 1, offset_y = 7, advance_x = 12},
	{ rect = {744, 1, 11, 15}, value = 'D', offset_x = 2, offset_y = 8, advance_x = 13},
	{ rect = {897, 1, 9, 15}, value = 'E', offset_x = 2, offset_y = 8, advance_x = 11},
	{ rect = {886, 1, 9, 15}, value = 'F', offset_x = 2, offset_y = 8, advance_x = 11},
	{ rect = {387, 1, 12, 17}, value = 'G', offset_x = 1, offset_y = 7, advance_x = 13},
	{ rect = {783, 1, 11, 15}, value = 'H', offset_x = 2, offset_y = 8, advance_x = 14},
	{ rect = {930, 1, 2, 15}, value = 'I', offset_x = 2, offset_y = 8, advance_x = 5},
	{ rect = {612, 1, 9, 16}, value = 'J', offset_x = 0, offset_y = 8, advance_x = 10},
	{ rect = {835, 1, 11, 15}, value = 'K', offset_x = 2, offset_y = 8, advance_x = 13},
	{ rect = {919, 1, 9, 15}, value = 'L', offset_x = 2, offset_y = 8, advance_x = 10},
	{ rect = {673, 1, 13, 15}, value = 'M', offset_x = 2, offset_y = 8, advance_x = 16},
	{ rect = {848, 1, 11, 15}, value = 'N', offset_x = 2, offset_y = 8, advance_x = 14},
	{ rect = {344, 1, 13, 17}, value = 'O', offset_x = 1, offset_y = 7, advance_x = 14},
	{ rect = {874, 1, 10, 15}, value = 'P', offset_x = 2, offset_y = 8, advance_x = 12},
	{ rect = {285, 1, 14, 20}, value = 'Q', offset_x = 1, offset_y = 7, advance_x = 14},
	{ rect = {861, 1, 11, 15}, value = 'R', offset_x = 2, offset_y = 8, advance_x = 12},
	{ rect = {359, 1, 12, 17}, value = 'S', offset_x = 0, offset_y = 7, advance_x = 12},
	{ rect = {730, 1, 12, 15}, value = 'T', offset_x = 0, offset_y = 8, advance_x = 12},
	{ rect = {484, 1, 12, 16}, value = 'U', offset_x = 1, offset_y = 8, advance_x = 14},
	{ rect = {688, 1, 12, 15}, value = 'V', offset_x = 0, offset_y = 8, advance_x = 11},
	{ rect = {638, 1, 18, 15}, value = 'W', offset_x = 0, offset_y = 8, advance_x = 17},
	{ rect = {716, 1, 12, 15}, value = 'X', offset_x = 0, offset_y = 8, advance_x = 11},
	{ rect = {702, 1, 12, 15}, value = 'Y', offset_x = -1, offset_y = 8, advance_x = 10},
	{ rect = {757, 1, 11, 15}, value = 'Z', offset_x = 1, offset_y = 8, advance_x = 12},
	{ rect = {981, 1, 9, 13}, value = 'a', offset_x = 1, offset_y = 11, advance_x = 11},
	{ rect = {414, 1, 11, 17}, value = 'b', offset_x = 1, offset_y = 7, advance_x = 12},
	{ rect = {970, 1, 9, 13}, value = 'c', offset_x = 1, offset_y = 11, advance_x = 10},
	{ rect = {439, 1, 10, 17}, value = 'd', offset_x = 1, offset_y = 7, advance_x = 12},
	{ rect = {947, 1, 10, 13}, value = 'e', offset_x = 1, offset_y = 11, advance_x = 11},
	{ rect = {462, 1, 8, 17}, value = 'f', offset_x = 0, offset_y = 6, advance_x = 6},
	{ rect = {315, 1, 11, 18}, value = 'g', offset_x = 1, offset_y = 11, advance_x = 11},
	{ rect = {576, 1, 10, 16}, value = 'h', offset_x = 1, offset_y = 7, advance_x = 12},
	{ rect = {633, 1, 3, 16}, value = 'i', offset_x = 1, offset_y = 7, advance_x = 5},
	{ rect = {278, 1, 5, 21}, value = 'j', offset_x = -1, offset_y = 7, advance_x = 5},
	{ rect = {588, 1, 10, 16}, value = 'k', offset_x = 1, offset_y = 7, advance_x = 11},
	{ rect = {478, 1, 4, 17}, value = 'l', offset_x = 1, offset_y = 7, advance_x = 5},
	{ rect = {992, 1, 16, 12}, value = 'm', offset_x = 1, offset_y = 11, advance_x = 18},
	{ rect = {992, 15, 10, 12}, value = 'n', offset_x = 1, offset_y = 11, advance_x = 12},
	{ rect = {934, 1, 11, 13}, value = 'o', offset_x = 1, offset_y = 11, advance_x = 12},
	{ rect = {401, 1, 11, 17}, value = 'p', offset_x = 1, offset_y = 11, advance_x = 12},
	{ rect = {427, 1, 10, 17}, value = 'q', offset_x = 1, offset_y = 11, advance_x = 12},
	{ rect = {1004, 15, 7, 12}, value = 'r', offset_x = 1, offset_y = 11, advance_x = 7},
	{ rect = {959, 1, 9, 13}, value = 's', offset_x = 0, offset_y = 11, advance_x = 9},
	{ rect = {623, 1, 8, 16}, value = 't', offset_x = 0, offset_y = 8, advance_x = 7},
	{ rect = {1010, 1, 10, 12}, value = 'u', offset_x = 1, offset_y = 12, advance_x = 12},
	{ rect = {965, 16, 11, 11}, value = 'v', offset_x = 0, offset_y = 12, advance_x = 10},
	{ rect = {934, 16, 16, 11}, value = 'w', offset_x = 0, offset_y = 12, advance_x = 16},
	{ rect = {978, 16, 10, 11}, value = 'x', offset_x = 0, offset_y = 12, advance_x = 10},
	{ rect = {498, 1, 11, 16}, value = 'y', offset_x = 0, offset_y = 12, advance_x = 10},
	{ rect = {638, 18, 9, 11}, value = 'z', offset_x = 0, offset_y = 12, advance_x = 9},
	{ rect = {908, 1, 9, 15}, value = '1', offset_x = 1, offset_y = 8, advance_x = 11},
	{ rect = {822, 1, 11, 15}, value = '2', offset_x = 0, offset_y = 8, advance_x = 11},
	{ rect = {563, 1, 11, 16}, value = '3', offset_x = 0, offset_y = 8, advance_x = 11},
	{ rect = {809, 1, 11, 15}, value = '4', offset_x = 0, offset_y = 8, advance_x = 11},
	{ rect = {511, 1, 11, 16}, value = '5', offset_x = 0, offset_y = 8, advance_x = 11},
	{ rect = {600, 1, 10, 16}, value = '6', offset_x = 1, offset_y = 8, advance_x = 11},
	{ rect = {796, 1, 11, 15}, value = '7', offset_x = 0, offset_y = 8, advance_x = 11},
	{ rect = {550, 1, 11, 16}, value = '8', offset_x = 0, offset_y = 8, advance_x = 11},
	{ rect = {524, 1, 11, 16}, value = '9', offset_x = 0, offset_y = 8, advance_x = 11},
	{ rect = {537, 1, 11, 16}, value = '0', offset_x = 0, offset_y = 8, advance_x = 11},
	{ rect = {451, 1, 9, 17}, value = '?', offset_x = 0, offset_y = 7, advance_x = 9},
	{ rect = {472, 1, 4, 17}, value = '!', offset_x = 1, offset_y = 7, advance_x = 6},
	{ rect = {328, 1, 14, 17}, value = '&', offset_x = 0, offset_y = 7, advance_x = 13},
	{ rect = {660, 18, 4, 4}, value = '.', offset_x = 1, offset_y = 20, advance_x = 5},
	{ rect = {1019, 15, 4, 7}, value = ',', offset_x = 1, offset_y = 20, advance_x = 5},
	{ rect = {675, 18, 11, 2}, value = '_', offset_x = 0, offset_y = 24, advance_x = 11},
	{ rect = {1013, 15, 4, 12}, value = ':', offset_x = 1, offset_y = 12, advance_x = 5},
	{ rect = {301, 1, 5, 20}, value = '[', offset_x = 2, offset_y = 7, advance_x = 6},
	{ rect = {308, 1, 5, 20}, value = ']', offset_x = 0, offset_y = 7, advance_x = 6},
	{ rect = {666, 18, 7, 3}, value = '-', offset_x = 0, offset_y = 16, advance_x = 6},
	{ rect = {952, 16, 11, 11}, value = '+', offset_x = 0, offset_y = 10, advance_x = 11},
}
