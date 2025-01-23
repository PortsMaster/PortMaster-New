#include "ctp2_config.h"
#include "c3.h"

#ifdef __AUI_USE_SDL__

#include "aui_ui.h"
#include "aui_sdlmouse.h"
#include "aui_sdlui.h"

#include "ctp2_listbox.h"
#include "c3_listbox.h"
#include "aui_ranger.h"

#include "civapp.h"
#include "aui_sdlsurface.h"

#include "profileDB.h"

extern CivApp           *g_civApp;

uint32 HandleMouseAnimation(uint32 interval, void *param) {
	aui_SDLMouse *mouse = (aui_SDLMouse*) param;
	mouse->HandleAnim();
	return interval;
}

aui_SDLMouse::aui_SDLMouse(
   AUI_ERRCODE *retval,
   const MBCHAR *ldlBlock,
   BOOL useExclusiveMode)
   :
   aui_Input(),
   aui_Mouse(retval, ldlBlock),
   aui_SDLInput(retval, useExclusiveMode),
   m_currentCursor(NULL),
   m_animationTimer(0),
   m_lastFrameTick(0),
   m_cursorTexture(NULL)
{
	Assert(AUI_SUCCESS(*retval));
	if (!AUI_SUCCESS(*retval)) return;

	int x = 0, y = 0;
	SDL_GetMouseState(&x, &y);
	m_data.position.x = x;
	m_data.position.y = y;
}

aui_SDLMouse::~aui_SDLMouse()
{
    if (m_animationTimer) {
        SDL_RemoveTimer(m_animationTimer);
        m_animationTimer = 0;
    }
    if (m_cursorTexture) {
        SDL_DestroyTexture(m_cursorTexture);
    }
    End();
}

void HandleMouseWheel(sint16 delta)
{
	if (!g_civApp) return;

	aui_Ranger *box2 = aui_Ranger::GetMouseFocusRanger();
	if (box2 != NULL)
	{
		if (delta)
		{
			if (delta < 0)
			{
				box2->ForceScroll(0, 1);
			}
			else
			{
				box2->ForceScroll(0, -1);
			}
			return;
		}
	}
	else { // handl mouse wheel for other element than scroll boxes, e.g. scroll map
 	}
}

AUI_ERRCODE aui_SDLMouse::HandleAnim() {
	Assert(m_lastIndex > m_firstIndex);
	Assert(m_curCursor >= m_cursors + m_firstIndex);

	if (m_curCursor++ >= m_cursors + m_lastIndex) {
		m_curCursor = m_cursors + m_firstIndex;
	}
	ActivateCursor(*m_curCursor);
	return AUI_ERRCODE_HANDLED;
}

sint32 aui_SDLMouse::ManipulateInputs(aui_MouseEvent *data, BOOL add) {
	Assert(!add);

	SDL_PumpEvents();

	SDL_Event sdlEvents[k_MOUSE_MAXINPUT];
	// check for mouse events
	int numberSDLEvents = SDL_PeepEvents(sdlEvents, k_MOUSE_MAXINPUT, SDL_GETEVENT, SDL_MOUSEMOTION, SDL_MOUSEWHEEL);
	if (0 > numberSDLEvents) {
		// fprintf(stderr, "%s L%d: Mouse PeepEvents failed: %s\n", __FILE__, __LINE__, SDL_GetError());
		return 0;
	}

	int numberEvents = 0;
	for (int i = 0; i < numberSDLEvents; i++) {
		aui_MouseEvent *event = data + numberEvents;
		switch (sdlEvents[i].type) {
			case SDL_MOUSEMOTION: {
				SDL_MouseMotionEvent *motionEvent = &(sdlEvents[i].motion);
				event->time = motionEvent->timestamp;
				event->position.x = motionEvent->x;
				event->position.y = motionEvent->y;
				event->lbutton = ((motionEvent->state & SDL_BUTTON_LMASK) != 0);
				event->rbutton = ((motionEvent->state & SDL_BUTTON_RMASK) != 0);
				numberEvents++;
				break;
			}
			case SDL_MOUSEBUTTONDOWN:
			case SDL_MOUSEBUTTONUP: {
				SDL_MouseButtonEvent *buttonEvent = &(sdlEvents[i].button);
				event->time = buttonEvent->timestamp;
				event->position.x = buttonEvent->x;
				event->position.y = buttonEvent->y;
				if (buttonEvent->button == SDL_BUTTON_LEFT) {
					event->lbutton = (buttonEvent->state == SDL_PRESSED);
				} else if (buttonEvent->button == SDL_BUTTON_RIGHT) {
					event->rbutton = (buttonEvent->state == SDL_PRESSED);
				}
				numberEvents++;
				break;
			}
			case SDL_MOUSEWHEEL: {
				if (sdlEvents[i].wheel.y > 0) {
					HandleMouseWheel((sint16) 1);
				} else if (sdlEvents[i].wheel.y < 0) {
					HandleMouseWheel((sint16) -1);
				}
				break;
			}
			default:
				printf("event not handled: %d\n", sdlEvents[i].type);
				break;
		}
	}

	uint32 currentFrameTick = SDL_GetTicks();
	if (numberEvents) {
		m_lastFrameTick = currentFrameTick;
		m_data = data[numberEvents - 1];
	} else {
		// generate at least a single event every x ticks to force a redraw
		const int FRAMES_PER_SECOND = 60;
		const int TICKS_PER_FRAME = 1000 / FRAMES_PER_SECOND;
		if (currentFrameTick > m_lastFrameTick + TICKS_PER_FRAME) {
			m_lastFrameTick = currentFrameTick;
			data[0] = m_data;
			data[0].time = currentFrameTick;
			numberEvents = 1;
		}
	}
	return numberEvents;
}

void aui_SDLMouse::SetAnimIndexes(sint32 firstIndex, sint32 lastIndex) {
	if (firstIndex == m_firstIndex && lastIndex == m_lastIndex)
		return;

	if (m_animationTimer) {
		SDL_RemoveTimer(m_animationTimer);
		m_animationTimer = 0;
	}
	aui_Mouse::SetAnimIndexes(firstIndex, lastIndex);
	if (firstIndex != lastIndex) {
		m_animationTimer = SDL_AddTimer(m_animDelay, HandleMouseAnimation, this);
	}
}

void aui_SDLMouse::ActivateCursor(aui_Cursor *cursor)
{
    if (cursor != m_currentCursor) {
        printf("Activating cursor\n");
        aui_Surface *cursorSurface = cursor->TheSurface();
        aui_SDLSurface *sdlCursorSurface = dynamic_cast<aui_SDLSurface *>(cursorSurface);
        if (sdlCursorSurface != NULL) {
            cursor->GetHotspot(m_hotspot);
            printf("Got hotspot: %d, %d\n", m_hotspot.x, m_hotspot.y);
            
            static bool cursorHidden = false;
            if (!cursorHidden) {
                SDL_ShowCursor(SDL_DISABLE);
                cursorHidden = true;
                printf("Hardware cursor hidden\n");
            }

            if (m_cursorTexture) {
                SDL_DestroyTexture(m_cursorTexture);
            }

            aui_SDLUI *sdlUI = static_cast<aui_SDLUI*>(g_ui);
            m_cursorTexture = SDL_CreateTextureFromSurface(sdlUI->m_SDLRenderer, sdlCursorSurface->GetSDLSurface());
            if (m_cursorTexture) {
                printf("Created cursor texture successfully\n");
                SDL_SetTextureBlendMode(m_cursorTexture, SDL_BLENDMODE_BLEND);
            } else {
                printf("Failed to create cursor texture: %s\n", SDL_GetError());
            }
            m_currentCursor = cursor;
        } else {
            printf("Failed to get SDL surface for cursor\n");
        }
    }
}

AUI_ERRCODE	aui_SDLMouse::BltWindowToPrimary(aui_Window *window)
{
	AUI_ERRCODE retcode = AUI_ERRCODE_OK;

	sint32 windowX = window->X();
	sint32 windowY = window->Y();
	aui_Surface *windowSurface = window->TheSurface();
	aui_DirtyList *windowDirtyList = window->GetDirtyList();

	ListPos position = windowDirtyList->GetHeadPosition();
	for (sint32 j = windowDirtyList->L(); j; j--)
	{
		RECT *windowDirtyRect = windowDirtyList->GetNext(position);

		RECT screenDirtyRect = *windowDirtyRect;
		OffsetRect(&screenDirtyRect, windowX, windowY);

		AUI_ERRCODE errcode = g_ui->BltToSecondary(
				screenDirtyRect.left,
				screenDirtyRect.top,
				windowSurface,
				windowDirtyRect,
				k_AUI_BLITTER_FLAG_COPY );
		Assert( errcode == AUI_ERRCODE_OK );
		if ( errcode != AUI_ERRCODE_OK )
		{
			retcode = AUI_ERRCODE_BLTFAILED;
			break;
		}
	}

	return retcode;
}

AUI_ERRCODE	aui_SDLMouse::BltDirtyRectInfoToPrimary()
{
	AUI_ERRCODE retcode = AUI_ERRCODE_OK;
	AUI_ERRCODE errcode;

	if (g_civApp->IsInBackground()) return AUI_ERRCODE_OK;

	tech_WLList<aui_UI::DirtyRectInfo *> *driList = g_ui->GetDirtyRectInfoList();

	uint32 blitFlags;
	LPVOID primaryBuf = NULL;

	if (g_theProfileDB && g_theProfileDB->IsUseDirectXBlitter())
	{
		blitFlags = k_AUI_BLITTER_FLAG_COPY;
	}
	else
	{
		blitFlags = k_AUI_BLITTER_FLAG_COPY | k_AUI_BLITTER_FLAG_FAST;
		errcode = g_ui->Secondary()->Lock(NULL, &primaryBuf, 0);
		Assert( errcode == AUI_ERRCODE_OK );
	}

	ListPos position = driList->GetHeadPosition();
	for (sint32 j = driList->L(); j; j--)
	{
		aui_UI::DirtyRectInfo *dri = driList->GetNext(position);

		aui_Window *window = dri->window;

		sint32 windowX = window->X();
		sint32 windowY = window->Y();
		aui_Surface *windowSurface = window->TheSurface();

		if (!windowSurface) continue;

		if (g_civApp->IsInBackground()) continue;

		RECT *windowDirtyRect = &dri->rect;

		RECT screenDirtyRect = *windowDirtyRect;
		OffsetRect(&screenDirtyRect, windowX, windowY);

		if (!g_civApp->IsInBackground()) // Actual Drawing
		{
			errcode = g_ui->BltToSecondary(
					screenDirtyRect.left,
					screenDirtyRect.top,
					windowSurface,
					windowDirtyRect,
					blitFlags);
			Assert(errcode == AUI_ERRCODE_OK);
			if (errcode != AUI_ERRCODE_OK)
			{
				retcode = AUI_ERRCODE_BLTFAILED;
				break;
			}
		}
	}

	errcode = g_ui->BltSecondaryToPrimary(blitFlags);
	Assert(errcode == AUI_ERRCODE_OK);
	if (errcode != AUI_ERRCODE_OK)
	{
		retcode = AUI_ERRCODE_BLTFAILED;
	}

	if (!g_theProfileDB || !g_theProfileDB->IsUseDirectXBlitter())
	{
		errcode = g_ui->Secondary()->Unlock( primaryBuf );
		Assert( errcode == AUI_ERRCODE_OK );
	}
	return retcode;
}

AUI_ERRCODE	aui_SDLMouse::BltBackgroundColorToPrimary(COLORREF color, aui_DirtyList *colorAreas)
{
	if (g_civApp->IsInBackground()) return AUI_ERRCODE_OK;

	ListPos position = colorAreas->GetHeadPosition();
	for (sint32 j = colorAreas->L(); j; j--)
	{
		RECT *screenDirtyRect = colorAreas->GetNext(position);
		AUI_ERRCODE errcode = g_ui->ColorBltToSecondary(screenDirtyRect, color,0);
		Assert(errcode == AUI_ERRCODE_OK);
		if (errcode != AUI_ERRCODE_OK)
		{
			return AUI_ERRCODE_BLTFAILED;
		}
	}

	return AUI_ERRCODE_OK;
}

AUI_ERRCODE	aui_SDLMouse::BltBackgroundImageToPrimary(aui_Image *image, RECT *imageRect, aui_DirtyList *imageAreas)
{
	if (g_civApp->IsInBackground()) return AUI_ERRCODE_OK;

	ListPos position = imageAreas->GetHeadPosition();
	for ( sint32 j = imageAreas->L(); j; j-- )
	{
		RECT *screenDirtyRect = imageAreas->GetNext(position);
		AUI_ERRCODE errcode = g_ui->BltToSecondary(
			screenDirtyRect->left,
			screenDirtyRect->top,
			image->TheSurface(),
			screenDirtyRect,
			k_AUI_BLITTER_FLAG_COPY);

		Assert(errcode == AUI_ERRCODE_OK);
		if (errcode != AUI_ERRCODE_OK)
		{
			return AUI_ERRCODE_BLTFAILED;
		}
	}

	return AUI_ERRCODE_OK;
}

#endif
