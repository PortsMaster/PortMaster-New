## Notes

Dave Gnukem is a retro-style 2D scrolling platform shooter similar to, and inspired by, Duke Nukem 1 (~1991). 
The source code is cross-platform and open source. 
It runs on Windows, Linux, Mac OS X and more. 
(The original Duke Nukem 1 had 16-color EGA 320x200 graphics; the aim here is 'similar but different' gameplay and 'look and feel'. It is kind of a parody of the original. Please note it is not a 'clone', and not a 're-make'.) 

Thanks to [David Joffe](https://github.com/davidjoffe) developers and contributors for the open source game.
Also thanks to Bamboozler and Slayer366 for the porting work for portmaster. 

Source: [davidjoffe](https://github.com/davidjoffe/dave_gnukem) 


## Controls

| Button | Action |
|--|--| 
|Start|Enter|
|Select|Menu|
|Left/Right|Move left/right|
|A/Y|Shoot|
|B|Jump|
|X/Up|Action|
|L1/L2|Decrease volume|
|R1/R2|Increase volume|

</br>

## Interactive text Input Mode Controls

START+D-PAD DOWN to activate
once activated:

| Button | Action |
|--|--| 
|D-PAD UP|previous letter|
|D-PAD DOWN|next letter|
|D-PAD RIGHT|next character|
|D-PAD LEFT|delete and move back one character|
|L1|jump back 13 letters for current character|
|R1|jump forward 13 letters for current character|
|A|send ENTER key and exit mode|
|SELECT/HOTKEY|cancel and exit mode (deletes all characters)|
|START|confirm and exit mode (also sends ENTER key)|

</br>

If you get stuck in the high-score text box, just press the shoulder or trigger buttons to enter number gibberish and press 'Start'.

</br>

## Compile

```shell
git clone https://github.com/davidjoffe/dave_gnukem
cd dave_gnukem
make -j$(nproc)
```
