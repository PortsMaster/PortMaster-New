## Notes

Special thank you goes to [**Kaito Sinclaire** (any pronoun)](https://github.com/KScl) for creating this amazing version of [**Tyrian 2000**](https://github.com/KScl/opentyrian2000) and making it available for everyone, free of charge. Thanks to the original developers of this fantastic game.


## Controls

| Button | Action |
|--|--| 
|A|Change Fire|
|B|Fire|
|Y, L1, L3|Left Sidekick|
|X, R1, R3|Right Sidekick|
|Start|Menu / Pause|
|Select|Switch between Full Screen / Windowed Mode|
|D-Pad|Movement|
|Left Analog|Movement|
|Right Analog|Mouse Movement|


## Compile

```shell
git clone https://github.com/KScl/opentyrian2000.git
cd opentyrian2000

# this changes WITH_NETWORK from 'true' to 'false'
sed -i 's/^\(WITH_NETWORK\s*:=\s*\)true/\1false/' Makefile

make -j8
make install
```