# Thanks
Thanks to the [civctp2 Team](https://github.com/civctp2/civctp2) for creating this engine and making it available for free.

## Controls

| Button | Action |
|--|--| 
|DPAD| Move Mouse |
|A/B| Mouse Leftt / Right|
|Y| Next Unit| 
|X| Slow Mouse |
|Start| Next Turn|

## Building

```
git clone https://github.com/civctp2/civctp2.git
cd civctp2/
cp configure.ac from src folder in port to civctp2

cd ctp2_code/libs/anet
mkdir macros
echo 'AC_DEFUN([AC_LIBANET_INTERNAL],[])' > macros/libanet.m4
libtoolize --force --copy
aclocal -I macros
automake --add-missing --copy --foreign
autoconf

cd civctp2/ 
mkdir ctp2_code/os/autoconf/m4
mv ctp2_code/os/autoconf/*.m4 ctp2_code/os/autoconf/m4/
touch AUTHORS ChangeLog NEWS
cp /usr/share/aclocal/pkg.m4 ctp2_code/os/autoconf/m4/
aclocal -I ctp2_code/os/autoconf/m4
libtoolize --force
autoconf
automake --add-missing
./configure
make 
```