#!/bin/bash

source /etc/profile

cd /storage/roms/ports/mightymike

./MightyMike | tee ./log.txt
