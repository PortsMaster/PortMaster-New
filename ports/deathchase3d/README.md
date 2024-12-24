## Notes
Thanks to [Paul Robson](https://web.archive.org/web/20140918142844/http://www.robsons.org.uk/archive/www.autismuk.freeserve.co.uk/deathchase3d-0.9.tar.gz) for creating this game and making it available for free!

## Controls

| Button | Action |
|--|--| 
|DPAD| Drive|
|A/B | Shoot|


## Compile

```shell
git clone https://gitlab.com/osgames/deathchase3d.git
cd deathchase3d/
./configure --build=aarch64-unknown-linux-gnu
add -lm to deathchase/Makefile
`LIBS =  -L/usr/lib/aarch64-linux-gnu -lSDL -lm
make
```

