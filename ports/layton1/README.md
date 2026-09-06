## Notes

| Details | Information |
|---|---|
| Ready to Run | No |
| Engine/Framework | Level-5 in-house engine (Android build, run through Bogodroid) |
| Architectures | 64 Bit |
| Aspect Ratio | Portrait, rotated to fit the panel (switchable in-game) |
| Rumble Support | No |
| Tested Versions | Google Play 1.0.8 |
| Controls | Native |
| Joysticks Required | None |


**Patched-in features:**
- Full touchscreen support.
- Stick and d-pad move an on-screen pointer, moving in the direction you push regardless of screen rotation; speed and size scale with the display
- On-screen keyboard that appears by itself whenever the game asks for text (puzzle answers, your name), with a number pad for numeric fields. Start toggles it manually.
- Screen rotation between portrait and landscape, changeable while playing with L1/R1, or set in `layton.toml`


Thanks to:
* [Level-5](https://www.level5.co.jp/) for creating this wonderful game! Check out the game's Google Play page [here](https://play.google.com/store/apps/details?id=com.Level5.LT1REU).
* binarycounter for [Bogodroid](https://github.com/binarycounter/Bogodroid), the Android loader this port is built on, which does nearly all of the work.
* The authors of the Nintendo Switch port of the same game, whose approach to the engine's rotation, cutscene handling and JNI entry points this port follows.
* JanTrueno for porting: Professor Layton and the Curious Village HD.

## Controls

| Button | Action |
|--|--| 
|D-Pad/L-Stick/R-Stick|Move Pointer|
|Face Buttons/L3/R3|Tap|
|L1/R1|Rotate screen|
|Start|On screen keyboard|


