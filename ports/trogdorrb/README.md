## Notes

Thanks to [Mode8fx](https://github.com/Mode8fx/Trogdor-Reburninated) for making this recreation of a classic game.


## Controls

| Button | Action |
|--|--| 
|Dpad and Joysticks|Move|
|Start|Start|
|A|Confirm|
|B|Back|
|Y|Change resolution|
|X|Change overlay|
|Select|Quit while paused|
|Start + Select|Force quit|


## Compile
Opdated scaling in on_open_and_close.cpp to allow it to work on 480x320 with a fix by slayer366 3rd line is new first 2 for reference:
        window = SDL_CreateWindow("Trogdor: Reburninated", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, DEFAULT_WIDTH, DEFAULT_HEIGHT, SDL_WINDOW_SHOWN);
        renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
        SDL_RenderSetLogicalSize(renderer, DEFAULT_WIDTH, DEFAULT_HEIGHT);


x86_64 had a sprite issue fixed with:
 In sprite_objects.cpp, replace line 111 with:
temp_sprite_single = SDL_CreateRGBSurface(0, single_srcrect.w, single_srcrect.h, 32, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000);


```shell
git clone https://github.com/Mode8fx/Trogdor-Reburninated.git
cd Trogdor-Reburninated/Trogdor-Reburninated
mkdir build
cd build
cmake ../ -DLINUX=ON
make
```
