## Notes
<br/>

Thanks to [alesan99](https://alesan99.itch.io/clockwind) for creating this game and making it available for free.
<br/>

## Controls

DPAD	    = Move
A			= Jump
B			= Grab / Toss
R1 / L1		= Time Travel
R2 / L2 	= Time Travel

## Compile 

Love 11.5 

```bash
wget https://github.com/love2d/love/releases/download/11.4/love-11.4-linux-src.tar.gz
tar xf love-11.4-linux-src.tar.gz
cd love-11.4/
./configure
make -j12
strip src/.libs/liblove-11.4.so
cp src/.libs/liblove-11.4.so device/libs
cp src/.libs/love device/
```

