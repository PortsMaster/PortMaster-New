#!/bin/bash

. /etc/profile

jslisten set "-9 Nanosaur2"

cd /storage/roms/ports/nanosaur2/

./Nanosaur2 | tee ./log.txt
