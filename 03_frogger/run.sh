#!/bin/bash

EXE_NAME=frogger

TYPE=$1

pushd bin
./${EXE_NAME}_${TYPE}
popd
