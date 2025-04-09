## Notes
<br/>

Thanks to [Poul Sander and contributors](https://github.com/blockattack/blockattack-game) for creating this game and making it available for free.  Also, thanks to Cebion for the porting work for portmaster.
<br/>

## Compile

```bash
git clone https://github.com/blockattack/blockattack-game.git
./packdata.sh
edit source/code/main.cpp and remove sdl_joystick init
cmake .
make
```
