## Notes

Thanks to the wonderful developer akouzoukos for creating such a well crafted game.
https://gitea.com/akouzoukos/apotris
https://akouzoukos.com/apotris/


## Controls

| Button | Action |
|--|--|
| Dpad | Move Pieces |
| DPAD UP | Drop Piece |
| A/B | Rotate Piece |

## Compiling

```bash
wget https://raw.githubusercontent.com/devkitPro/general-tools/master/bin2s.c
gcc -o bin2s bin2s.c -D'PACKAGE_STRING="bin2s Version 1.0"'
cp bin2s /usr/bin/
git clone -b rgb30 https://gitea.com/akouzoukos/apotris.git
git submodule update --init --remote --force
make rgb30
```