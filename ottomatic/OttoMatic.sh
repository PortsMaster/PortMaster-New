#!/bin/bash

source /etc/profile

cd /storage/roms/ports/ottomatic/

./OttoMatic | tee ./log.txt
