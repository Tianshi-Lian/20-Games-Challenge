@echo off

set EXE_NAME="engine"

set TYPE=%1
set BUILD_PARAMS=-strict-style -vet-using-stmt -vet-using-param -vet-style -vet-semicolon

if not exist bin (
    mkdir bin
)
if not exist bin-int (
    mkdir bin-int
)
if not exist bin\assets (
    mkdir bin\assets
)

if "%TYPE%" == "dbg" (
    odin build src -out:bin/%EXE_NAME%_%TYPE%.exe %BUILD_PARAMS% -vet -debug
)
if "%TYPE%" == "rel" (
    odin build src -out:bin/%EXE_NAME%_%TYPE%.exe %BUILD_PARAMS% -vet -no-bounds-check -o:speed -subsystem:windows
)

xcopy /s /d /A /Y assets\ bin\assets\
