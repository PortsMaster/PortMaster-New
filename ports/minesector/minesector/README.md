## MineSector

Pretty classic Minesweeper. Web Demo deployed [here](https://grassdne.github.io/minesector/)!

![game](example.png)

This uses only [SDL2](https://www.libsdl.org/) and extension libraries [SDL_image](https://wiki.libsdl.org/SDL_image/), [SDL_ttf](https://wiki.libsdl.org/SDL_ttf/), and [SDL_mixer](https://wiki.libsdl.org/SDL_mixer/).

Built with CMake (unfortunately).

## Quickstart
Install the appropriate auto-built binary from [latest release](https://github.com/grassdne/minesector/releases/latest).

For Windows: Run the .msi installer. You may need to get past Windows Defender. \
For MacOS: Use the .dmg package and do that weird Drag and Drop into Applications thing you do. The first time you go to open it right click -> Open -> Open. \
For RPM/DEB distros: Install the appropriate .rpm or .deb with your package manager (It should install dependencies). \
Other Unix: Build from source. See below.

## Unix Build from Source Code
1. Install SDL2 (minimum version 2.0.18), SDL_image, SDL_ttf, and SDL_mixer development packages (and basic build tools).

  ### Fedora:
  ```console
  sudo dnf install SDL2-devel SDL2_image-devel SDL2_ttf-devel SDL2_mixer-devel cmake
  ```
  ### MacOS [Homebrew](https://brew.sh/):
  ```console
  brew install sdl2 sdl2_image sdl2_ttf sdl2_mixer cmake
  ```
  ### Ubuntu 22.04:
  ```console
  sudo apt install libsdl2-dev libsdl2-ttf-dev libsdl2-mixer-dev libsdl2-image-dev cmake
  ```
  
2. Build source code
```console
git clone https://github.com/grassdne/minesector.git
cd minesector
./configure
make -j
```
./configure is currently equivalent to running `cmake -DCMAKE_BUILD_TYPE=Release`. To specify an installation location, set -DCMAKE_INSTALL_PREFIX in the configure step:
```console
./configure -DCMAKE_INSTALL_PREFIX=./build
```
The `-j` argument to `make` just tells make to run in parallel and is not required.
./configure may issue warnings on some distros like Ubuntu about not finding cmake configuration files for SDL2_ttf, SDL2_image, and SDL2_mixer but it should still work.

3. Install

### MacOS

On MacOS, CMake builds a .app package. Run it with:
```console
open MineSector.app
```
To install, run cpack to build a .dmg Drag and Drop.
```console
cpack
open minesector.dmg 
```

### Linux / other Unix

```console
sudo make install
```
To run the program without `make install`, you must set the MINERUNTIME environment variable to the source directory to tell MineSector where to find the assets. Inside the git repo:
```console
MINERUNTIME="" ./minesector
```
