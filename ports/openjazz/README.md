## Notes


Thanks to [AlisterT](https://github.com/AlisterT/openjazz) for creating the opensource port that makes this possible.  Also thanks to [Jetup13](https://github.com/Jetup13/openjazz-oga) for the porting work for portmaster.


## Compile

```shell
git clone https://github.com/AlisterT/openjazz.git
cd openjazz
- Place Makefile.sdl2 from this port into the openjazz directory or manually edit makefile to use SDL2 instead of SDL1.2
- remove SDL_INIT_JOYSTICK from src/main.cpp
make -f Makefile.sdl2
strip OpenJazz
```
