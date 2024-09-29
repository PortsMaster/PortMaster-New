## Notes

Thanks to the authors for creating this game and making it free:
* Guillaume Cottenceau (code)
* Alexis Younes (graphic)
* Matthias Le Bidan (music)
* Amaury Amblard-Ladurantie (graphic)

Source: https://github.com/kthakore/frozen-bubble

I also have to say a big thank you to my fellow testers:
* ZOMGUoff
* tabreturn
* Ganimoth
* JanTrueno

## Important notes

* The *level editor* menu entry is disabled. However you can import from a computer the levels into *frozen-bubble/conf*
* The *change keys* menu entry is disabled. If you need to change the controls modify the configuration in the *frozen-bubble/frozen-bubble.gptk* file with a text editor (make a backup before).
* On rocknix it seems to run better with panfrost. However it works still pretty well with libmali.
* If you feel it is too laggy you can switch between 3 levels of details (Low/Medium/High) with the *graphics* entry in the menu.

## Controls

| Button | Action |
|--|--| 
|D-PAD left/right|aim left/right (P1)|
|D-PAD down|aim center  (P1)|
|D-PAD up|fire (P1)|
|L1|fire (P1)|
|L-Stick up|send malus to top left player (multiplayer only)|
|L-Stick down|send malus to bottom left player (multiplayer only)|
|R-Stick up|send malus to top right player (multiplayer only)|
|R-Stick down|send malus to bottom right player (multiplayer only)|
|R3|send malus to all opponents (multiplayer only)|
|Y/A|aim left/right (P2)|
|B|aim center (P2)|
|X|fire (P2)|
|R1|fire (P2)|
|Start|Enter|
|Select|Esc|
|L2|Y (yes)|
|R2|N (no)|
|L3|toggle music on/off|

## Compile

```
git clone https://github.com/cdeletre/frozen-bubble-aarch64.git
cd frozen-bubble-aarch64
docker build --platform=linux/arm64 -t frozen-bubble-aarch64 .
docker run --rm -v ${PWD}:/frozen-bubble frozen-bubble-aarch64 /frozen-bubble/build.sh
```

