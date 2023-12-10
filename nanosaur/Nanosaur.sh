#!/bin/bash

source /etc/profile

cd /storage/roms/ports/nanosaur/

./Nanosaur | tee ./log.txt
