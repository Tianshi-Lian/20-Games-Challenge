@echo off

set TYPE=%1
set GAME_RUNNING=false
set EXE=game_hot_reload.exe
set BUILD_PARAMS=-strict-style -vet-using-stmt -vet-using-param -vet-style -vet-semicolon

if not exist build (
	mkdir build
)
if not exist pdbs (
	mkdir pdbs
)
if not exist build\assets (
	mkdir build\assets
)

pushd tools
call build.bat
popd

if "%TYPE%" == "dbg" (
    call tools\atlas_builder\atlas_builder.exe
    call tools\file_version_builder\file_version_builder.exe
	odin build src/release_exe -out:build/game_debug.exe %BUILD_PARAMS% -vet -debug
)
if "%TYPE%" == "rel" (
    call tools\atlas_builder\atlas_builder.exe
    call tools\file_version_builder\file_version_builder.exe
	odin build src/release_exe -out:build/game_release.exe %BUILD_PARAMS% -vet -no-bounds-check -o:speed -subsystem:windows
)
if "%TYPE%" == "rld" (
    call build_hot_reload.bat
)
xcopy /s /d /A /Y assets\ build\assets\
