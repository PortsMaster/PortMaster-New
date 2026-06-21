Thanks to [banteg](https://github.com/banteg/crimson) for this faithful rewrite of Crimsonland.
Modded for handhelds: [jckhng](https://github.com/jckhng/crimson)
Thanks to NotYerAvgPorter for testing.

# Crimsonland PortMaster

Copy the original game archives into `crimsonland/assets/` before launching. The
native PortMaster build can run without music; `music.paq` or loose `music/*.ogg` files are optional. 

## Attribution and redistribution

Crimsonland is the original game by 10tons Ltd. This package is an independent
community PortMaster build of the native Zig reimplementation from the Crimson
rewrite project. It is not an official 10tons release.

New runtime configs default to left-stick movement and right-stick aim/fire.
Controls use `crimson.gptk` by default for keyboard/menu fallbacks, but
gameplay aiming uses native raylib gamepad axes instead of mouse cursor
emulation. Y opens perk picking, L1/L2 reload, and X sends Backspace for
high-score name entry. The PortMaster launcher hides Crimson's custom UI cursor
for controller-only navigation. Set `CRIMSON_USE_GPTOKEYB=0` before launching
to test native raylib gamepad input only.
