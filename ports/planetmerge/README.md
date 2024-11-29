# Planet Merge

Source: https://github.com/psiroki/dinnye/

## Controls

| Button | Action |
|--|--| 
|DPAD|Move drop position or menu selection|
|A/B/X/Y|Drop planet|
|START/MENU|Enter menu|
|START+SELECT|Exit immediately|

## Compiling

To get the executable, you can follow the standard cmake boilerplate, just specify `-DPORTMASTER=ON`.

```
mkdir build
cd build
cmake -DPORTMASTER=ON -DCMAKE_BUILD_TYPE=Release ..
make
```
