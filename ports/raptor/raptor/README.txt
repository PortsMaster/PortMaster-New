Raptor

Reversed-engineered source port from Raptor Call Of The Shadows

Developer: skynettx and wel97459 (Winston Lowe)
URL: https://github.com/skynettx/raptor


Installing

You need the original assets (GLB files) from Raptor Call Of The Shadows v1.2 shareware or fullversion. Important only the DOS version v1.2 is compatible! You have to take care of these files yourself.

Shareware

1. Copy the following files to Raptor directory:
FILE0000.GLB  
FILE0001.GLB  

2. Copy the raptor.exe (Windows) or raptor (Linux or macOS) and SETUP(ADLIB).INI or SETUP(MIDI).INI files from build directory to Raptor directory. For Midi support over TinySoundFont copy the soundfont TimGM6mb.sf2 from include\TimGM6mb\ to Raptor directory. 
Under Windows copy the SDL.dll from include\SDL2-devel-2.0.14-VC\SDL2-2.0.14\lib\x86\ include\SDL2-devel-2.0.14-VC\SDL2-2.0.14\lib\x64\ folder or from include\SDL2-devel-2.0.14-mingw\SDL2-2.0.14\i686-w64-mingw32\bin\ include\SDL2-devel-2.0.14-mingw\SDL2-2.0.14\x86_64-w64-mingw32\bin\folder
 (depending on which version you prefer) to Raptor directory. Under Linux install lib-sdl2 from the packagemanager of your respective distro. When you use macOS install lib-sdl2 from dmg or from a packagemanager like brew etc.

3. The final folder should look like this:
FILE0000.GLB  
FILE0001.GLB  
SDL2.dll (only under Windows required)  
SETUP(ADLIB).INI or SETUP(MIDI).INI  
TimGM6mb.sf2  
raptor.exe (under Windows) or raptor (under Linux or macOS)

Fullversion

1. Copy the following files to Raptor directory:
FILE0000.GLB  
FILE0001.GLB  
FILE0002.GLB  
FILE0003.GLB  
FILE0004.GLB  

2. Copy the raptor.exe (Windows) or raptor (Linux or macOS) and SETUP(ADLIB).INI or SETUP(MIDI).INI files from build directory to Raptor directory. For Midi support over TinySoundFont copy the soundfont TimGM6mb.sf2 from include\TimGM6mb\ to Raptor directory. 
Under Windows copy the SDL.dll from include\SDL2-devel-2.0.14-VC\SDL2-2.0.14\lib\x86\ include\SDL2-devel-2.0.14-VC\SDL2-2.0.14\lib\x64\ folder or from include\SDL2-devel-2.0.14-mingw\SDL2-2.0.14\i686-w64-mingw32\bin\ include\SDL2-devel-2.0.14-mingw\SDL2-2.0.14\x86_64-w64-mingw32\bin\folder
 (depending on which version you prefer) to Raptor directory. Under Linux install lib-sdl2 from the packagemanager of your respective distro. When you use macOS install lib-sdl2 from dmg or from a packagemanager like brew etc.

3. The final folder should look like this:
FILE0000.GLB  
FILE0001.GLB  
FILE0002.GLB  
FILE0003.GLB  
FILE0004.GLB  
SDL2.dll (only under Windows required)  
SETUP(ADLIB).INI or SETUP(MIDI).INI  
TimGM6mb.sf2  
raptor.exe (under Windows) or raptor (under Linux or macOS)

Configuration

You can build or download Raptor Setup to create and edit the SETUP.INI, or edit it manually as follows. Rename the SETUP(ADLIB).INI or the SETUP(MIDI).INI file to SETUP.INI in Raptor directory.
If you want Midi over the TinySoundFont lib rename the TimGM6mb.sf2 to SoundFont.sf2 or specify the filename in the SETUP.INI file:
SoundFont=SoundFont.sf2
You can use any other GM compatible soundfont in sf2 format. For a better Midi sound quality I recommend the FluidR3_GM.sf2. This font is 140 mb so it is not in the repository.
To play with one of the following input devices set Control=0 under the [Setup] section in the SETUP.INI file to:
Control=0 Keyboard
Control=1 Mouse
Control=2 Joystick (Game Controller)
Haptic (Game Controller rumble support) can be switched off or on under the [Setup] section in the SETUP.INI file:
Haptic=0
Haptic=1
If you want to turn off the menu pointer control via the joystick in mode Control=2 and enable the new joystick menu control in all input modes, set under the [Setup] section in the SETUP.INI file:
joy_ipt_MenuNew=0
joy_ipt_MenuNew=1
System Midi support (Windows Multimedia, Linux ALSA and macOS CoreAudio) can be switched off or on in the [Setup] section in the SETUP.INI file:
sys_midi=0
sys_midi=1
For ALSA Midi support on Linux, install timidity and soundfont-fluid from the packagemanager of your distro. When timidity is running get the timidity client and port with aplaymidi -l and set it in the [Setup] section in the SETUP.INI file:
alsa_output_client=128
alsa_output_port=0
To display the text mode ending screen after the game quits in fullscreen mode set under the [Video] section in the SETUP.INI file:
txt_fullscreen=0
txt_fullscreen=1