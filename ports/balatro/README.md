# Balatro PortMaster

Port of the super popular and addictive [poker-inspired roguelike deck builder Balatro](https://www.playbalatro.com/).

The port requires you to own a version of Balatro on Steam (either macOS or Windows is fine).


## Installation instructions

- Install the port from PortMaster
- Generate the `Balatro.love` game file.

### Here is how you can generate Balatro.love:

#### on macOS

The file is under `~/Library/Application Support/Steam/steamapps/common/Balatro/Balatro.app/Contents/Resources` (if you don't know how to navigate there, go to Steam > Right Click on Balatro > Manage > Browse Local File. Then in the `Balatro.app` package, right click > Show Package Contents > then go to Contents/Resources).

#### on Windows

You need to find the game's .exe file (Steam > Right Click on Balatro > Manage > Browse Local File). Use [7-Zip](https://www.7-zip.org/), right click > extract the .exe file. Then inside the folder with a bunch of .lua file, re-zip the content of the folder (but not the root folder itself, just the content). Rename the output zip into `Balatro.love` (note the capital B since portmaster runs on Linux which is case sensitive).


## Advanced Instructions

You can further modify the games code, by extracting the `Balatro.love` file, change the content, then repackage (note: always repackage the content, not the root folder)

### Switch A / B or X / Y buttons

Under `globals.lua` find the line and switch to TRUE/FALSE depending on your preferences:

```
    self.F_SWAP_AB_PIPS = true             --Swapping button pips for A and B buttons (mainly for switch)
    self.F_SWAP_AB_BUTTONS = true          --Swapping button function for A and B buttons (mainly for switch)
    self.F_SWAP_XY_BUTTONS = true          --Swapping button function for X and Y buttons (mainly for switch)
```

### Scale the content up and down

Under `globals.lua`, around line 220, change the TILE_W and TILE_H. The smaller it is, the more zoomed in the UI is. The default is 20.

For example: more zoomed in value of 16.5 is good for the RGB30:
```
    self.TILE_W = 16.5
    self.TILE_H = 16.5
```

If the UI got swished / overlapped, you can change the location of content under `functions/common_events.lua`.