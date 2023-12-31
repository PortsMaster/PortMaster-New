## Notes
<br/>

* Thanks to [Rubberduckycooly](https://github.com/Rubberduckycooly/RSDKv5-Decompilation) for the decompilation work that makes this possible.  Thanks to [TheGammaSqueeze](https://github.com/TheGammaSqueeze/RSDKv5-Decompilation) for the porting work.
* Please note that the game comes preconfigured for displaying on a 640x480 device (ex. RG351V and RG353V/VS).  Unfortunately this truncates the menus a little but does not affect gameplay (the ring and lives hud are placed correctly).  If you go to Options then Video, you can force Fullscreen to On and restart the game and it will set the screen to fullscreen for widescreen devices but add black bars at the top and bottom of 4:3 screens like the RG351V.  Once you've made this change, you can't go back to 4:3 without either manually editing the settings.ini file within the sonicmania port folder and changing pixWidth to 320 and fullscreen to 0, or redownload the port through portmaster which will overwrite this settings.ini file with the default one provided in the port package that is preconfigured for 4:3.
* To access DLC (Sonic Mania Plus), per the developer's [license requirements](https://github.com/Rubberduckycooly/RSDKv5-Decompilation/blob/master/LICENSE.md),  users need to compile this themselves. Thanks to romadu, the compile process has been made as simple as possible by providing a single GitHub repo that can be compiled on a device with ArkOS by following these instructions available [here](https://github.com/romadu/RSDKv5-Decompilation/blob/master/README.md#building-on-device-with-arkos).
<br/>

