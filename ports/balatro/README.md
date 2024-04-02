# Balatro PortMaster

Port of the super popular and addictive [poker-inspired roguelike deck builder Balatro](https://www.playbalatro.com/).

The port requires you to own a version of Balatro on Steam (either macOS or Windows is fine).

## Installation instructions

- Buy the game from [Steam](https://store.steampowered.com/app/2379780/Balatro/).
- Install the port from PortMaster.
- Find the `Balatro.love` (on Mac) or `Balatro.exe` (on Windows) game file.

### Here is how you can find the game file:

#### on macOS

The file is under `~/Library/Application Support/Steam/steamapps/common/Balatro/Balatro.app/Contents/Resources` (if you don't know how to navigate there, go to Steam > Right Click on Balatro > Manage > Browse Local File. Then in the `Balatro.app` package, right click > Show Package Contents > then go to Contents/Resources). You should see the file `Balatro.love` game file there. Drop the file under `ports/balatro` folder of PortMaster.

#### on Windows
You need to find the game's .exe file (Steam > Right Click on Balatro > Manage > Browse Local File). Simply copy the Balatro.exe file into the `balatro` folder under `ports/balatro` folder of PortMaster.


## Note

This PortMaster script automatically patches the Balatro game files to make them suitable for small devices. Upon patching, the file `Balatro.love` or `Balatro.exe` will be updated and have their extension removed to `Balatro`.

Some of the patches include:

For devices < 1280px in width:
- Increasing the scaling.
- Replace the font with the open font Nunito (Black Variant) for visibility.
- Disable CRT, Shadow, and reduce Background animation effect for performance and visibility.
- Specifically on RGB30: move the items around for best visibility.

If you would like to bypass the patch, simply change your game file from `Balatro.love` or `Balatro.exe` to just `Balatro`.