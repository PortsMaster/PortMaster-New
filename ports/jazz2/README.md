## Notes
Thanks to deathkiller's [Jazz² Resurrection](https://github.com/deathkiller/jazz2-native) project, to [orsonmmz](https://github.com/orsonmmz) for the original PortMaster port, and to [ImCoKeMaN](https://github.com/ImCoKeMaN) for the x86_64 version of the port.

## Controls
| Button | Action |
|--|--|
|D-Pad/Left Analog Stick|Movement| 
|A|Jump|
|B|Run|
|X|Shoot|
|Y|Switch Weapon|
|Start|Menu/Go Back|
|Start + Select|Exit Game|

This game uses **SDL** for controls. In the event that **ABXY** do not correspond to the expected buttons on your device/firmware, you may wish to change the in-game settings, or to make use of your firmware's options (ex.: [Knulli](https://knulli.org/play/basic-inputs/#switch-ab-and-xy-for-ports), [muOS](https://muos.dev/tour/modules/muxcontrol)).

## Compile
The aarch64 version was built using Cebion's [WSL2 chroot environment](https://github.com/Cebion/Portmaster_builds).
```shell
git clone https://github.com/deathkiller/jazz2-native.git
mkdir jazz2-native/build
cd jazz2-native/build
cmake -D CMAKE_BUILD_TYPE=Release -D NCINE_DOWNLOAD_DEPENDENCIES=OFF -D NCINE_PREFERRED_BACKEND=SDL2 -D NCINE_WITH_OPENGLES=ON -D NCINE_LINUX_PACKAGE=jazz2 -D NCINE_PACKAGED_CONTENT_PATH=ON ..
make -j $(nproc)
```

## Graphical Issues
Thanks to deathkiller, the known graphical issues—missing/flickering textures, both in-game and in the main menu—with certain TrimUI devices (e.g. Brick, Smart Pro) should be [fixed automatically upon detection of affected GPUs](https://github.com/deathkiller/jazz2-native/commit/f6b538b0a004204b7d3ce33c65b295b3286ad895). If similar issues are encountered with other devices, launching the game with the `/gpu-workaround fixed-batch-size` option *may* resolve them. Any similarly-affected GPUs should probably be reported.