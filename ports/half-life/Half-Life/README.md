# Half-Life / Blue Shift / Opposing Forces


This is the configuration files and the required steps to build the xash3d engine for handheld emulator devices (Anbernic RG353V, etc.) using the Portmaster scripts for launching.


# Installation

To play **Half-Life** you need to copy over the `valve` folder from your steam install of [Half-Life](https://store.steampowered.com/app/70/HalfLife/) into `ports/Half-Life/valve`, on first run it will override the required files to run.

To play **Half-Life: Blue Shift** you need to have Half-Life installed, then copy over the `bshift` folder from your steam install of [Half-Life: Blue Shift](https://store.steampowered.com/app/130/HalfLife_Blue_Shift/) into `ports/Half-Life/bshift`, on first run it will override the required files to run, and create a `Half-Life Blue Shift.sh` in your ports directory.

To play **Half-Life: Opposing Forces** you need to have Half-Life installed, then copy over the `gearbox` folder from your steam install of [Half-Life: Opposing Forces](https://store.steampowered.com/app/50/HalfLife_Opposing_Force/) into `ports/Half-Life/gearbox`, on first run it will override the required files to run, and create a `Half-Life Opposing Fores.sh` in your ports directory.

_Note: Currently it doesnt matter if you use Windows, Linux or MacOS versions of the game. On MacOS it will state that the games are incompatible if you have a newer OS, that doesnt matter, install it anyway._

# Controls


- Left Analog: Move/Strafe
- Right Analog: Look
- A_BUTTON: Use
- B_BUTTON: Jump
- X_BUTTON: Flashlight
- Y_BUTTON: Reload
- L1: Crouch
- L2: Walk
- R1: Fire
- R2: Alt-Fire
- DPAD_UP: Spray
- DPAD_LEFT: Last Weapon
- DPAD_RIGHT: Next Weapon
- DPAD_DOWN: Quick Swap
- Start: Pause
- Select + X: Menu
- Select + L1: Quick Load
- Select + R1: Quick Save
- Select + B: Screenshot
- Select + Start: Quit


## Build Environment


I currently use docker to build it, this is optional

    git clone --recursive https://github.com/RetroGFX/UnofficialOS.git


add "libfontconfig1-dev" to the Dockerfile, as it is the one missing dependancy

    make docker-image-build


My UnofficialOS & Half Life stuff is currently in `~/Half-Life`, so to run the docker image I do:


    docker run  -it --init --env-file .env --rm --user 1000:1000  -v $HOME/Half-Life:$HOME/Half-Life -w $HOME/Half-Life  "justenoughlinuxos/jelos-build:latest" bash


## Building

    git clone --recursive https://github.com/FWGS/hlsdk-portable.git
    git clone --recursive https://github.com/FWGS/xash3d-fwgs.git

    # Build main engine
    cd xash3d-fwgs

    ## requires --enable-static-gl to work.
    ./waf configure -T release --enable-gles2 --enable-static-gl
    ./waf clean
    ./waf build
    ./waf install --destdir=../build

    cd ..

    cd hlsdk-portable

    # Half-Life client files
    git checkout master
    ./waf configure -T release --64bit
    ./waf clean
    ./waf build
    ./waf install --destdir=../build

    # Blue shift client files
    git checkout bshift
    ./waf configure -T release --64bit
    ./waf clean
    ./waf build
    ./waf install --destdir=../build

    # Opforce client files
    git checkout opfor
    ./waf configure -T release --64bit
    ./waf clean
    ./waf build
    ./waf install --destdir=../build

    cd ..


At the end all the binary stuff is in `build`.

Finally run `./build.py` to combine the compiled files in `build` with the script/config files suitable for Portmaster distribution.

# TODO:

- [x] Add launch scripts for Blue Shift / Opposing Forces to the ports directory when they're detected.
- [ ] Consolidate the autoexe.cfg / config.cfg / opengl.cfg files.
- [ ] Better installation instructions
- [x] Build a more robust build setup
- [ ] Add support for counterstrike 1.6
