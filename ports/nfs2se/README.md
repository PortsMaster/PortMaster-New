## Notes
Thanks to [Błażej Szczygieł](https://github.com/zaps166/NFSIISE) for creating this wrapper and making it available for free! 
 
## Controls

| Button | Action |
|--|--| 
|A| Accelerate|
|B| Brake|
|Y| Hand Brake|
|L1| Shift Down |
|R1| Shift Up |
|L2| Camera View |
|R2| Horn |

## Compile

```shell
git clone https://github.com/zaps166/NFSIISE.git
modify src/Wrapper.c to if (SDL_Init(SDL_INIT_EVERYTHING & ~(SDL_INIT_JOYSTICK | SDL_INIT_GAMECONTROLLER)) < 0)
./compile_nfs cpp gles2
```