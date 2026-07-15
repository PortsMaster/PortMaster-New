# Bully: Anniversary Edition package licenses and notices

This is a BYO-data PortMaster/NextOS package. It includes the Linux
compatibility loader, launcher, metadata, preview images and first-run setup
helpers. It does not include the APK, bundles, OBBs, `libGame.so`,
`libc++_shared.so`, data archives, audio, textures, models, maps, videos, saves
or other Rockstar game data.

## Game and game data

"Bully: Anniversary Edition" and its game data are property of Rockstar Games
and their respective rightsholders. The user must provide a legally obtained,
complete Android v1.4.311 copy. This package grants no right to redistribute
game code or assets.

## Port code

The compatibility loader and shims are derived from the
`nextos_ports_android` so-loader framework and are released under Apache-2.0
unless an individual source file states otherwise. The framework includes code
derived from mtojek's Apache-2.0 so-loader ports. See
`Apache-2.0.txt` and `Apache-2.0-NOTICE.txt`.

The indexed asset resolver includes work copyright (c) 2026
givethesourceplox under the MIT License. See `MIT-givethesourceplox.txt`.

## Bundled OpenAL Soft

`libopenal.so.1` is OpenAL Soft 1.21.1 and is dynamically linked. OpenAL Soft
is distributed under LGPL-2.1-or-later. See `LGPL-2.1-or-later.txt` for the
complete license and `openal-soft-LICENSE.txt` for corresponding source and
replacement information.

## System and PortMaster components

SDL2, EGL, GLES, libc, libm, libpthread and libdl are supplied by the target
system and are not bundled. `gptokeyb` is supplied by PortMaster when the
optional fallback is enabled; it is not included in this package.

## Preview images

The included `cover.png` and `screenshot.png` identify the port in
the frontend. They are not a substitute for the game and grant no right to
redistribute the original game assets.
