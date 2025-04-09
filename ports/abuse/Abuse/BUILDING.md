# Building Abuse

## Prerequists

### All Platforms

- SDL 1.1.6 or higher <http://www.libsdl.org> (note that SDL2 will not work)
- [SDL_mixer 1.2](http://www.libsdl.org/projects/SDL_mixer/release-1.2.html)
- [CMake 2.8.9 or later](http://www.cmake.org/)
- GL libraries and headers are required for OpenGL support.
- OpenCV library for extracting PCX images in SPEC files using abuse-tool

### Windows

- [Visual Studio 2013](http://www.visualstudio.com/downloads/download-visual-studio-vs#d-express-windows-desktop)
  (maybe earlier versions, haven't tried)
- CMake 2.8.11 or later for the WIX installer (tested with 3.0)

### Mac OS X

Mac OS X should have most of the stuff you need already. The easiest method for
getting CMake and SDL/SDL_mixer is probably using [Homebrew](http://brew.sh/).

    brew install cmake
    brew install sdl
    brew install sdl_mixer

# Compiling

1. Clone this repository.

       git clone https://github.com/Xenoveritas/abuse.git

2. Create a new directory for the build. CMake likes to build into directories
   outside the source directory and its best not to fight it on this.

   Within that directory, run CMake.

   In order to get a build that includes all the data, you'll want to specify
   an install directory. All told, you might setup doing something like:

       mkdir abuse
       cd abuse
       git clone https://github.com/Xenoveritas/abuse.git
       mkdir build
       cd build
       cmake -DCMAKE_INSTALL_PREFIX:PATH=../final-binary ../abuse

   Under Windows, this will probably fail because it can't find the SDL2 or
   SDL2_mixer libraries. Two solutions to this:

      1. Run `cmake-gui` and provide the paths that way
      2. Set `SDL2DIR` and `SDL2MIXERDIR` to point to where you extracted the
         Windows VC devel binaries for each library

3. Build the files

   Under Linux and Mac OS X, this is the familiar `make`.

   Under Windows, you'll want to use `MSBuild abuse.sln`. (Alternatively, open
   the solution in Visual Studio and build it that way.)

4. Install the files

   Note that you can skip this step if you're planning on building an installer.
   This is simply `make install` or building `INSTALL.vcxproj` under Windows.
   (Again, either `MSBuild INSTALL.vcxproj` or just build it directly within
   Visual Studio.)

# Installers (Packages)

The CMake package includes some CPack stuff to enable building installers. Under
Windows, this will attempt to create a [WIX](http://wixtoolset.org/) installer
and a ZIP file. Under Mac OS X, it attempts to create a DMG and TGZ.

To build them under Linux and Mac OS X, it's just `make package`.

Under Windows, build `PROJECT.vcxproj`.
