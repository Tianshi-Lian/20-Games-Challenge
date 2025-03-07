#!/bin/bash

EXE_NAME=frogger

TYPE=$1

if [ $TYPE=="" ]; then
    TYPE="dbg"
fi

pushd bin
./${EXE_NAME}_${TYPE}
popd
