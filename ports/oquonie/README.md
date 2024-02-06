## Notes

Thanks to Rek & Devine for creating this wonderful game
https://hundredrabbits.itch.io/

Also special thanks for bhart for the intial start of the port and Cebion and Tabreturn for the finishing touches.

In this uxnemu version the sdl_init(joystick) has been disabled and mapped via gptokeyb.

## Controls

| Button | Action |
|--|--|
| Dpad | Move |

## Compiling UXN

```bash
git clone https://git.sr.ht/~rabbits/uxn
cd src
edit uxnemu.c to if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0)
cd ..
./build.sh