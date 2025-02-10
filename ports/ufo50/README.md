## Installation
Purchase the game on Steam and copy all the data to `ports/ufo50/assets`. On first run the game will be patched.

If you are updating a prepatched game, simply delete the `patchlog.txt` file, and add your new `data.win` file to `assets` *in addition to any new data you want added*. This means you can add the `ext` folder for any language updates and the `Textures` folder.

## Performance Notes
This port features audio compression in an attempt to reduce memory usage. This is necessary in order for the port to run on the linux arm handhelds targeted. These handhelds are equipped with low-end rockchip or allwinner processors and usually 1-2GB of memory, alongside Mali blob drivers. Low processing power, low memory, and low VRAM are all major things to watch for when running ports on these devices. The following are known issues that are, again, **conditionally existent due to hardware and gmloader-next constraints**.

- Games that use large rooms will have lower fps (Ninpek, Velgress, Planet Zoldath, etc).

UFO 50 v1.7.0.1 implemented dynamic texture loading, which may alleviate slowdowns in these particular games further.

## xDelta Patch Notes
For the more technically inclined, here are specific modifications made in order to make UFO 50 run smoothly on the targeted devices:

- [GMTools](https://github.com/cdeletre/gmtools) by Cyril Deletre to convert WAV to OGG and lower their bitrate
- [UndertaleModTool](https://github.com/UnderminersTeam/UndertaleModTool) to make some specific changes to the game
    - Remove/hide the scaling feature since the game always scales to the display on targeted devices, and enforce 1x scaling
    - Change the video settings menu to use `Stretch to Fit`, `Maintain Aspect Ratio`, and `Integer Scale` for display options
    - Remove/hide the scale options and the CRT shader options, since CRT shaders do not work on 1x scale
    - Flush textures during cleanup operations
    - Use a `config.ini` file to toggle arcade mode

## Thanks
Mossmouth -- The absolutely amazing game  
JohnnyOnFlame -- GMLoader-Next and TextureRepacker via UTMT  
Cyril aka kotzebuedog -- GMTools audio patcher  
mavica -- Display patch  
Testers & Devs from the PortMaster Discord