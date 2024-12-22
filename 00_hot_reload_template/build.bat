@echo off

set TYPE=%1
set GAME_RUNNING=false
set EXE=game_hot_reload.exe

if not exist build (
	mkdir build
)
if not exist pdbs (
	mkdir pdbs
)
if not exist build\assets (
	mkdir build\assets
)

if "%TYPE%" == "dbg" (
	odin build src/release_exe -out:build/game_debug.exe -strict-style -vet -debug
)
if "%TYPE%" == "rel" (
	odin build src/release_exe -out:build/game_release.exe -strict-style -vet -no-bounds-check -o:speed -subsystem:windows
)
if "%TYPE%" == "rld" (
    call build_hot_reload.bat
)
xcopy /s /d assets\ build\assets\
