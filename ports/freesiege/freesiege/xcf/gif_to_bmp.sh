#!/bin/bash

convert $1 -format png $2%02d
for a in `ls $2??`; do
convert $a -background magenta -flatten +matte $a.bmp
done
rm $2??
