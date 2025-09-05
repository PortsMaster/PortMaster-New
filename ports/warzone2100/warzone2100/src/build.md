## Build instructions

1. Follow the [PortMaster instructions](https://portmaster.games/build-environments.html) to create a chroot build environment.

2. Clone the Warzone2100 repository

```
git clone https://github.com/Warzone2100/warzone2100.git
```

3. Build the code

Follow the build instructions in the Warzone2100 README.md file.

Additionally, you will need to build libzip locally. To do that, clone the libzip repo somewhere:

```
git clone https://github.com/nih-at/libzip
```

Then follow the instruction in the libzip INSTALL.md file.

4. When the build is done, copy everything from the install dir to ports/warzone2100/game (basically the bin and shared folders).

Don't forget to run 'strip' on the binary to save some space!

## Patching

The port includes a patch file, which was created on top of the following commit:

```
commit 9dc499a1edf3266a8a43c8ab4b617109ed993f4c (HEAD -> master, origin/master, origin/HEAD)
Author: past-due <30942300+past-due@users.noreply.github.com>
Date:   Sun Aug 17 16:30:13 2025 -0400

    Improve comparePlacementPoints

    Add a tie-breaker if the manhattan distances are equal.

    Co-Authored-By: Pavel Solodovnikov <pavel.al.solodovnikov@gmail.com>

```

It fixes a few things, notable ones:
* some devices don't like having quotes in pragma checks in the shader code, and the game crashes (it would still launch to the main menu, so it's not immediately obvious). Luckily, it just checks OpenGL version, so the patch removes them
* OpenAL version below 1.20 has some issue setting HRTF (spacial audio) attribute, and the result is that audio won't work. Most CFWs have OpenAL versions higher than 1.19, except ArkOS. The patch skips configuring HRTF if the version is too low
* fix invisible cursor issue where westonpack crusty cursor is used, by rendering a small invisible widget. This is necessary because for some reason the cursor disappears unless there is at least 1 widget visible on the screen
