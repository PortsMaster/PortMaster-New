/*
 * Nikwi Deluxe
 * Copyright (C) 2005-2012 Kostas Michalopoulos
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 *
 * Kostas Michalopoulos <badsector@runtimelegend.com>
 */

/*
** Nikwi Engine - GFX
*/

#include "nikwi.h"

//#define HALF_SIZED_SCREEN

SDL_Surface	*screen = NULL;
#ifdef HALF_SIZED_SCREEN
SDL_Surface	*rscreen = NULL;
#endif
bool		fullscreen = true;

static SDL_Joystick	*joy = NULL;

static unsigned short read_ushort_le(unsigned char* data)
{
	return data[0] | data[1] << 8;
}

SDL_Surface *createSurface(int width, int height, bool colorKey)
{
	SDL_Surface	*surf;
	Uint32		rm, gm, bm;

	rm = 0x0000001F;
	gm = 0x000007E0;
	bm = 0x0000F800;
	
	if (screen && screen->format)
	{
		rm = screen->format->Rmask;
		gm = screen->format->Gmask;
		bm = screen->format->Bmask;
	}

	surf = SDL_CreateRGBSurface(SDL_HWSURFACE|(colorKey?SDL_SRCCOLORKEY:0),
		width, height, 16, rm, gm, bm, 0);
	if (!surf)
		return NULL;
		

	if (colorKey)
	{
		SDL_SetColorKey(surf, SDL_SRCCOLORKEY, SDL_MapRGB(surf->format,
			248, 0, 248));
	}
	
	return surf;
}

SDL_Surface *loadImage(String file)
{
	uint		len;
	unsigned char	*data = (unsigned char*)getData(file, len);
	unsigned short	width;
	unsigned short	height;
	unsigned short	*pixels;
	unsigned short	*spixels;
	SDL_Surface	*surf;
	if (!data)
	{
		return NULL;
	}
	pixels = (unsigned short*)&data[8];
	width = read_ushort_le(data + 4);
	height = read_ushort_le(data + 6);
	
	surf = createSurface(width, height);
	if (!surf)
	{
		free(data);
		return NULL;
	}
	
	if (SDL_MUSTLOCK(surf))
		SDL_LockSurface(surf);
	uint	index = 0;
	for (uint h=0;h<height;h++)
	{
		spixels = &((unsigned short*)surf->pixels)[h*surf->pitch/2];
		for (uint w=0;w<width;w++)
		{
			/*
			int	rv = pixels[index++];
			int	gv = pixels[index++];
			int	bv = pixels[index++];
			*/
			unsigned int	pixel = read_ushort_le((unsigned char*) &pixels[index++]);
			int		rv, gv, bv;
			
			bv = (pixel&31) << 3;
			gv = ((pixel >> 5)&63) << 2;
			rv = ((pixel >> 11)&31) << 3;
			*(spixels++) = SDL_MapRGB(surf->format, rv, gv, bv);
/*			*(spixels++) = rv;
			*(spixels++) = gv;
			*(spixels++) = bv;
			*(spixels++) = 0;*/
		}
	}
	if (SDL_MUSTLOCK(surf))
		SDL_UnlockSurface(surf);
	
	free(data);
	
	return surf;
}

void drawLine(int x1, int y1, int x2, int y2, int color)
{
	unsigned short	*pixels = (unsigned short*)screen->pixels;
	float	len = hypot(x2 - x1, y2 - y1);
	float	x, y, dx, dy;
	
	dx = (x2 - x1)/len;
	dy = (y2 - y1)/len;
	
	x = x1;
	y = y1;
	
	for (int i=0;i<(int)len;i++,x+=dx,y+=dy)
		if (x >= 0 && x <= 639 && y >= 0 && y <= 479)
			pixels[(int)y*640 + (int)x] = color;
}

void drawBox(int x1, int y1, int x2, int y2, int color)
{
	unsigned short	*pixels = (unsigned short*)screen->pixels;
	for (int x=x1;x<x2;x++)
	{
		if (x < 0 || x > 639)
			continue;
		if (y1 >= 0 && y1 < 480)
			pixels[y1*640 + x] = color;
		if (y2 >= 0 && y2 < 480)
			pixels[y2*640 + x] = color;
	}
	for (int y=y1;y<y2;y++)
	{
		if (y < 0 || y > 479)
			continue;
		if (x1 >= 0 && x1 < 640)
			pixels[y*640 + x1] = color;
		if (x2 >= 0 && x2 < 640)
			pixels[y*640 + x2] = color;
	}
}

bool initGfx(String winCaption)
{
	SDL_Init(SDL_INIT_VIDEO|SDL_INIT_AUDIO);
	#ifdef HALF_SIZED_SCREEN
	rscreen = SDL_SetVideoMode(320, 240, 16, (fullscreen?SDL_FULLSCREEN:0)|
		SDL_SWSURFACE|SDL_DOUBLEBUF);
	if (!rscreen)
		rscreen = SDL_SetVideoMode(320, 240, 16,
			(fullscreen?SDL_FULLSCREEN:0));
	if (!rscreen)
		rscreen = SDL_SetVideoMode(320, 240, 16, 0);
	
	screen = createSurface(640, 480, false);
	
	screen = SDL_CreateRGBSurface(SDL_HWSURFACE, 640, 480, 16,
		rscreen->format->Rmask,
		rscreen->format->Gmask,
		rscreen->format->Bmask,
		rscreen->format->Amask);
	#else	
	screen = SDL_SetVideoMode(640, 480, 16, (fullscreen?SDL_FULLSCREEN:0)|
		SDL_HWSURFACE|SDL_DOUBLEBUF);
	if (!screen)
		screen = SDL_SetVideoMode(640, 480, 16,
			(fullscreen?SDL_FULLSCREEN:0));
	if (!screen)
		screen = SDL_SetVideoMode(640, 480, 16, 0);
	
	if (!screen)
		return false;
	#endif
	
	SDL_WM_SetCaption(winCaption, winCaption);
	SDL_ShowCursor(false);
	
	joy = SDL_JoystickOpen(0);
	
	return true;
}

void shutdownGfx()
{
	if (joy)
		SDL_JoystickClose(joy);
	joy = NULL;
	SDL_Quit();
}

void updateSystemScreen()
{
	#ifdef HALF_SIZED_SCREEN
	
	if (SDL_MUSTLOCK(screen))
		SDL_LockSurface(screen);
	if (SDL_MUSTLOCK(rscreen))
		SDL_LockSurface(rscreen);
	
	unsigned short	*spixels = (unsigned short*)screen->pixels;
	unsigned short	*rpixels = (unsigned short*)rscreen->pixels;
	unsigned int	spitch = screen->pitch;
	unsigned int	rpitch = rscreen->pitch >> 1;
	unsigned int	sindex, rindex, sstart = 0, rstart = 0;
	
	for (int y=0;y<240;y++)
	{
		sindex = sstart;
		rindex = rstart;
		
		for (int x=0;x<320;x++)
		{
			rpixels[rindex] = spixels[sindex];
			
			sindex += 2;
			++rindex;
		}
		
		sstart += spitch;
		rstart += rpitch;
	}
	
	if (SDL_MUSTLOCK(rscreen))
		SDL_UnlockSurface(rscreen);
	if (SDL_MUSTLOCK(screen))
		SDL_UnlockSurface(screen);
	
	SDL_Flip(rscreen);
	
	#else
	SDL_Flip(screen);
	#endif
}

