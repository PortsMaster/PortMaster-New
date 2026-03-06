## Notes

**Known bugs**

* Slow audio when OpenAL is enabled
* Blank screen when joining modded servers ¹
* Blank screen when changing graphics settings
* Flickering on player setup in armhf ²
* Occasional random blank screen when opening the game

¹ It seems, when joining modded servers, the engine moves to a download information screen, but it can't identify the video settings, so it reverts to 640x480. Probably won't cause issues on 640x480 devices, but it does on others. Framebuffer can't resume afterwards.

² Something on GL4ES. Something with compiling options, or needs a patch? Quake 3 port's GL4ES doesn't seems to have the same issue, so it's being used for aarch64.


## Controls

| Button | Action |
|--|--| 
|X|Next weapon (Dual-analog devices)|
|X|Move forward (Single-analog devices)|
|X|Look up (D-Pad devices)|
|Y|Prev weapon (Dual-analog devices)|
|Y|Move left (Single-analog devices)|
|Y|Look down (D-Pad devices)|
|A|Use item / Confirm (Dual-analog devices)|
|A|Move right / Confirm (Single-analog devices)|
|A|Next weapon / Confirm (D-Pad devices)|
|B|Jump (Dual-analog devices)|
|B|Move backwards (Single-analog devices) |
|B|Jump (D-Pad devices)|
|R1|Shoot|
|L1|Zoom (Dual-analog devices)|
|L1|Jump (Single-analog devices)|
|L1|Zoom (D-Pad devices)|
|D-Pad Up|Team orders (Dual-analog devices)|
|D-Pad Up|Team orders (Single-analog devices)|
|D-Pad Up|Move forward (D-Pad devices)|
|D-Pad Left|Vote yes (Dual-analog devices)|
|D-Pad Left|Prev weapon (Single-analog devices)|
|D-Pad Left|Turn left (D-Pad devices)|
|D-Pad Right|Vote no (Dual-analog devices)|
|D-Pad Right|Next weapon (Single-analog devices)|
|D-Pad Right|Turn right (D-Pad devices)|
|D-Pad Down|Gesture (Dual-analog devices)|
|D-Pad Down|Gesture (Single-analog devices)|
|D-Pad Down|Move backwards (D-Pad devices)|
|L2|Zoom (Single-analog devices)|
|L2|Crouch (D-Pad devices)|
|R2|Walk (Dual-analog devices)|
|R2|Use item (Single-analog devices)|
|R2|Use item (D-Pad devices)|
|L3|Crouch|
|Start|Pause|
|Select|Show scores|
|Start + D-Pad Down|Enable text input|


## Compile

```shell
**Clone OpenArena's engine**
```
git clone https://github.com/OpenArena/engine
cd engine
```

**(Optional) Follow cross-compiling guide**
https://portmaster.games/build-environments.html

**Build**
```
make
```

**Download OpenArena's content and move to the directory alongside the binaries**
https://openarena.ws/download.php
```
