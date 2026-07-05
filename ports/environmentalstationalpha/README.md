## Credits
Thanks to [Arvi "*Hempuli*" Teikari](https://www.hempuli.com/) for creating ['*Environmental Station Alpha*'](https://www.hempuli.com/esa/), to the [`box64` project](https://github.com/ptitseb/box64), to [BinaryCounter](https://github.com/binarycounter) for the [Westonpack runtime](https://github.com/binarycounter/Westonpack/wiki) & [`libcrusty_inputblocker.so`](https://github.com/PortsMaster/PortMaster-New/blob/main/ports/tboirebirth/tboirebirth/libs.aarch64/libcrusty_inputblocker.so), and to the contributors of the [PortMaster project](https://github.com/PortsMaster).

## Installation
1. Purchase your copy of the game on [Steam](https://store.steampowered.com/app/350070/Environmental_Station_Alpha/).
2. Use the [Steam console](steam://open/console) to download the required version of the game with `download_depot 350070 350073 7502940888771481801`.
3. Copy all of the files from the depot into the `environmentalstationalpha/gamedata/` folder.
    * The resulting file/folder structure should look something like this:
        ```
        environmentalstationalpha/
        └── gamedata/
            ├── Assets.dat
            ├── Data/
            │   ├── 0-1.arr
            │   ├── <MANY MORE FILES HERE>
            │   └── ztesttileset.png
            ├── bin64/
            │   ├── Chowdren
            │   └── libsteam_api.so
            ├── gamecontrollerdb.txt
            ├── icon.bmp
            └── run.sh
        ```
4. Launch the game. The `gamedata` files will be relocated to their required locations on first launch. **Note that the game can take a bit of time to launch. It may take twenty seconds or more in some cases.**

## Controls
* ### Main Controls
    | **Button** | *Action* |
    |---|---|
    |**Left Analog Stick**|*Move*|
    |**D-Pad**|*Move*|
    |**A Button**|*Shoot* / *Menu Confirm*|
    |**B Button**|*Jump* / *Menu Cancel*|
    |**X** & **Y Buttons**|*Nothing* — available for configuration using the in-game settings (use the keyboard menu)|
    |**Start Button**|*Menu Confirm*|
    |**Select Button**|*Map*|
    |**Menu Button**|*Menu Cancel* / *Dialogue Skip*|
    |**L1 Button**|*Hookshot*|
    |**R1 Button**|*Dash*|
    |**L2/R2** & **L3/R3 Buttons**|*Nothing* — available for configuration using the in-game settings (use the keyboard menu)|
    |**Start + Menu Buttons**|Enter *Password Entry Mode*|
* ### Password Entry Mode
    At certain points within the game, you may find yourself needing to enter one or more passwords. In order to do so, you may hold the **Start Button** and then tap the **Menu Button** to switch to an alternative control scheme. In this mode, you may enter characters by using any of the following mappings. These mappings *attempt* to cover all of the required letters while also being *somewhat* memorable.
    * #### D-pad (*compass directions*)
        | **Button** | *Action* |
        |---|---|
        |**D-Pad Up**|Enter the Letter "*N*"|
        |**D-Pad Down**|Enter the Letter "*S*"|
        |**D-Pad Right**|Enter the Letter "*E*"|
        |**D-Pad Left**|Enter the Letter "*W*"|
    * #### ABXY (*self-explanatory*, watch out for potential issues as [mentioned below](#control-notes))
        | **Button** | *Action* |
        |---|---|
        |**A Button**|Enter the Letter "*A*"|
        |**B Button**|Enter the Letter "*B*"|
        |**X Button**|Enter the Letter "*X*"|
        |**Y Button**|Enter the Letter "*Y*"|
    * #### Shoulder Buttons (*L ➤ M & R ➤ S, alphabetically*)
        | **Button** | *Action* |
        |---|---|
        |**L1 Button**|Enter the Letter "*L*"|
        |**L2 Button**|Enter the Letter "*M*"|
        |**R1 Button**|Enter the Letter "*R*"|
        |**R2 Button**|Enter the Letter "*S*"|
    * #### Start & Select (*"Confirm" & "Option"*)
        | **Button** | *Action* |
        |---|---|
        |**Start Button**|Enter the Letter "*C*"|
        |**Select Button**|Enter the Letter "*O*"|
    * #### Menu (*"Mode"*)
        | **Button** | *Action* |
        |---|---|
        |**Menu Button**|Exit *Password Entry Mode*|

    For example, if you needed to enter the password "*SONAR*" into the game, you would:
    1. Enter the password entry control mode by holding **Start** and tapping **Menu**.
    2. Enter the password "*SONAR*" by tapping each of the following buttons, sequentially: **Down** (or ***R2***), **Select**, **Up**, **A**, **R1**.
    3. Exit the password entry control mode and return your controls to normal by tapping **Menu**.

    Note that you may also use an external keyboard in order to enter passwords.
* ### Control Notes
    This port uses [`gptokeyb2`](https://github.com/PortsMaster/gptokeyb2) for controls. The controls may be modified by:
    * using the keyboard controls section of the in-game settings menu.
    * editing `Chowdren.ini` and/or `savedata/ESA_Settings.txt`.

    In the event that **ABXY** do not correspond to the expected buttons on your device/firmware, you may wish to make use of your firmware's options (ex.: [Knulli](https://knulli.org/play/basic-inputs/#switch-ab-and-xy-for-ports), [muOS](https://muos.dev/tour/modules/muxcontrol)), or to modify the aforementioned game options.

## Issues
* This port may not perform well on RK3326 devices (e.g. Game Console R36S, BATLEXP G350), although it has been found to perform acceptably on some of them (e.g. GKD Pixel 2, Anbernic RG351M). Consequently—although *some* users may find it to be playable on such devices—it has been flagged as a `power` port.
    * This port may exhibit occasional slowdown even on less-underpowered devices (e.g. Anbernic RG-35XX H), but this is generally limited to only a few locations in the game (i.e. specific rooms in the forest area), and the game is otherwise quite playable.
* On the TrimUI Brick, minor graphical glitches have been observed in areas of the game (i.e. underwater areas, hot areas) which use a particular graphical warping effect. These glitches *may* also be seen on similar devices, such as the TrimUI Smart Pro.

## Shim
This port uses a preloaded shim (`libs.x64/esa-chowdren-shim.so`), which was written by ChatGPT. This shim has two features, which may be controlled via the following environment variables:
* `ESA_SHIM_FOCUS=1`: Enables an Xwayland startup workaround by hooking Chowdren's X11/GLX window creation path and sending early focus nudges which the game needs to actually start rendering and appear under Sway/Xwayland.
* `ESA_SHIM_SAVEDATA=1`: Redirects Chowdren's `~/MMFApplications` file activity into `./savedata`—beside the game binary—so saves and configuration stay local to the port folder.

The port's launch script sets `ESA_SHIM_FOCUS=1` and `SDL_VIDEODRIVER="x11"` when run on ROCKNIX with Panfrost drivers. There may be other firmware/device configurations which require these settings. In the event that this port fails to launch—specifically: if the game hangs when attempting to open a window—you may wish to experiment with manually setting the `ESA_SHIM_FOCUS` and/or `SDL_VIDEODRIVER` variables in the launch script.

A copy of the shim's source code has been included at `libs.x64/esa-chowdren-shim.c`, and further documentation regarding the shim may be found at `libs.x64/esa-chowdren-shim.md`.
