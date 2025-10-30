## Notes
Whatever flashes on the display can usually be set up using the D-PAD.  
  
You select an audiobook or start/pause playing with OK (usually button A).  
  
BACK (usually B) pauses or switches from pause to chapter (=file) selection. BACK also switches back to the previous screen.  
  
When the device is playing an audiobook the volume can be set up using the D-PAD. For as long as this volume overlay screen is shown (usually 5s) pressing the OK button will scroll through different sub menus of the overlay for setting up sleep timer, play speed, equalizer and book repeat mode. The maximum volume depends on what you have set up the device with when starting the application. If the device was only set up e.g. in emulationstation with 50% then the application if set to 100% will only play with 50%. If set to 50% only with 25%. The devices volume buttons can be used to setup the devices volume also while the application is running.  
  
After 15s of no button input the device will switch off the screen to get as much playtime out of the battery as possible. If no audiobook is playing (incl. the audiobook is paused) the device will shutdown after 300s of no button input. If the screen is off when the device shuts down the screen will stay off. This keeps the device dark e.g. to not wake up again from the light after the sleep timer expired.  
  
A global settings menu can be reached by navigating to the first audiobook and pressing the D-PAD left. This allows setting up screen rotation, screen brightness, screensaver mode, font type, A-B switch, deleting of bookmarks, reduced mode.  
  
Each audiobook folder is supposed to contain all the files of that audiobook. The scanner currently looks for file extensions mp3, mp4, m4a, aac, m4b, awb, amr and ogg. The files are sorted alpha numerically by the character that the OS returns. This works for ASCII but most likely will not for specific UTF-8 codings.  
The audiobook folders and files can contain UTF-8 characters. The default font might not be able to display them though.  
  
### Audiobook folder options
The application scans orderly in the following positions relative to the ports application directory and uses the first directory found as base:  
- ../../audiobooks (usually the games or roms folder of ROCKNIX, Knulli, AmberELEC, ArkOS)
- ../../ROMS/audiobooks (usually the roms folder of muOS)
- audiobooks (a folder inside the port/tinamp directory)
  
### Audiobook transfer
Apart from copying new audiobooks by removing the SD card and using it in another system for the transfer you can also transfer new audiobooks directly via a USB cable if your device supports USB MTP mode. If the player application is running it will detect changes within the audiobook folder (inotify API) and shows a transfer symbol. If you finished the transfer press BACK button. This will rescan all audiobooks.  
  
### Bookmarks
Bookmarks are automatically created. There is one bookmark per book. It is created/updated every 60s during playback and whenever the audiobook is stopped.  
The audiobook selection screen shows an ! character below the book name if there is a bookmark for this audiobook. If an # character is shown this audiobook has a bookmark with 95% completion hinting this audiobook is probably finished.  
All bookmarks can be deleted in the setup menu.  
Additionally there is an auto clean up function. If the available space left on the device where the bookmarks are stored is lower than 2MB bookmarks are deleted from which the audiobook folder can not be found anymore.  
Bookmarks are stored in the saves folder of the ports application directory as .b files. They can be synced to other devices.  
  
### Screensaver
The screen switches off after 15s of inactivity by disabling the backlight. This worked for all tested handheld operating systems. If it does not, contact me.  
Additionally a setting is available to enable a screensaver mode for LCDs. LCD displays sometimes have burned in images. In LCD screensaver mode during the time the display backlight is off the display is cycling through red, green, blue and white to clean the display.  
  
### Background image
The application comes with a default background image in the assets folder (license in the license folder).  
If an image named ```bg.bmp``` is placed in the assets folder then this image is taken instead. This allows to change the background and keep it when updating the application with a different default.  
The image is always displayed centered on the screen and stretched if needed.  
  
### Reduced mode
This mode can be set up in the global settings menu. If activated it will disable the options in the overlay screen only allowing volume settings. Additionally the BACK button is disabled only leaving OK. BACK functionality is now a time based delay. When paused the player automatically switches back to chapter selection or audiobook selection after 10s.  
This makes it easier for elderly people to navigate. Instead of differentiating when to press OK and when BACK they now just wait for what is blinking.  
  
### Battery life
I tested different devices playing using the inbuilt speaker while not using the device for anything else. They were all set up to the same volume and almost all the time the screen was off. The playtime ranged from 15hrs (R36s clone, Powkiddy RGB20s) to 19hrs (Anberbnic RG40XXV, Powkiddy V10).  
  
### Bugs, feature requests, contact
Please head over to the corresponding [Github repository](https://github.com/lanmarc77/tinamp) and open a ticket.  
  
## Packaged audiobooks
The packaged audiobooks *"Lewis Carroll - Alice's Adventures in Wonderland"* and *"Paula Dehmel - Das grüne Haus"* were taken from the public domain archive [LibriVox](https://librivox.org/).  
License is available in the license folder as file LICENSE.LibriVox.txt.  
  
## Controls
| Button | Action |
|--|--|
|A|ok/enter|
|B|stop/go back|
|D-PAD RIGHT|plus/forward/up a little|
|D-PAD LEFT|minus/backwards/down a little|
|D-PAD UP|plus/forward/up more|
|D-PAD DOWN|minus/backwards/down more|
|**Special key combos**||
|START+SELECT|quit application|
|B long press|if in audio book selection screen: shutdown the player|
|SELECT|if player is playing: activate/deactivate sleep timer|
|START+A|if player is playing: activate/deactivate key lock|
  
## Compile
Compilation needs docker installed.  
Debian 11 Bullseye arm64 is used for compiling to support older libc operating systems.  

```git clone https://github.com/lanmarc77/tinamp```  
  
Everything of the following is build inside ./build directory:  

```make libffmpeg_aarch64``` (to build ffmpeg libraries)  

```make libvlc_aarch64``` (to build libvlc libraries and to reduce and collect required libraries for packaging)  

```make tinamp_aarch64``` (to build the application)  

```make portmaster``` (to create a distributable portmaster .zip)

## Version history
v00.00.06  

 - key lock: when the device plays an audio book a key lock can be enabled and disabled by pressing and holding START and then press A

v00.00.05  

 - application detects/handles changes within the audiobook folder (e.g. during MTP file transfers)

v00.00.04  

 - sleep timer set up and chapter select now also respect different D-PAD actions
 - volume fade out starts and ends earlier before auto shutdown to allow cancelling and extending
 - background image support
 - updated FFmpeg libraries to version n4.4.6

v00.00.03  

 - initial release  

