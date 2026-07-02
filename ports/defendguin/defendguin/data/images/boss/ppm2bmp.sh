#!/bin/bash

# Convert boss PPMs (from povray) to BMPs for libSDL;
# also, convert solid black to solid white, for transparency masking

# Bill Kendrick
# bill@newbreedsoftware.com
# http://www.newbreedsoftware.com/

for i in `ls *.ppm`; do
  o=`basename $i .ppm`.bmp
  echo "$i => $o"
  ppmchange "rgbi:0/0/0" "rgbi:1/1/1" $i | ppmtobmp > $o
  rm $i
done

