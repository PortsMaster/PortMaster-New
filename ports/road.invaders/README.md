## Notes

Original version by:  
https://blasin.itch.io/road-invaders

Special thanks to: Blasin for making this game and allowing us to share it with you.

Thanks to EvilLurker for the cover.png art.


## Controls

| Button | Action               |
| ------ | -------------------- |
| Dpad   | Horizontal movement  |
| Start  | Pause game           |
| Select | Exit Game            |


## Compile

```shell
wget https://github.com/love2d/love/releases/download/11.4/love-11.4-linux-src.tar.gz  
tar xf love-11.4-linux-src.tar.gz  
cd love-11.4/  
./configure  
LOVE_GRAPHICS_USE_OPENGLES=1 make -j12  
strip src/.libs/liblove-11.4.so  
scp src/.libs/liblove-11.4.so device/libs  
scp src/.libs/love device/
```
