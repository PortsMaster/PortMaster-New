## Notes

* For Steam:
    * On your PC, press Win+R and type: “steam://open/console” (Steam will now show console command)
    * In the Steam console, type: “download_depot 393520 393524”
    * After a minute or two, it will show you the location of the game files on your PC.
    * Copy all files to ports/iconoclasts/gamedata
    * Be sure the folder contains subfolders named 32, 64 and data
    * Additionally install the windows version of Iconoclasts.
    * Copy the `music` folder from `steam folder/iconoclasts/data` into `ports/iconoclasts/gamedata/data` folder
* For Preinstalled GOG:
    * Copy data into the ports/iconoclasts/gamedata folder
    * Be sure the folder contains subfolders named 32, 64 and data
* Alternatively, from GOG's self-installer:
    * Rename the installer (e.g. iconoclasts_1_15_chinese_24946.sh) extension from .sh to .gz
    * Then use 7zip to open the installer and grab the contents of the game folder (bin32, bin64, data and Assets.dat) and place it in the ports/iconoclasts/gamedata folder

**This game is best played on devices with a 640x480 screen resolution or higher!**

Thanks to JohnnyonFlame for [gl4es](https://github.com/ptitSeb/gl4es/pull/362) and the [necessary packaging](https://github.com/JohnnyonFlame/BoxofPatches) to allow this game to run on portmaster.
You can donate towards JohnnyonFlame's work [here](https://ko-fi.com/johnnyonflame)
