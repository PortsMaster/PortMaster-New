## Notes

Thanks to [NZ:P Team](https://docs.nzp.gay/) for the game.

Also thanks to the PortMaster team for all of the work they do.

## Detailed Instructions

The installer automatically takes care of setting up the game.

## Controls

The default controller mapping is pretty good, and you can change everything in the in-game settings (Configuration --> Controls --> Bindings).

Few notes:
- by default, the aim down sight is L2 and the fire is R2, which works well with devices with stacked shoulder and trigger buttons, but very awkward with in-line buttons. The installer changes the mapping to L1 and R1 respectively, in order to give a good out-of-the-box experience for everybody, but it is highly recommended to switch back to L2 and R2 if you have stacked buttons.
- some of the settings (e.g. sensitivity) has a slider, however, it only accepts mouse clicks. The dpad does not work with them. Press 'start' + 'a' to get a mouse pointer, and use the left analog stick and the 'a' button to change the value on the sliders. Press 'start' again when you're done, to exit from the mouse control mode.

If you need to enter text, for example, to change the name of the soldier, press 'select' + 'b' to enter text input mode. In that mode, the face buttons can be used to add/remove letters.

## Custom build

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

4. at the minimum, apply this patch, otherwise the game crashes with "Out of memory" error:

```
diff --git a/engine/qclib/initlib.c b/engine/qclib/initlib.c
index 70c36a9af..a837cd67b 100644
--- a/engine/qclib/initlib.c
+++ b/engine/qclib/initlib.c
@@ -552,8 +552,9 @@ static void PDECL PR_Configure (pubprogfuncs_t *ppf, size_t addressable_size, in
                addressable_size = 32*1024*1024;
 #endif
        }
-   if (addressable_size > 0x80000000)
-           addressable_size = 0x80000000;
+        #define MAX_ADDRESSABLE_SIZE (100 * 1024 * 1024)  // 100MB
+        if (addressable_size > MAX_ADDRESSABLE_SIZE)
+                addressable_size = MAX_ADDRESSABLE_SIZE;
        PRAddressableFlush(progfuncs, addressable_size);
        progfuncs->funcs.stringtable = prinst.addressablehunk;

```

Additionally, for older glibc, you need the following as well, otherwise SDL_CreateWindow() fails with an error

```
diff --git a/engine/gl/gl_vidsdl.c b/engine/gl/gl_vidsdl.c
index 6fa37dad9..258132140 100644
--- a/engine/gl/gl_vidsdl.c
+++ b/engine/gl/gl_vidsdl.c
@@ -386,12 +386,12 @@ static qboolean SDLVID_Init (rendererstate_t *info, unsigned char *palette, r_qr
                                (vid_gl_context_forwardcompatible.ival?SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG:0) |
                                0);

-           if (vid_gl_context_es.ival)
-                   SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
-           else if (vid_gl_context_compatibility.ival)
-                   SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_COMPATIBILITY);
-           else
-                   SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
+         //if (vid_gl_context_es.ival)
+         //  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
+         //else if (vid_gl_context_compatibility.ival)
+         //  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_COMPATIBILITY);
+         //else
+         //  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
        #endif
                if (info->multisample)
                {
```

Note: the above changes were made on top of the following commit of the fteqw engine:

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
