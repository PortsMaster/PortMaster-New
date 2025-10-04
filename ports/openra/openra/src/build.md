## Build instructions

1. Follow the [PortMaster instructions](https://portmaster.games/build-environments.html) to create a chroot build environment.

2. Additionally, you're going to need the dotnet SDK, which you can download from [here](https://builds.dotnet.microsoft.com/dotnet/Sdk/8.0.413/dotnet-sdk-8.0.413-linux-arm64.tar.gz)

Untar it to any location, e.g. /opt/dotnet, then make sure you export the path before you build OpenRA:
```
export DOTNET_ROOT=/opt/dotnet
export PATH=$PATH:/opt/dotnet
```

3. Clone the OpenRA repository

```
git clone https://github.com/OpenRA/OpenRA
```

4. Apply the openra-base and openra-gui patch files, which are based on the following commit:

```
commit 8a0197c88b8ef6145d2ec6e4211bf9f87afb7af1 (HEAD -> bleed, origin/bleed, origin/HEAD)
Author: Rampoina <rampoina@protonmail.com>
Date:   Mon Jul 21 22:24:10 2025 +0200

    Make AttackMoveInfo public

```

The base patch has changes which are necessary to make it work in various CFWs.

The GUI patch has UI yaml updates, to have a usable menu system when playing with low resolution devices (e.g. 640x480). Before applying this patch, you should make a copy of the affected yaml files, which are overwritten by the patch, because the original yaml files work great with high resolution screens. The launch script takes care of swapping out the yaml files to match the current resolution. For this to work, we need 2 sets of the yaml files: one for high resolution screens (src/mods_highres), which are essentially the unmodified stock yaml files, and one for low resolution screens (src/mods_lowres). However, we don't need to replicate everything, just the following:
* chrome directory (where it exists)
* chrome.yaml (where it exists)
* mod.yaml (where it exists)

Basically, it goes like this:
* copy the mods folder from the OpenRA build to ports/openra/game
* make a copy of chrome directory, chrome.yaml, and mod.yaml, to src/mods_highres, preserving the directory hieararchy
* apply the GUI patch
* copy the same files again, but this time to src/mods_lowres

Examine the content of these folders to better understand the structure of the files.

Most of the work of editing the yaml files is a trial-and-error. Launch the game, see how things look, and if something is rendered off-screen, you are going to need to find the corresponding section in one of the yaml files, and mess around with the "X", "Y", "Width" and "Height" settings, until it looks usable in low resolution.

5. Build the code

```
make prefix=/opt/openra_build TARGETPLATFORM=linux-arm64
make prefix=/opt/openra_build TARGETPLATFORM=linux-arm64 install
```

More details can be found [here](https://github.com/OpenRA/OpenRA/wiki/Compiling)

6. When the build is done, copy everything from /opt/openra_build/lib/openra to the ports/openra/game, with a few exceptions:

* DO NOT COPY SDL2.so!!
* you can skip all of the .pdb and .config files
* IP2LOCATION-LITE-DB1.IPV6.BIN.ZIP is also not needed

## Adding mods

OpenRA was created as a generic RTS game engine, and there are many mods written for it. Check [moddb](https://www.moddb.com/games/openra/mods) for a comprehensive list of available mods.

Adding new mods is relatively simple, however, they are developed for specific versions of the OpenRA engine, and they may not work with the OpenRA version we are shipping. To bridge the gap, we keep the mod binaries separate from the main OpenRA binaries, in the ports/openra/src/mods_bin folder. We also need a copy of any common engine binaries for the base OpenRA build in ports/openra/src/mods_bin/openra, since they may be overwritten by the mod's own engine files. Example common binaries:
* OpenRA.Game.dll
* OpenRA.Game.deps.json
* OpenRA.Mods.Cnc.dll
* OpenRA.Mods.Cnc.deps.json
* OpenRA.Mods.Common.dll
* OpenRA.Mods.Common.deps.json
* OpenRA.Platforms.Default.dll
* OpenRA.Platforms.Default.deps.json

The mod specific binaries are automatically copied to ports/openra/game by the launcher, before starting the mod, but make sure that the name of the folder under mods_bin matches the codename of the mod.

Keep in mind that by default, even the mods are assuming a high resolution screen, and often rely on the base OpenRA common settings, with some mod-specific tweaks. This means that you're going to need to edit the yaml files and create a low resolution version for each mod, as described in the previous section.

Finally, if a mod does not work with the base OpenRA engine we are shipping, then make sure to apply the openra_base.patch to the mod's engine files, otherwise the game may not work in the supported CFWs. Additional changes may be necessary, and you'll have to debug the mod as you go, if the mod does not work properly. For example, the engine changes over time regarding how the yaml files are consumed, some thing might get added/removed, etc. You may need to copy some of the yaml files from the mod's engine's "mods/common/chrome" directory, and update the mod's mod.yaml to refer to its own version instead of the common one, otherwise the game might crash for reasons like it cannot find a label, widget, or something that changed upstream and not yet adapted to by the mod. See Generals Alpha mod below, for example, which needs a tooltip.yaml file from its engine/mods/common/chrome.

Besides log.txt, OpenRA logs its own console messages under ports/openra/conf/Logs (e.g. graphics.log). It may be useful for debugging.

#### Mod: OpenHV (Hard Vacuum)

Build it with the following steps:

1. Clone the mod repository separately from OpenRA, e.g.:

```
git clone https://github.com/OpenHV/OpenHV
```

2. Apply the openra-base patch in the OpenHV/engine directory, to ensure that the mod works with all supported CFWs

3. The OpenHV mod has its own GUI patch file (included in the src directory), which was applied on top of the following commit:

```
commit 3ab3638df2dac83fffefcdf8da6f90e26c13f82b (HEAD -> main, origin/main, origin/HEAD)
Author: Dzierzan <dzierzan.12111994@gmail.com>
Date:   Fri Aug 1 22:18:43 2025 +0200

    Adjusted offsets for `default-minimap` cursor.

    Closes #1371

```

Apply this patch in the OpenHV repository's root.

4. Build and install the game

```
make prefix=/opt/openhv_build TARGETPLATFORM=linux-arm64
make prefix=/opt/openhv_build TARGETPLATFORM=linux-arm64 install
```

5. When the build is done, copy the following files from /opt/openhv_build/lib/openhv to ports/openra/src/mods_bin/hv:

* OpenRA.Game.dll
* OpenRA.Game.deps.json
* OpenRA.Mods.Common.dll
* OpenRA.Mods.Common.deps.json
* OpenRA.Mods.HV.dll
* OpenRA.Mods.HV.deps.json
* OpenRA.Platforms.Default.deps.json
* OpenRA.Platforms.Default.dll
* SmartIrc4net.dll

6. Copy mods/hv to the ports/openra/game/mods directory as well

#### Mod: Generals Alpha

Build it with the following steps:

1. Clone the mod repository separately from OpenRA, e.g.:

```
git clone https://github.com/MustaphaTR/Generals-Alpha
```

2. Apply the openra-base patch in the Generals-Alpha/engine directory, to ensure that the mod works with all supported CFWs

3. The Generals-Alpha mod has its own GUI patch file (included in the src directory), which was applied on top of the following commit:

```
commit 2f960c46210cf0c1ebcbd6eaaf6076521ca96145 (HEAD -> master, tag: gen-20250825, origin/master, origin/HEAD)
Author: Mustafa Alperen Seki <mustafaoyunda37@gmail.com>
Date:   Mon Aug 25 13:30:21 2025 +0300

    Remove mono stuff from Mac Packaging files.

```

Apply this patch in the Generals-Alpha repository's root.

4. Build the game

```
make prefix=/opt/gen_build TARGETPLATFORM=linux-arm64
```

5. When the build is done, copy the following files from /opt/Generals-Alpha/engine/bin to ports/openra/src/mods_bin/gen:

* OpenRA.Game.dll
* OpenRA.Game.deps.json
* OpenRA.Mods.AS.dll
* OpenRA.Mods.AS.deps.json
* OpenRA.Mods.Cnc.dll
* OpenRA.Mods.Cnc.deps.json
* OpenRA.Mods.Common.dll
* OpenRA.Mods.Common.deps.json
* OpenRA.Mods.GenSDK.dll
* OpenRA.Mods.GenSDK.deps.json
* OpenRA.Platforms.Default.deps.json
* OpenRA.Platforms.Default.dll

6. Copy mods/gen and mods/gen-content to the ports/openra/game/mods directory as well

7. This mod does not have a 3x upscaled icon file, but it's needed by the game launcher. The missing icon is included in the src directory, called gen-icon-3x.png. Copy it to ports/openra/game/mods/gen as icon-3x.png.

## Packaging

Unfortunately, due to the large number of asset files some of the mods have, it takes longer than the ~3 minutes allowed by the PortMaster installer to install the game (i.e. it times out and PortMaster crashes). Because of this, the "game" directory needs to be zipped and shipped as a single file, located in the src directory. The included patchscript takes care of unzipping the game files on first run.

Unless we can find a better solution (e.g. eliminate or increase the installer timer), we can't ship the game files unzipped.