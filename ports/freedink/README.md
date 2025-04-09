## Notes
Thanks to [RTsoft, Sylvain Beucler, Keiran Harcombe & all Contributros](https://www.gnu.org/software/freedink/credits) for creating this awesome game.

## DMOD Support 

For DMODS download the mod from https://www.dinknetwork.com/files/category_dmod/

Extract the .dmod file and copy the extracted folder into the freedink folder

## Controls

| Button | Action |
|--|--| 
|DPAD| Walk / Push|
|B| Attack / Use Selected Item|
|A| Talk / Examine / Manipulate|
|X| Use equipped magic|
|Y| Select Highlighted Item|
|R1| Map|
|Start| Inventory / Equip Screen| 
|Select| Escape| 

## Compile ## 

###Freedink
```bash
git clone https://git.savannah.gnu.org/git/freedink.git
cd freedink
apply freedink_cpp_changes.patch from src folder
./configure
make
```

### MiniFE
```bash
git clone git@github.com:Cebion/minife.git
cd minife/
apt-get install libguichan-dev
./bootstrap.sh
./configure
make 
```
