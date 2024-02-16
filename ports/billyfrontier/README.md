## Notes
Thanks to Pangea Software for creating the game and publicly releasing the game files. 
Thanks to [Jorio](https://github.com/jorio/BillyFrontier) for porting the game engine to various platforms. 
 
Also thanks to brooksytech and Cebion for the porting work for portmaster.


## Compile

```shell
git clone https://github.com/jorio/BillyFrontier
git submodule update --init --remote --force
mkdir build && cd build

Compile custom shim gl4es 
cmake-DCMAKE_BUILD_TYPE=Release -DNOX11=ON -DGLX_STUBS=ON -DGBM=OFF -DNOEGL=ON ..

```
edit Source/Boot.cpp
```
SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
```
Comment out from: Source/3D/OGL_Support.c

```
    //         glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &gMaxAnisotropy);
    //         OGL_CheckError();
cmake ..	
make
```
