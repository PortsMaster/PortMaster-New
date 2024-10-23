## Notes

Thank to team [Calvera Studio](https://calaverastudio.itch.io/) for making this awesome game.

The music is not yet supported in the port, an update will come later when we'll have meet all the requirements. While you can listen to this awesome BGM in this Youtube [video](https://www.youtube.com/watch?v=yjQHXCoh2lY) from the music composer [Manuel Soruco](https://manuelsoruco.com/about/).

## Controls

| Button | Action |
|--|--| 
|Dpad / Left Stick|Movement|
|A|Roll|
|B|Jump|
|X|Throw grenade|
|Y|Shot|
|L1|Roll left|
|R1|Roll right|
|L2|Weapon menu|
|R2|Weapon menu|
|Option / Start|Menu|

Nintendo gamepad layout:
* B is South
* X is North
* Y is East
* A is West

### Disable swapping of buttons
Just rename the file `SDL_swap_gpbuttons.txt` to `NO_SDL_swap_gpbuttons.txt`, or even delete it.

### Swap only A/B buttons:
This configuration might be usefull for on the X55 device.

Edit `SDL_swap_gpbuttons.txt`:
```
a b
```

### Swap A/B, X/Y and shoulder/trigger buttons:
This configuration might be more confortable on the RG40XXH device.

Edit `SDL_swap_gpbuttons.txt`:
```
a b x y leftshoulder lefttrigger rightshoulder righttrigger
```

## Acknowledgments

I cannot forget to thank warmly our fellow testers from the PortMaster Discord server <3

And finaly a big thanks to:
* JohnnyOnFlame for making GMLoaderNext
* nate for the custom loading splash engine
* Jeod for the [EmulationStation-ImageMaker](https://github.com/JeodC/EmulationStation-ImageMaker)
* [JanTrueno](https://github.com/JanTrueno) for the magnificent Patcher tool

## Build

Build custom version of gmloadernext that support `config.json`

```bash
git clone --recursive https://github.com/cdeletre/gmloader-next.git
cd gmloader-next
make -f Makefile.gmloader ARCH=aarch64-linux-gnu
ls build/aarch64-linux-gnu/gmloader
```

##  Sound patch

The game code (`data.win`) is patched to replace the wwise sound calls by native GameMaker sound calls as the wwise version used in Mini Doom II isn't supported on Linux arm.

Here is an exemple of the modification for the rocket exploding sound:

```
--- CodeEntries.in/gml_Object_o_rocket_Destroy_0.gml	2024-09-15 00:07:01
+++ CodeEntries.out/gml_Object_o_rocket_Destroy_0.gml	2024-09-16 17:22:37
@@ -9,5 +9,5 @@ if (!fade)
     }
     instance_create_layer(x, y, "Control", o_rocket_explod)
     with (objSoundController)
-        gmwPostEvent(3602287031, id)
+        audio_play_sound(125, 10, false);
 }
```

The SFX sounds are extracted from the wwise sound banks and repacked into a GameMaker audiogroup data file.