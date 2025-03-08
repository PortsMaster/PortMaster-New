## Notes

Please support the developers at https://store.steampowered.com/app/2417850/?snr=1_5_9__205 or https://pixelwestern.itch.io/yolk-hero. Purchasing the game is mandatory to run it.

Yolk Heroes is a Tamagotchi-style idle game where the player raises an Elf to become a hero. Think Digimon Tamagotchi meets Princess Maker as an idle game.

The Gameboy-style art and screen scaling make it a good candidate for a portable platform.

## Controls

| Button | Action |
|--|--| 
|A|'Confirm'|
|B|'Back'|
|X|'Confirm'|
|Y|'Back'|
|Start|'Menu'|
|Select|'Space'|

Text input info from gptokeyb documentation::

Interactive Input Mode Controls:
```
START+D-PAD DOWN to activate
Once activated:
D-PAD UP = previous letter
D-PAD DOWN = next letter
D-PAD RIGHT = next character
D-PAD LEFT = delete and move back one character
L1 = jump back 13 letters for current character
R1 = jump forward 13 letters for current character
A = send ENTER key and exit mode
SELECT/HOTKEY = cancel and exit mode (deletes all characters)
START = confirm and exit mode (also sends ENTER key)
```

### Capitals
By default Interactive Text Entry mode will start with A as the first letter and immediately after a space, and a otherwise, unless environment variable TEXTINPUTNOAUTOCAPITALS="Y" is set, whereby all letters will start as a.

### Symbols
By default Interactive Text Entry mode includes only a limited number of symbols "[space] . , - _ ( )", and a full set of symbols is included with environment variable TEXTINPUTADDEXTRASYMBOLS="Y".

### Exiting mode
Interactive Text Entry relies on the game providing a text prompt and sends key strokes to add and change characters, so it is only useful in these situations. Interactive Text Entry is automatically exited when either SELECT, HOTKEY, START or A are pressed, to minimise issues by accidentally triggering this mode.