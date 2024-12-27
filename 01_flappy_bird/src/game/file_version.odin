package game

import "core:os"

FileVersion :: struct {
	path: string,
	modification_time: os.File_Time,
}

file_versions := []FileVersion {
	{ path = "D:\\Development\\Projects\\20-Games-Challenge\\01_flappy_bird\\assets\\textures\\owl.aseprite", modification_time = 133797965285157108 },
	{ path = "D:\\Development\\Projects\\20-Games-Challenge\\01_flappy_bird\\assets\\textures\\test.png", modification_time = 133797717600573724 },
}

