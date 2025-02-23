#!/bin/bash

EXE_NAME=frogger

TYPE=$1
BUILD_PARAMS="-strict-style -vet-using-stmt -vet-using-param -vet-style -vet-semicolon"

mkdir -p assets
mkdir -p bin/assets
mkdir -p bin-int

if [ $TYPE=="dbg" ]; then
    odin build src -out:"bin/${EXE_NAME}_${TYPE}" $BULD_PARAMS -vet -debug
fi
if [ $TYPE=="rel" ]; then
    odin build src -out:"bin/${EXE_NAME}_${TYPE}" $BULD_PARAMS -vet -no-bounds-check -o:speed
fi

cp -u -r assets bin/assets
