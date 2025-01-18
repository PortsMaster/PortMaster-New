#ifdef HAVE_PRAGMA_ONCE
#pragma once
#endif

#ifndef __aui_sdl__aui_sdlmoviemanager_h__
#define __aui_sdl__aui_sdlmoviemanager_h__ 1

#include "ctp2_config.h"
#include "aui_moviemanager.h"

#if defined(__AUI_USE_SDL__)

#include "aui_sdlmovie.h"
#include <SDL2/SDL_render.h>

class aui_SDLMovieManager : public aui_MovieManager {
public:
	aui_SDLMovieManager(SDL_Renderer *sdlRenderer, SDL_Texture *background, const int windowWidth,
			const int windowHeight);
	virtual ~aui_SDLMovieManager();

	virtual aui_Movie *Load(const MBCHAR *filename, C3DIR dir = C3DIR_DIRECT);

	virtual AUI_ERRCODE Unload( aui_Movie *movie )
	{ return m_movieResource->Unload((aui_SDLMovie*)movie); }
	virtual AUI_ERRCODE Unload( const MBCHAR *movie )
	{ return m_movieResource->Unload(movie); }

	virtual AUI_ERRCODE AddSearchPath(const MBCHAR *path)
	{ return m_movieResource->AddSearchPath(path); }
	virtual AUI_ERRCODE RemoveSearchPath(const MBCHAR *path)
	{ return m_movieResource->RemoveSearchPath(path); }

private:
	aui_Resource<aui_SDLMovie>	*m_movieResource;

	SDL_Renderer *m_renderer;
	SDL_Texture *m_background;
	int m_windowWidth;
	int m_windowHeight;
};

#endif  // defined(__AUI_USE_SDL__)

#endif
