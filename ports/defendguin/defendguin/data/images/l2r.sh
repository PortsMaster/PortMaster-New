#!/bin/sh

echo Converting left tux images to right tux images...

for i in 0 1 2 3 4 5 6 7
do
  echo $i
  bmptoppm tux/l${i}.bmp | pnmflip -lr | ppmtobmp > tux/r${i}.bmp
done
  