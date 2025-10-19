## Notes
NiceChess is built off of Brutal Chess 0.5.2 as its base and updated to use SDL2 along with some nice quality-of-life improvements.

Source: [Slayer366](https://github.com/Slayer366/nicechess)

Thanks to [BencsikRoland](https://github.com/BencsikRoland/nicechess) and the original contributors of Brutal Chess for this open source chess engine.  

NOTE: While the difficulty level can be changed, it's recommended to stick with levels less than 6 because while lvl 6 can take the CPU up to two minutes to make a move, anything higher will either have you waiting for a very long time or the game thinks so hard that it freezes.

NOTE #2: On some RK3566 devices, the dark squares seem to want to pick a random color every time at launch.  Perhaps this can be fixed at some point.

## Controls

</br>

On devices with less than 2 thumb sticks, the D-Pad can be used to move the cursor.

| Button | Action |
|--|--| 
|Select|Esc/Quit|
|Start|Enter|
|A|Enter/Invoke menu selection|
|B/R1/L3/R3|Left Mouse button|
|X/L2/R2|Main Menu|
|Y/L1|Hold to rotate chess board|
|D-Pad|Navigate Menu|
|Left Analog|Move cursor|
|Right Analog|Move cursor|

</br>

## Compile

```shell
sudo apt install libsdl2-dev libsdl2-image-dev libglm-dev libfreetype6-dev
git clone https://github.com/Slayer366/nicechess
cd nicechess
make -j$(nproc)
```
