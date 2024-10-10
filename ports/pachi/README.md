## Notes
Thanks to [Santiago Radeff](https://sourceforge.net/projects/dragontech/) for creating this game and making it available for free!

## Controls

| Button | Action |
|--|--| 
|DPAD| Move|
|A | Jump|


## Compile

```shell
wget https://sourceforge.net/projects/dragontech/files/Pachi%20el%20marciano/Pachi%20el%20marciano%201.0/pachi_source.tgz
tar xf pachi_source.tgz
./configure
// change datapaths in Makefiles and config.h to .
make
```

Remove joystick init in init.c
```
    if(SDL_Init(SDL_INIT_AUDIO|SDL_INIT_VIDEO) < 0)

//     have_joystick = SDL_NumJoysticks();
//    fprintf(stderr, "%i joysticks were found.\n", have_joystick );
//     if (have_joystick)
//     {                                                        
// 	SDL_JoystickEventState(SDL_ENABLE);                                  
// 	joystick = SDL_JoystickOpen(0);                                      
//     }   
```