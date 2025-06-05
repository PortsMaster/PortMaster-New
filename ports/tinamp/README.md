## Notes
Whatever flashes on the display can usually be setup using the D-PAD.  
  
You select an audio book or start/pause playing with OK (usually button A).  
  
BACK (usually B) pauses or switches from pause to chapter (=file) selection. BACK also switches back to the previous screen.  
  
When the device is playing an audio book the volume can be setup using the D-PAD. For as long as this volume overlay screen is shown the OK button will scroll through different sub menus of the overlay for setting up sleep timer, play speed, equalizer or book repeat mode. The maximum volume depends on what you have setup the device with when starting the application. If the device was only setup e.g. in emulationstation with 50% then the application if set to 100% will only play with 50%. If set to 50% only with 25%.  
  
After 15s of no button input the device will switch off the screen to get as much playtime out of the battery as possible. If no audio book is playing (incl. the audio book is paused) the device will shutdown after 300s of no button input. If the screen is off when the device shuts down the screen will stay off. This keeps the device dark e.g. to not wake up again from the light after the sleep timer expired.  
  
A global settings menu can be reached by navigating to the first audio book and pressing the D-PAD left. This allows setting up screen rotation, screen brightness, screen saver mode, font type, A-B switch, deleting of bookmarks, reduced mode.  
  
Each audio book folder is supposed to contain all the files of that audio book. The scanner currently looks for file extensions mp3, mp4, m4a, aac, m4b, awb, amr and ogg. The files are sorted alpha numerically by the character that the OS returns. This works for ASCII but most likely will not for specific UTF-8 codings.  
The audio book folders and files can contain UTF-8 characters. The default font might not be able to display them though.  
  
### Special key combos
If you are in the audio book selection screen and press and hold BACK for longer than 5s the application will quit and shutdown the device.  
  
If you wish to keep using the device press START+SELECT to return to the devices main UI (e.g. emulationstation).  
  
The sleep timer can also be started faster by pressing SELECT while the player is playing. The last setup sleep time is used to right away enable the timer.  
  
### Audiobook folder options
The application scans orderly in the following positions relative to the ports application directory and uses the first directory found as base:  
- ../../audiobooks (usually the games or roms folder of ROCKNIX, Knulli, AmberELEC, ArkOS)
- ../../ROMS/audiobooks (usually the roms folder of muOS)
- audiobooks (a folder inside the port/tinamp directory)
  
### Bookmarks
Bookmarks are automatically created. There is one bookmark per book. It is created/updated every 60s during playback and whenever the audio book is stopped.  
The audio book selection shows an ! character below the book name if there is a bookmark for this audio book. If an # character is shown this audio book has a bookmark with 95% completion hinting this audio book is probably finished.  
All bookmarks can be deleted in the setup menu.  
Additionally there is an auto clean up function. If the available space left on the device where the bookmarks are stored is lower than 2MB bookmarks are deleted from which the audio book folder can not be found anymore.  
Bookmarks are stored in the saves folder of the ports application directory as .b files. They could be synced to other devices.  
  
### Screen saver
The screen switches off after 15s of inactivity by disable the backlight. This worked for all tested handheld operating systems. If it does not contact me.  
Additionally a setting is available to enable a screen saver mode for LCDs. These displays sometimes have burned in images. If the LCD mode is switched on while the display backlight is off the display is cycling through red, green, blue and white to clean the display.  
  
### Reduced mode
This mode can be setup in the global settings menu. If activated it will disable the options in the overlay screen only allowing volume settings. Additionally the BACK button is disabled only leaving OK. BACK functionality is now a time based delay. When paused the player automatically switches back to chapter selection or audio book selection after 10s.  
This makes it easier for elderly people to navigate. Instead of differentiating when to press OK and when BACK they now just wait for what is blinking.  
  
### Battery life
I tested different devices playing using the inbuilt speaker while not using the device for anything else. They were all setup to the same volume and almost all the time the screen was off. The playtime ranged from 15hrs (R36s clone, Powkiddy RGB20s) to 19hrs (Anberbnic RG40XXV, Powkiddy V10).  
  
### Bugs, feature requests, contact
Please head over to the corresponding [Github repository](https://github.com/lanmarc77/tinamp) and open a ticket.  
  
## Packaged audio books
The packaged audio books "Lewis Carroll - Alice's Adventures in Wonderland" and "Paula Dehmel - Das grüne Haus" were taken from the public domain archive [LibriVox](https://librivox.org/).  
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

## Compile
Compilation needs docker installed.  

git clone https://github.com/lanmarc77/tinamp  
  
Everything of the following is build inside ./build directory:  

make libffmpeg_aarch64 (to build ffmpeg libraries)  

make libvlc_aarch64 (to build libvlc libraries)  

make tinamp_aarch64 (to build the application)  

make portmaster (to create a distributable portmaster .zip)
