//----------------------------------------------------------------------------
//
// Project      : Call To Power 2
// File type    : C++ source
// Description  : SDL user interface handling
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
// __AUI_USE_SDL__
//
//----------------------------------------------------------------------------
//
// Modifications from the original Activision code:
//
// - Prevented crashes
//
//----------------------------------------------------------------------------

#include <iostream>

#include "c3.h"

#ifdef __AUI_USE_SDL__

#include "civ3_main.h"

#include "aui_mouse.h"
#include "aui_keyboard.h"
#include "aui_joystick.h"
#include "aui_sdlsurface.h"
#include "aui_sdlmouse.h"
#include "aui_sdlmoviemanager.h"

#include "aui_sdlui.h"

extern BOOL			g_exclusiveMode;

#include "civapp.h"
extern CivApp		*g_civApp;

#include "display.h"

extern BOOL					g_createDirectDrawOnSecondary;
extern sint32				g_ScreenWidth;
extern sint32				g_ScreenHeight;
extern DisplayDevice		g_displayDevice;

extern uint32 g_SDL_flags; //See ctp2_code/ctp/civ3_main.cpp
extern sint32 g_is565Format;

aui_SDLUI::aui_SDLUI
(
	AUI_ERRCODE *retval,
	HINSTANCE hinst,
	HWND hwnd,
	sint32 width,
	sint32 height,
	sint32 bpp,
	const MBCHAR *ldlFilename,
	BOOL useExclusiveMode
)
:   aui_UI              (),
    aui_SDL             (),
    m_SDLWindow         (0),
    m_SDLRenderer       (0),
    m_SDLTexture        (0)
{

	*retval = aui_Region::InitCommon( 0, 0, 0, width, height );
	Assert( AUI_SUCCESS(*retval) );
	if ( !AUI_SUCCESS(*retval) ) return;

	Assert( aui_Base::GetBaseRefCount() == 2 );
	g_ui = aui_Base::GetBaseRefCount() == 2 ? this : NULL;

	*retval = aui_UI::InitCommon( hinst, hwnd, bpp, ldlFilename );
	Assert( AUI_SUCCESS(*retval) );
	if ( !AUI_SUCCESS(*retval) ) return;

	*retval = InitCommon();
	Assert( AUI_SUCCESS(*retval) );
	if ( !AUI_SUCCESS(*retval) ) return;

	*retval = CreateNativeScreen( useExclusiveMode );
	Assert( AUI_SUCCESS(*retval) );
	if ( !AUI_SUCCESS(*retval) ) return;
}

AUI_ERRCODE aui_SDLUI::InitCommon()
{
	m_savedMouseAnimFirstIndex = 0;
	m_savedMouseAnimLastIndex = 0;
	m_savedMouseAnimCurIndex = 0;

	return AUI_ERRCODE_OK;
}

AUI_ERRCODE aui_SDLUI::DestroyNativeScreen(void)
{
	if (m_primary)
	{
		delete m_primary;
		m_primary   = NULL;
	}

	return AUI_ERRCODE_OK;
}

AUI_ERRCODE aui_SDLUI::CreateNativeScreen( BOOL useExclusiveMode )
{
	AUI_ERRCODE errcode = aui_SDL::InitCommon( useExclusiveMode );
	Assert( AUI_SUCCESS(errcode) );
	if ( !AUI_SUCCESS(errcode) ) return errcode;

	m_pixelFormat = aui_Surface::TransformBppToSurfacePixelFormat(m_bpp);
	m_SDLWindow = SDL_CreateWindow("Call To Power 2", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
		m_width, m_height, g_SDL_flags);
	if (!m_SDLWindow) {
		c3errors_FatalDialog("aui_SDLUI", "SDL window creation failed:\n%s\n", SDL_GetError());
	}
	m_SDLRenderer = SDL_CreateRenderer(m_SDLWindow, -1, 0);
	if (!m_SDLRenderer) {
		c3errors_FatalDialog("aui_SDLUI", "SDL renderer creation failed:\n%s\n", SDL_GetError());
	}
	SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "linear");
	SDL_RenderSetLogicalSize(m_SDLRenderer, m_width, m_height);
	m_SDLTexture = SDL_CreateTexture(m_SDLRenderer, aui_SDLSurface::TransformSurfacePixelFormatToSDL(m_pixelFormat),
		SDL_TEXTUREACCESS_STREAMING, m_width, m_height);
	if (!m_SDLTexture) {
		c3errors_FatalDialog("aui_SDLUI", "SDL texture creation failed:\n%s\n", SDL_GetError());
 	}

	m_primary = new aui_SDLSurface(&errcode, m_width, m_height, m_bpp, NULL, TRUE);
	Assert( AUI_NEWOK(m_primary,errcode) );
	if ( !AUI_NEWOK(m_primary,errcode) ) return AUI_ERRCODE_MEMALLOCFAILED;

	if(!m_secondary) {
		m_secondary = new aui_SDLSurface(&errcode, m_width, m_height, m_bpp, NULL, FALSE);
		Assert( AUI_NEWOK(m_secondary,errcode) );
		if ( !AUI_NEWOK(m_secondary,errcode) ) return AUI_ERRCODE_MEMALLOCFAILED;
	}

	m_pixelFormat = m_primary->PixelFormat();

	return AUI_ERRCODE_OK;
}

aui_SDLUI::~aui_SDLUI( void )
{
	if (m_SDLTexture) {
		SDL_DestroyTexture(m_SDLTexture);
		m_SDLTexture = NULL;
	}
	if (m_SDLRenderer) {
		SDL_DestroyRenderer(m_SDLRenderer);
		m_SDLRenderer = NULL;
	}
	if (m_SDLWindow) {
		SDL_DestroyWindow(m_SDLWindow);
		m_SDLWindow = NULL;
	}
}

AUI_ERRCODE aui_SDLUI::TearDownMouse(void)
{
	if (m_mouse) {
		m_mouse->GetAnimIndexes(&m_savedMouseAnimFirstIndex, &m_savedMouseAnimLastIndex);
		m_savedMouseAnimCurIndex = m_mouse->GetCurrentCursorIndex();
		m_savedMouseAnimDelay = (sint32)m_mouse->GetAnimDelay();

		if ( m_minimize || m_exclusiveMode )
		{
#if 0
			SetCursorPos( m_mouse->X(), m_mouse->Y() );
#endif
		}

		m_mouse->End();
		delete m_mouse;
		m_mouse = NULL;
	}

	return AUI_ERRCODE_OK;
}

AUI_ERRCODE aui_SDLUI::RestoreMouse(void)
{
	AUI_ERRCODE		auiErr;
	BOOL			exclusive = TRUE;

	aui_SDLMouse *mouse = new aui_SDLMouse( &auiErr, "CivMouse", exclusive );
	Assert(mouse != NULL);
	if ( !mouse ) return AUI_ERRCODE_MEMALLOCFAILED;

	delete m_mouse;
	m_mouse = mouse;

	m_mouse->SetAnimIndexes(m_savedMouseAnimFirstIndex, m_savedMouseAnimLastIndex);
	m_mouse->SetCurrentCursor(m_savedMouseAnimCurIndex);
	m_mouse->SetAnimDelay((uint32)m_savedMouseAnimDelay);

	auiErr = m_mouse->Start();
	Assert(auiErr == AUI_ERRCODE_OK);
	if ( auiErr != AUI_ERRCODE_OK ) return auiErr;

	if ( m_minimize || m_exclusiveMode )
	{
		POINT point;
		//GetCursorPos( &point );
		m_mouse->SetPosition( &point );
	}

	return AUI_ERRCODE_OK;
}

AUI_ERRCODE aui_SDLUI::AltTabOut( void )
{
	Assert(0);

	if(m_keyboard) m_keyboard->Unacquire();
	if ( m_joystick ) m_joystick->Unacquire();

	if (m_mouse) {
		if (g_exclusiveMode) {
			TearDownMouse();
		} else {
			main_RestoreTaskBar();

			if (!m_mouse->IsSuspended()) {
				m_mouse->Suspend(FALSE);
				m_mouse->Unacquire();
			}
		}
	}

	if ( m_minimize || m_exclusiveMode )
	{
		DestroyNativeScreen();
	}

#if 0
	while ( ShowCursor( TRUE ) < 0 )
		;

	if ( m_minimize || m_exclusiveMode )
	{
		while ( !IsIconic( m_hwnd ) )
			::ShowWindow( m_hwnd, SW_MINIMIZE );
	}
#endif
	if (g_civApp)
	{
		g_civApp->SetInBackground(TRUE);
	}

	return AUI_ERRCODE_OK;
}

AUI_ERRCODE aui_SDLUI::AltTabIn( void )
{
	Assert(0);

	if ( !m_primary ) CreateNativeScreen( m_exclusiveMode );

#if 0
	if ( m_minimize || m_exclusiveMode )
		while ( GetForegroundWindow() != m_hwnd )
			::ShowWindow( m_hwnd, SW_RESTORE );
	::ShowWindow(m_hwnd, SW_SHOWMAXIMIZED);

	while ( ShowCursor( FALSE ) >= 0 )
		;

	if (g_exclusiveMode) {
		RestoreMouse();
	} else {
		if ( m_minimize || m_exclusiveMode )
		{
			POINT point;
			GetCursorPos( &point );
			m_mouse->SetPosition( &point );
		}

		if (m_mouse) {
			m_mouse->Acquire();
			m_mouse->Resume();
		}

		main_HideTaskBar();

		RECT clipRect = { 0, 0, m_width, m_height };
		ClipCursor(&clipRect);
	}
#endif
	if ( m_joystick ) m_joystick->Acquire();
	if (m_keyboard) m_keyboard->Acquire();

	if (g_civApp)
	{
		g_civApp->SetInBackground(FALSE);
	}

	return FlushDirtyList();
}

aui_MovieManager* aui_SDLUI::CreateMovieManager( void ) {
	Assert(m_SDLWindow);
	Assert(m_SDLRenderer);
	Assert(m_SDLTexture);
	int windowWidth;
	int windowHeight;
	SDL_GetWindowSize(m_SDLWindow, &windowWidth, &windowHeight);
	return new aui_SDLMovieManager(m_SDLRenderer, m_SDLTexture, windowWidth, windowHeight);
}

AUI_ERRCODE aui_SDLUI::SDLDrawScreen( void ) {
    Assert(m_primary);
    Assert(m_SDLTexture);
    Assert(m_SDLRenderer);
    int errcode;
    errcode= SDL_UpdateTexture(m_SDLTexture, NULL, m_primary->Buffer(), m_primary->Pitch());
    if (errcode < 0) std::cerr << "SDL error: " << SDL_GetError() << std::endl;
    errcode= SDL_RenderClear(m_SDLRenderer);
    if (errcode < 0) std::cerr << "SDL error: " << SDL_GetError() << std::endl;
    errcode= SDL_RenderCopy(m_SDLRenderer, m_SDLTexture, NULL, NULL);
    if (errcode < 0) std::cerr << "SDL error: " << SDL_GetError() << std::endl;

    aui_SDLMouse *sdlMouse = static_cast<aui_SDLMouse*>(g_ui->TheMouse());
    if (sdlMouse && sdlMouse->GetCursorTexture()) {
        SDL_Rect destRect;
        POINT pos = sdlMouse->GetPosition();
        POINT hotspot = sdlMouse->GetHotspot();
        destRect.x = pos.x - hotspot.x;
        destRect.y = pos.y - hotspot.y;
        SDL_QueryTexture(sdlMouse->GetCursorTexture(), NULL, NULL, &destRect.w, &destRect.h);
        SDL_RenderCopy(m_SDLRenderer, sdlMouse->GetCursorTexture(), NULL, &destRect);
    }

    SDL_RenderPresent(m_SDLRenderer);

    if (errcode < 0)
      return AUI_ERRCODE_SURFACEFAILURE;
    else
      return AUI_ERRCODE_OK;
}

#endif  // __AUI_USE_SDL__
