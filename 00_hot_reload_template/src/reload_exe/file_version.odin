package main

import "core:os"

FileVersion :: struct {
	path: string,
	modification_time: os.File_Time,
}

file_versions := []FileVersion {
	{ path = "D:\\Development\\Projects\\20-Games-Challenge\\00_hot_reload_template\\assets\\textures\\test.png", modification_time = 133797717600573724 },
}

