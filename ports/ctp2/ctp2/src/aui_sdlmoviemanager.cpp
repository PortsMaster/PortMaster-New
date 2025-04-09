#include "c3.h"
#include "aui_sdlmoviemanager.h"

#if defined(__AUI_USE_SDL__)

#include "aui_sdlmovie.h"

#if defined(USE_SDL_FFMPEG)
#include <SDL2/SDL_mutex.h>
extern "C" {
	#include <libavformat/avformat.h>
}

#endif // USE_SDL_FFMPEG

aui_SDLMovieManager::aui_SDLMovieManager(SDL_Renderer *renderer, SDL_Texture *background, const int windowWidth,
		const int windowHeight) :
	aui_MovieManager(false),
	m_renderer(renderer),
	m_background(background),
	m_windowWidth(windowWidth),
	m_windowHeight(windowHeight)
{
	Assert(m_renderer);
	Assert(m_background);
	m_movieResource = new aui_Resource<aui_SDLMovie>();
}

aui_SDLMovieManager::~aui_SDLMovieManager() {
	delete m_movieResource;
}

aui_Movie* aui_SDLMovieManager::Load(const MBCHAR *filename, C3DIR dir) {
	aui_SDLMovie *movie = m_movieResource->Load(filename, dir);
	movie->SetContext(m_renderer, m_background, m_windowWidth, m_windowHeight);
	return movie;
}

#endif // defined(__AUI_USE_SDL__)
