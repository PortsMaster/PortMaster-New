## Notes

Thanks to [Linus Probert](https://github.com/Oliveshark/breakhack) for BreakHack - a genuinely charming little roguelike, easy to pick up for a quick dungeon run and just as easy to lose an hour to. Great pixel art, great pick-up-and-play loop, appreciate it being open source so it could make it onto handhelds like this.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move (walk into a monster to attack it) |
| A | Confirm / Class Skill 1 |
| X | Class Skill 2 |
| Y | Class Skill 3 |
| B | Throw Dagger |
| R1 | Drink Health Potion |
| Start | Confirm / Pause |
| Select | Menu / Back |
| R2 | Toggle Minimap |
| L2 | Hold Turn |

Class Skills 1-3 depend on your chosen class: Mage gets Vampiric Blow/Erupt/Blink, Rogue gets
Backstab/Trip/Phase, Warrior gets Flurry/Bash/Charge. Engineer and Paladin don't have any (those
slots stay empty).

### Entering a custom seed

Picking a custom game seed needs actual text input, which a gamepad can't do on its own. Hold **Start + D-Pad Down** to open interactive text entry, then:

- D-Pad Up/Down - change the current letter
- D-Pad Right - move to the next character
- D-Pad Left - delete and move back one character
- A - confirm and exit
- Select - cancel and exit

## Compile

git clone https://github.com/Cebion/breakhack_sdl2_pm.git
cd breakhack_sdl2_pm
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make
