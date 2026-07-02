## Notes


Thanks to the [OpenTyrian Team](https://github.com/opentyrian/opentyrian) and contributors for the open-source port that makes this possible.


## Compile

```shell
git clone https://github.com/opentyrian/opentyrian.git
cd opentyrian

- change Makefile WITH_NETWORK := true to WITH_NETWORK := false
- change src/joystick.c bool ignore_joystick = false; to bool ignore_joystick = true;

make
strip opentyrian
```
