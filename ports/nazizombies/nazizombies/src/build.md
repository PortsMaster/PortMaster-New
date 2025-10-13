## Build instructions for aarch64 using [WSL chroot environment](https://github.com/Cebion/Portmaster_builds)

1. clone the engine:

   ```
   git clone https://github.com/nzp-team/fteqw nzp
   cd nzp/engine
   ```

2. apply the included small patch file, which addresses 3 problems:

   * avoid an "out of memory" crash on launch
   * fix SDL window creation with older glibc version
   * allow invert pitch when using game controllers (the engine supports mouse only)

   These changes were made on top of the following commit of the fteqw engine:

   ```
   commit 1d0b3976d6c6fd7aa503387185984dfc28406555 (HEAD -> master, tag: bleeding-edge, origin/master, origin/HEAD)
   Author: Peter0x44 <peter0x44@disroot.org>
   Date:   Sat Apr 19 19:29:22 2025 +0100

       Add hack abstraction to make mouse IDs sequential

       SDL3 (and therefore sdl2-compat) changed mouse IDs from being seuqential
       (so they could be used as an index) to effectively random. We have to
       hack over an abstraction for this ourselves to make it work.

       Lol!

       fixes https://github.com/nzp-team/nzportable/issues/1131
   ```

3. build the game:

   ```
   export CC=aarch64-linux-gnu-gcc
   export STRIP=aarch64-linux-gnu-strip
   make makelibs FTE_TARGET=SDL2 && make m-rel FTE_TARGET=SDL2 FTE_CONFIG=nzportable -j4
   ```

4. copy the binary from engine/release/nzportable-sdl2 to ports/nazizombies/game/nzp-aarch64-sdl. If you are replacing an existing build on a device where you already played the game, then copy it to ports/nazizombies/game/nzp-sdl as well. Make sure it's executable.

## Build instructions for armhf

1. install the docker image from here: https://hub.docker.com/r/motolegacy/fteqw

   ```
   docker pull motolegacy/fteqw
   ```

2. run docker:

   ```
   docker run --privileged -it --name nzp motolegacy/fteqw bash
   ```

3. follow steps 1-2 from the aarch64 build section, to clone the engine and apply the patch

4. build

   ```
   export CC=arm-linux-gnueabihf-gcc
   export STRIP=arm-linux-gnueabihf-strip
   make makelibs FTE_TARGET=SDL2 && make m-rel FTE_TARGET=SDL2 FTE_CONFIG=nzportable -j4
   ```

5. copy the binary from engine/release/nzportable-sdl2 to ports/nazizombies/game/nzp-armhf-sdl. If you are replacing an existing build on a device where you already played the game, then copy it to ports/nazizombies/game/nzp-sdl as well. Make sure it's executable.
