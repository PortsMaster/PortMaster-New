## Notes

Thanks to [sobomax](https://github.com/sobomax/digger) for the source.
Digger Remastered's source code has been contributed by different people and licensed under the terms of several licenses including Public Domain, Beer-Ware, 2-clause BSD and GNU General Public License version 2. Please refer to a specific source file as well as source code history to find out more.

Special thanks to Bamboozler and Cebion from Portmaster for the compile help!

## Controls

| Button | Action |
|--|--| 
|X|Pause Game|
|B/A/R1|Fire|
|Select|Title Screen|
|Start|Start Game|

## Compile

```shell
git clone https://github.com/sobomax/digger
cd digger
# Edit def.h
# Above the line with #include <stdint.h> add #include <SDL2/SDL.h>
# On line 87 with #define ININAME, replace getenv("HOME") with SDL_GetBasePath()
# Save changes
# Edit scores.c
# On line 56 with #define SFNAME, replace getenv("HOME") with SDL_GetBasePath()
# Save changes
# Edit GNUmakefile
# On line 6, remove -DDIGGER_DEBUG from the CFLAGS
# Save changes
make -j4
```