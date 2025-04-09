## Notes
Thanks to the [Chris Mohler and Martin Gerhardy](http://www.caveproductions.org/) for creating this game and making it available for free!

## Controls

| Button | Action |
|--|--| 
|DPAD| Move|


## Compile

```shell
dget -u http://deb.debian.org/debian/pool/main/c/caveexpress/caveexpress_2.5.2-1.dsc
cd caveexpress-2.5.2/
mkdir build && cd build 

rewrite initControllerAndHaptic function in src/modules/gfx/SDLFrontend.cpp to: 

void SDLFrontend::initControllerAndHaptic ()
{
        // Log controller initialization attempt
        Log::info(LOG_GFX, "Controller initialization has been skipped.");

        // Immediately exit the function without initializing controllers or haptics
        return;
}

cmake .
make
```