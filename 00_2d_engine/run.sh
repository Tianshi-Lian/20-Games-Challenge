#!/bin/bash

EXE_NAME=engine

TYPE=$1

pushd bin >/dev/null
./${EXE_NAME}_${TYPE}
popd >/dev/null
