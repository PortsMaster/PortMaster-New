# VanillaTD

Vanilla Conquer is a fully portable version of the first generation C&C engine and is capable of running both Tiberian Dawn and Red Alert on multiple platforms. It can also be used for mod development for the Remastered Collection.

The main focus of Vanilla Conquer is to keep the default out-of-box experience faithful to what the games were back when they were released and work as a drop-in replacement for the original executables while also providing bug fixes, compatiblity and quality of life improvements.

# Controls

| Button            | Command                     |
|-------------------|-----------------------------|
| **A**             | Mouse Left                  |
| **B**             | Mouse Right                 |
| **X**             | Stop                        |
| **Y**             | Guard                       |
| **L1**            | Force attack                |
| **L2**            | Add to selection            |
| **R1**            | Slow down mouse             |
| **R2**            | Scatter                     |
| **Select + L1**   | Select next unit            |
| **Select + L2**   | Select everything on screen |
| **Select + R1**   | Show/Hide sidebar           |
| **Select + R2**   | Center screen on selection  |
| **Start**         | Enter                       |
| **Select**        | Menu                        |
| **D-Pad Up**      | Group 1                     |
| **D-Pad Right**   | Group 2                     |
| **D-Pad Down**    | Group 3                     |
| **D-Pad Left**    | Group 4                     |
| **Left Analog**   | Mouse Movement              |
| **Right Analog**  | Move screen                 |

# Game Settings

## RG351V/MP RG353V/M/P Settings:

For 640x480 full screen (slightly stretched) change `ports/vanillatd/save/vanillatd/conquer.ini`:

```
[Video]
Windowed=no
DOSMode=no
BoxingAspectRatio=4:3
Width=640
Height=480
Scaler=linear
```

## RG552 Settings:

```
[Video]
BoxingAspectRatio=5:3
Windowed=no
Width=1920
Height=1152
```

To enable the original DOS graphics change `DOSMode=no` to `DOSMode=yes`.

__Thanks to [Snoopy](https://github.com/Roughtrade) for figuring out these options__

# Game folder structure

The game comes with the demo files, to install the full version you will need to place the game files from the [following guide](https://github.com/TheAssemblyArmada/Vanilla-Conquer/wiki/Installing-VanillaTD) into `ports/vanillatd/data/vanillatd`.

The resulting install should have the below structure:

```
ports/vanillatd/data/vanillatd
├─ covertops/
│  ├─ GENERAL.MIX
│  ├─ MOVIES.MIX
│  ├─ SCORES.MIX
├─ gdi/
│  ├─ GENERAL.MIX
│  ├─ MOVIES.MIX
│  ├─ SCORES.MIX
├─ nod/
│  ├─ GENERAL.MIX
│  ├─ MOVIES.MIX
│  ├─ SCORES.MIX
├─ CCLOCAL.MIX
├─ CONQUER.MIX
├─ DESEICNH.MIX
├─ DESERT.MIX
├─ LOCAL.MIX
├─ SC-000.MIX
├─ SC-001.MIX
├─ SOUNDS.MIX
├─ SPEECH.MIX
├─ TEMPERAT.MIX
├─ TEMPICNH.MIX
├─ TRANSIT.MIX
├─ UPDATE.MIX
├─ UPDATEC.MIX
├─ WINTER.MIX
├─ WINTICNH.MIX
```

## Building

    git clone https://github.com/TheAssemblyArmada/Vanilla-Conquer.git

    git apply DATA_PATHS.diff

    mkdir build

    cd build

    cmake .. -DCMAKE_BUILD_TYPE=Debug

    make -j4

    strip vanilla*

You will then have `vanillara` & `vanillatd`

# TODO:

- [x] Get game to work.
- [x] Get expansions to work.
- [x] Figure out controls - Thanks Snoopy! :)
- [x] Test it on AmberELEC
- [x] Test it on ArkOS

# Thanks

A special thanks to the excellent folks on the [AmberELEC discord](https://discord.com/invite/R9Er7hkRMe), especially [Snoopy](https://github.com/Roughtrade) and [Cebion](https://github.com/Cebion) for all the testing.