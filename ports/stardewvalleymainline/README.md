## Notes

Thanks to the [MonoGame](https://github.com/MonoGame/MonoGame) project for the framework that's used to make this possible.
Thanks to JohnnyonFlame for the original Stardew Valley PortMaster work and all the help.
Mainline port work by Producdevity.

## Instructions

You must have a copy of the current regular/mainline Steam release of Stardew Valley.

1. **Install the regular/mainline Steam build of Stardew Valley.**
   1. In your Steam library, right click “Stardew Valley”.
   2. Select “Properties”.
   3. Open the “Betas” tab.
   4. Make sure the game is not opted into the compatibility beta.
   5. Let Steam finish updating the game.

2. **Install Stardew Valley Mainline via PortMaster**
   1. Open the PortMaster app
   2. Choose All Ports
   3. Navigate to Stardew Valley Mainline
   4. Press A to install
   5. Exit PortMaster

3. **Copy Stardew Valley game data to your Ports folder**
   1. Plug in your SD card into your SD card reader on your computer
   2. Navigate to `ports/stardewvalleymainline/gamedata`
   3. Open your Steam installation folder for Stardew Valley
   4. Copy every file in your Stardew Valley install directory to `/ports/stardewvalleymainline/gamedata`
   5. Do not delete or overwrite the other files from the PortMaster package. The port will patch the copied game data automatically on launch.

4. **Optional and experimental: add SMAPI mods**
   1. Leave `ports/stardewvalleymainline/Mods` empty if you want vanilla mainline Stardew Valley.
   2. Copy your SMAPI mods into `ports/stardewvalleymainline/Mods`.
   3. Do not put user mods into `gamedata/Mods`.
   4. SMAPI is included with this port and starts automatically when user mods are present.
   5. Removing user mods returns the port to vanilla mode. (Or rename `Mods` to `Mods.disabled` to toggle between vanilla and modded modes.)

5. **Play the game**
   1. Plug SD card back into your device
   2. Explore content and go to ports
   3. Run Stardew Valley Mainline
