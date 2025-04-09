## Notes

A great multiplayer game brought to you by [Ronnie Hedlund](https://sourceforge.net/u/rh_galaxy/profile/). The source code is available [here.](https://sourceforge.net/p/galaxyv2/code/HEAD/tree/)

A 2D multiplayer space shooter, inspired by the Amiga classic Gravity Force. Play race, mission or dogfight. Single player, with friends or against AI. There are 50+ levels and a map-editor included.

Global hi-score and achievements with replays on the website.

Features

    Space shooter
    Multiplayer
    Online hiscore
    Replays
    Race
    Dogfight
    Mission
    AI
    Editor
    Cross platform



## Controls

| Button | Action |
|--|--| 
|A|Fire|
|B/Up|Thrust|
|X|Music On/Off|
|Y|Sound on/Off|
|L1|Left Mouse|
|L2|Right Mouse|
|R1|Mouse Slow|
|R2|Minimap On/Off|
|Stick 1|Mouse|


## Compile

```shell
cp SDL_sim_cursor.h galaxyv2_2.00_src/src/graph
cd galaxyv2_2.00_src
vim src/graph.h
Add this line after #include <SDL.h>
vim src/graph.h
#include "SDL_sim_cursor.h"
vim src/graph.cpp
Add this at top file
#define SDL_SIM_CURSOR_COMPILE 1

Add this just before SDL_Quit();
SDL_SIM_MouseQuit();

Add this after the SDL_INIT if statement
SDL_SIM_MouseInit();

Add SDL_SIm command after m_pRenderer
m_pRenderer = SDL_CreateRenderer(m_pWindow, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
SDL_SIM_Set_Renderer(m_pRenderer);

Add
//Update screen
SDL_SIM_RenderCursor(NULL);


vim src/common/global.cpp
Need to change line 220
change strcpy(szDataPath, ""); //not used/found 
to strcpy(szDataPath, "./"); //not used/found
```
