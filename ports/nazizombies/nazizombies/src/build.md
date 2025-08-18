## Build instructions

If you wish to build your own binary, follow these steps. Skip 1-2 if you are building for a CFW with an older glibc (e.g. ArkOS, which has glibc version 2.30)

1. install the docker image from here: https://hub.docker.com/r/motolegacy/fteqw
   ```
   docker pull motolegacy/fteqw
   ```

2. run docker:
   ```
   docker run --privileged -it --name nzp motolegacy/fteqw bash
   ```

3. clone the engine:
   ```
   cd /usr/games && git clone https://github.com/nzp-team/fteqw nzp && cd nzp/engine
   ```

4. there are 2 patch files included in this directory:

- initlibc.patch: this is needed on all devices, to avoid an "Out of memory" crash on launch
- gl_vidsdl.patch: this is needed for devices with older glibc, otherwise SDL_CreateWindow() fails with an error

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

5. build the game:
   ```
   export CC=aarch64-linux-gnu-gcc
   export STRIP=aarch64-linux-gnu-strip
   make makelibs FTE_TARGET=SDL2 && make m-rel FTE_TARGET=SDL2 FTE_CONFIG=nzportable -j4
   ```

6. copy the binary from /usr/games/nzp/engine/release/nzportable-sdl2 to your device, into ports/nazizombies/game/nzp-sdl (overwrite if it already exists), and make sure it's executable
