## Notes

Thanks to [VCMI Team](https://github.com/vcmi/vcmi) for the open source Heroes of Might and Magic III engine that makes this possible.  Also thanks to the @kloptops for the porting work for portmaster.  
Update to 1.6.0-dev was made by @ddrsoul with great help of @kloptops , @kotzebuedog and all VCMI and PortMaster community.

## Detailed Instructions

You need to add required game files either from CD1 & CD2, GoG or an installed copy of the game.  
This requires about 2-3 gb of free space. For the gog version copy setup_heroes_of_might_and_magic_3_complete_4.0_(28740)-1.bin and setup_heroes_of_might_and_magic_3_complete_4.0_(28740).exe into ports/vcmi.  
For the cd version copy the contents of cd1 into ports/vcmi/cd1 and cd2 into ports/vcmi/cd2.  
For the installed version copy installed game files into ports/vcmi/install.

## Controls

VCMI supports gamepad controls.
Controller mapping can be redone in ./config/shortcutsConfig.json  

Some additional settings can be made in ./save/settings.json:  
"input" : {  
    "enableController" : true // turn controller detection on/off  
    "controllerTriggerTreshold" : 0.3  // triggers, e.g. L2/R2 on PS controller would activate if they are pressed to 30%  
    "controllerAxisDeadZone" : 0.2 // analog sticks would activate if they are at 20% from resting position  
    "controllerAxisFullZone" : 1.0 // analog sticks would be maxed-out when they are at 100% from resting position  
    "controllerAxisSpeed" : 1000 // analog sticks would move at 1000 px/second  
    "controllerAxisScale" : 2 // adds acceleration to analog sticks. So, half-pressed stick would actually move not at 500 px/second, but 250 px/s IIRC. Changing to 1 would make analog sticks linear  
	}  

## Building

```
    git clone --recursive https://github.com/vcmi/vcmi.git
```
 
	replace ./server/processors/PlayerMessageProcessor.cpp:653 with 
 
```
	std::string cheatTrimmed = boost::trim_copy(cheat);
	boost::split(words, cheatTrimmed, boost::is_any_of("\t\r\n "));
```
 
	put DATA_PATHS.diff inside ./vcmi folder
 
```
    git apply DATA_PATHS.diff

    mkdir build
    cd build

	cmake .. -DBIN_DIR:FILE="bin" -DCMAKE_INSTALL_PREFIX:FILE="." -DCOPY_CONFIG_ON_BUILD="ON" -DENABLE_DEBUG_CONSOLE="OFF" -DENABLE_EDITOR="OFF" -DENABLE_ERM="OFF" -DENABLE_GITVERSION="OFF" -DENABLE_LAUNCHER="OFF" -DENABLE_LUA="OFF" -DCMAKE_BUILD_TYPE="RelWithDebInfo" -DENABLE_MONOLITHIC_INSTALL="OFF" -DENABLE_MULTI_PROCESS_BUILDS="ON" -DENABLE_NULLKILLER_AI="ON" -DENABLE_PCH="OFF" -DENABLE_SINGLE_APP_BUILD="OFF" -DENABLE_STATIC_AI_LIBS="OFF" -DENABLE_STRICT_COMPILATION="OFF" -DENABLE_TEST="OFF" -DENABLE_TRANSLATIONS="OFF" -DFL_BACKTRACE="ON" -DFL_BUILD_BINARY="OFF" -DFL_BUILD_SHARED="OFF" -DFL_BUILD_STATIC="ON" -DFL_BUILD_TESTS="OFF" -DFL_USE_FLOAT="OFF" -DFORCE_BUNDLED_FL="ON"


    make
    
```

## Thanks

A special thanks to the excellent folks on the [AmberELEC discord](https://discord.com/invite/R9Er7hkRMe), especially [Cebion](https://github.com/Cebion) for all the testing.


