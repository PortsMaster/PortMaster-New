## Notes
Thanks to [Drinkbox Studios](https://www.gog.com/en/game/guacamelee_gold_edition) for making this awesome game!
Special thanks to kotzebuedog for solving a game-breaking bug

## Controls

Xbox Control Scheme (see Guacamelle Manual)

## Compile ARMHF Binaries

```shell
// Box86
git clone https://github.com/ptitSeb/box86.git
cd box86
mkdir build && cd build
cmake .. -DARM64=ON -DARM_DYNAREC=ON
make

// gl4es
git clone https://github.com/ptitSeb/gl4es.git
cd gl4es
mkdir build && cd build
cmake .. -DNOX11=ON -DGLX_STUBS=ON -DEGL_WRAPPER=ON -DGBM=ON
make
```