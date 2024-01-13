#!/bin/bash

if [ ! -f 'port.json' ]; then
    echo "Must be run in a port directory."
    exit
fi

ZIP_NAME="../data/$(basename $(pwd)).data.zip"

rm -fv "${ZIP_NAME}"

for name in $(find . -type f -size +90M)
do
    zip -vu $ZIP_NAME "$name"
    rm -f "$name"
done
