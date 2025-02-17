@echo off

set EXE_NAME="frogger"

set TYPE=%1

pushd bin
.\%EXE_NAME%_%TYPE%.exe
popd
