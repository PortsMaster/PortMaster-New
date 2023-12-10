#!/bin/bash

source /etc/profile

cd /storage/roms/ports/billyfrontier/

./billyfrontier | tee ./log.txt
