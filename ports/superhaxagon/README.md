# PortMaster Driver

This driver is intended for PortMaster builds. Learn more about PortMaster here:

https://portmaster.games/index.html

For additional instructions on different platforms, see the original README at:

https://github.com/RedTopper/Super-Haxagon

## Controls

The controls are shown on the title screen, but here's a copy if it's needed:

| Button | Action |
|--|--| 
|A|Select|
|B|Back|
|DPAD L, L1, L2, X|Rotate Left|
|DPAD R, R1, R2, Y|Rotate Right|
|Menu|Quit Game|

## Building

### Container Build:

The `monkeyx/retro_builder:arm64` container requires `qeumu-aarch64-static` for arm
emulation. This will not spin up a VM, but instead natively interpret the binaries
inside the docker container live. This is very similar to the "chroot" method, just
using Docker as the chroot instead.

(Note: If you are on an arm device, you do not need to use qeumu-aarch64-static)

With that said, I am using "podman" for building these images. Things should work
mostly the same, with the command `docker` swapped for `podman`.

These commands require root to enable the kernel flags for ARM emulation, but the
actual build will not require it.

```bash
sudo podman run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

At this point you may need to reboot your machine. Re-running the command to set
up qemu-user-static seems to break things.

```bash
podman run --rm --arch arm64 ubi9/ubi uname -m
```

If aarch64 printed out, you are good to go! You should now be able to build with:

```bash
podman-compose up PortMaster
```

### Other Build:

PortMaster has other build environments you can look into here:

https://portmaster.games/build-environments.html

Once you are in one of the above environments, you can build with the following commands:

```bash
mkdir build install
cd build
cmake -DDRIVER_PORTMASTER=TRUE -DCMAKE_INSTALL_PREFIX=../install ..
make -j4
make install
```

You can then zip the contents of the `install` folder and install it on your device.

## License

This driver follows the license scheme of the parent driver at `driver/SDL2`.
