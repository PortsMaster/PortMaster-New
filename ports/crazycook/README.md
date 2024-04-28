## Notes

Thanks to [Skinner Space](https://skinner-space.itch.io/brutal-castle) for creating this game and it available for free!

You have to cook burgers and throw them into the mouths of your busy customers before they lose their patience. Be cautious! Your customers have specific preferences. If you feed a vegetarian with beef, he will vomit it back at your face! Your goal is to earn enough money before the time. Cook fast and pass the test of a chef to become the best cook!


## Controls

| Button     | Action               |
| ---------- | -------------------- |
| D-Pad      | Directional movement |
| A/B        | Ingredient/throw     |
| Select     | Menu                 |
| Start      | Enter                |


## Compile

```shell
wget https://downloads.tuxfamily.org/godotengine/3.3.4/godot-3.3.4-stable.tar.xz  
tar xf godot-3.3.4-stable.tar.xz  
cd godot-3.3.4-stable/platform  
git clone https://github.com/Cebion/frt.git  
cd ../  
scons platform=frt tools=no target=release use_llvm=yes module_webm_enabled=no -j12  
strip bin/godot.frt.opt.llvm
```

