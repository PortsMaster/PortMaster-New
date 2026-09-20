#!/bin/sh

GAMEDIR=`dirname "$(readlink -f "$0")"`
cd "$GAMEDIR"

if [ $(uname -m | grep '64') ]; then
    "./bin64/Chowdren"
else
    "./bin32/Chowdren"
fi
