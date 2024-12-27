package main

import "core:os"

FileVersion :: struct {
	path: string,
	modification_time: os.File_Time,
}

file_versions := []FileVersion {
	{ path = "D:\\Development\\Projects\\20-Games-Challenge\\01_flappy_bird\\assets\\textures\\owl0.png", modification_time = 133797889855890935 },
	{ path = "D:\\Development\\Projects\\20-Games-Challenge\\01_flappy_bird\\assets\\textures\\owl1.png", modification_time = 133797889747231250 },
	{ path = "D:\\Development\\Projects\\20-Games-Challenge\\01_flappy_bird\\assets\\textures\\owl2.png", modification_time = 133797889605643700 },
	{ path = "D:\\Development\\Projects\\20-Games-Challenge\\01_flappy_bird\\assets\\textures\\test.png", modification_time = 133797717600573724 },
}

