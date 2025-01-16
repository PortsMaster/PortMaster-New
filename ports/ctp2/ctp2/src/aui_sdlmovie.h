#ifdef HAVE_PRAGMA_ONCE
#pragma once
#endif

#ifndef __aui_sdl__aui_sdlmovie_h__
#define __aui_sdl__aui_sdlmovie_h__ 1

#include "ctp2_config.h"
#include "aui_movie.h"

#if defined(__AUI_USE_SDL__)

#include <SDL2/SDL_events.h>

class VideoState;
class SDL_Renderer;
class SDL_Texture;
class SDL_Surface;
class aui_SDLMovie : public aui_Movie {
public:
	aui_SDLMovie(AUI_ERRCODE *retval, const MBCHAR * filename = NULL);
	virtual ~aui_SDLMovie();

	void SetContext(SDL_Renderer *renderer, SDL_Texture *background, const int windowWidth, const int windowHeight);

	virtual AUI_ERRCODE Load();
	virtual AUI_ERRCODE Unload();

	virtual AUI_ERRCODE Open(uint32 flags = 0, aui_Surface *surface = NULL, RECT *rect = NULL);
	virtual AUI_ERRCODE Close();

	virtual AUI_ERRCODE Play();
	virtual AUI_ERRCODE Stop();

	virtual AUI_ERRCODE Pause();
	virtual AUI_ERRCODE Resume();

	virtual AUI_ERRCODE Process();

	virtual BOOL IsOpen() const;
	virtual BOOL IsPlaying() const;
	virtual BOOL IsPaused() const;

private:
	bool HandleMovieEvent(SDL_Event &event);
	bool InsideMovieArea(int x, int y);
	void GrabLastFrame();

	VideoState *m_videoState;

	SDL_Renderer *m_renderer;
	SDL_Texture *m_background;
	int m_windowWidth;
	int m_windowHeight;
	int m_logicalWidth;
	int m_logicalHeight;
};

#endif  // defined(__AUI_USE_SDL__)

#endif
