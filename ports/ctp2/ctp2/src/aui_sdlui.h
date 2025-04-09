//----------------------------------------------------------------------------
//
// Project      : Call To Power 2
// File type    : C++ header
// Description  : User interface SDL component
//
//----------------------------------------------------------------------------
//
// Disclaimer
//
// THIS FILE IS NOT GENERATED OR SUPPORTED BY ACTIVISION.
//
// This material has been developed at apolyton.net by the Apolyton CtP2
// Source Code Project. Contact the authors at ctp2source@apolyton.net.
//
//----------------------------------------------------------------------------
//
// Compiler flags
//
// _MSC_VER
// - Compiler version (for the Microsoft C++ compiler only)
//
//----------------------------------------------------------------------------
//
// Modifications from the original Activision code:
//
// - Initialised pointer in default constructor to prevent destructor crash.
//
//----------------------------------------------------------------------------
#ifndef __AUI_SDLUI_H__
#define __AUI_SDLUI_H__

#ifdef __AUI_USE_SDL__

#include "aui_ui.h"
#include "aui_sdl.h"

class aui_SDLUI : public aui_UI, public aui_SDL
{
public:
	aui_SDLUI(
		AUI_ERRCODE *retval,
		HINSTANCE hinst,
		HWND hwnd,
		sint32 width,
		sint32 height,
		sint32 bpp,
		const MBCHAR *ldlFilename = NULL,
		BOOL useExclusiveMode = FALSE );
	virtual ~aui_SDLUI();

protected:
	aui_SDLUI()
	:   aui_UI              (),
	    aui_SDL             ()
	{ ; };

	AUI_ERRCODE InitCommon( void );

public:

	virtual AUI_ERRCODE AltTabOut( void );
	virtual AUI_ERRCODE AltTabIn( void );
	AUI_ERRCODE CreateNativeScreen( BOOL useExclusiveMode );
	AUI_ERRCODE DestroyNativeScreen(void);
	AUI_ERRCODE TearDownMouse(void);
	AUI_ERRCODE RestoreMouse(void);

	void SetWidth(sint32 width) { m_width = width; }
	void SetHeight(sint32 height) { m_height = height; }

	aui_MovieManager* CreateMovieManager( void );
public:
	virtual AUI_ERRCODE SDLDrawScreen( void );

	SDL_Window *m_SDLWindow;
	SDL_Renderer *m_SDLRenderer;
	SDL_Texture *m_SDLTexture;
};

typedef aui_SDLUI aui_NativeUI;

#endif

#endif
