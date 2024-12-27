package main

import "core:c/libc"

main :: proc() {
    libc.system("pushd .. &&exec.bat")
}
