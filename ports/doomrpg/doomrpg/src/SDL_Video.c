

//Using SDL and standard IO
#include <SDL.h>
#include <SDL_mixer.h>
#include <stdio.h>
#include <fluidsynth.h>

#include "DoomRPG.h"
#include "Game.h"
#include "SDL_Video.h"

SDLVideo_t sdlVideo;
SDLController_t sdlController;
FluidSynth_t fluidSynth;

SDLVidModes_t sdlVideoModes[14] =
{
	{128, 128},
	{128, 160},
	{160, 128},
	{176, 208},
	{176, 220},
	{220, 176},
	{240, 320},
	{320, 200},
	{320, 240},
	{352, 416},
	{416, 352},
	{640, 360},
	{640, 480},
	{800, 600}
};

void SDL_InitVideo(void)
{
	Uint32 flags;
	int video_w, video_h;

	SDL_memset(&sdlVideo, 0, sizeof(sdlVideo));
	SDL_memset(&sdlController, 0, sizeof(sdlController));

	// Default
	sdlVideo.fullScreen = false;
	sdlVideo.vSync = false;
	sdlVideo.integerScaling = true;
	sdlVideo.resolutionIndex = 8;
	sdlVideo.displaySoftKeys = true;

	Game_loadConfig(NULL);

	SDL_SetHint(SDL_HINT_NO_SIGNAL_HANDLERS, "1");
    if (SDL_Init(SDL_INIT_EVERYTHING) < 0) {
        DoomRPG_Error("Could not initialize SDL: %s", SDL_GetError());
    }

    flags = SDL_WINDOW_OPENGL| SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE;
    video_w = sdlVideoModes[sdlVideo.resolutionIndex].width;
    video_h = sdlVideoModes[sdlVideo.resolutionIndex].height;

	SDL_SetRelativeMouseMode(SDL_TRUE);
	SDL_ShowCursor(SDL_DISABLE);

	if (sdlVideo.fullScreen) {
		flags |= SDL_WINDOW_FULLSCREEN;
	}

	// Set the highdpi flags - this makes a big difference on Macs with
	// retina displays, especially when using small window sizes.
	flags |= SDL_WINDOW_ALLOW_HIGHDPI;

	sdlVideo.window = SDL_CreateWindow("DoomRPG", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, video_w, video_h, flags);

    if (!sdlVideo.window) {
		DoomRPG_Error("Could not set %dx%d video mode: %s", video_w, video_h, SDL_GetError());
    }

	//SDL_SetHint(SDL_HINT_RENDER_DRIVER, "software");
	//SDL_SetHint(SDL_HINT_RENDER_DRIVER, "opengl");
	//SDL_SetHint(SDL_HINT_RENDER_DRIVER, "direct3d11");

	SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "nearest");
	SDL_SetHint(SDL_HINT_RENDER_VSYNC, sdlVideo.vSync ? "1" : "0");

	sdlVideo.renderer = SDL_CreateRenderer(sdlVideo.window, -1, SDL_RENDERER_ACCELERATED);

	sdlVideo.rendererW = sdlVideoModes[sdlVideo.resolutionIndex].width;
	sdlVideo.rendererH = sdlVideoModes[sdlVideo.resolutionIndex].height;

    // Since we are going to display a low resolution buffer,
    // it is best to limit the window size so that it cannot
    // be smaller than our internal buffer size.
    SDL_SetWindowMinimumSize(sdlVideo.window, sdlVideo.rendererW, sdlVideo.rendererH);
    SDL_RenderSetLogicalSize(sdlVideo.renderer, sdlVideo.rendererW, sdlVideo.rendererH);
    SDL_RenderSetIntegerScale(sdlVideo.renderer, sdlVideo.integerScaling);

	// Check for joysticks
	SDL_SetHint(SDL_HINT_JOYSTICK_RAWINPUT, "0");

	sdlController.gGameController = NULL;
	sdlController.gJoystick = NULL;
	sdlController.gJoyHaptic = NULL;
	sdlController.deadZoneLeft = 25;
	sdlController.deadZoneRight = 25;

	if (SDL_NumJoysticks() < 1) {
		printf("Warning: No joysticks connected!\n");
	}
	else {
		printf("Joysticks connected: %d\n", SDL_NumJoysticks());

		// Open game controller and check if it supports rumble
		sdlController.gGameController = SDL_GameControllerOpen(0);
		if (sdlController.gGameController) {

			// Check if joystick supports Rumble
			if (!SDL_GameControllerHasRumble(sdlController.gGameController)) {
				printf("Warning: Game controller does not have rumble! SDL Error: %s\n", SDL_GetError());
			}
		}

		// Load joystick if game controller could not be loaded
		if (sdlController.gGameController == NULL) {
			// Open first joystick
			sdlController.gJoystick = SDL_JoystickOpen(0);
			if (sdlController.gJoystick == NULL) {
				printf("Warning: Unable to open joystick! SDL Error: %s\n", SDL_GetError());
			}
			else
			{
				// Check if joystick supports haptic
				if (!SDL_JoystickIsHaptic(sdlController.gJoystick)) {
					printf("Warning: Controller does not support haptics! SDL Error: %s\n", SDL_GetError());
				}
				else
				{
					// Get joystick haptic device
					sdlController.gJoyHaptic = SDL_HapticOpenFromJoystick(sdlController.gJoystick);
					if (sdlController.gJoyHaptic == NULL) {
						printf("Warning: Unable to get joystick haptics! SDL Error: %s\n", SDL_GetError());
					}
					else
					{
						// Initialize rumble
						if (SDL_HapticRumbleInit(sdlController.gJoyHaptic) < 0) {
							printf("Warning: Unable to initialize haptic rumble! SDL Error: %s\n", SDL_GetError());
						}
					}
				}
			}
		}
	}
}

void SDL_Close(void)
{
	printf("SDL_Close\n");
	//Close game controller or joystick with haptics
	if (sdlController.gGameController) {
		SDL_GameControllerClose(sdlController.gGameController);
	}

	if (sdlController.gJoyHaptic) {
		SDL_HapticClose(sdlController.gJoyHaptic);
	}

	if (sdlController.gJoystick) {
		SDL_JoystickClose(sdlController.gJoystick);
	}

	if (sdlVideo.window) {
		SDL_SetWindowFullscreen(sdlVideo.window, 0);
	}

	if (sdlVideo.renderer) {
		SDL_DestroyRenderer(sdlVideo.renderer);
	}

	if (sdlVideo.window) {
		SDL_DestroyWindow(sdlVideo.window);
	}

    //Quit SDL subsystems
    SDL_Quit();
}

SDLVideo_t* SDL_GetVideo(void)
{
	return &sdlVideo;
}

void SDL_RenderDrawFillCircle(SDL_Renderer* renderer, int x, int y, int r)
{
	int dx, dy, accum;

	dx = r;
	dy = 0;
	accum = dx - (dy << 1) - 1;

	while (dy <= dx) {

		SDL_RenderDrawLine(renderer, dx + x, dy + y, -dx + x, dy + y);
		SDL_RenderDrawLine(renderer, dy + x, dx + y, -dy + x, dx + y);
		SDL_RenderDrawLine(renderer, -dx + x, -dy + y, dx + x, -dy + y);
		SDL_RenderDrawLine(renderer, -dy + x, -dx + y, dy + x, -dx + y);

		dy++;
		if ((accum -= (dy << 1) - 1) < 0) {
			dx--;
			accum += dx << 1;
		}
	}
}

void SDL_RenderDrawCircle(SDL_Renderer* renderer, int x, int y, int r)
{
	int dx, dy, accum;

	dx = r;
	dy = 0;
	accum = dx - (dy << 1) - 1;

	while (dy <= dx) {

		const SDL_Point points[8] = {
			{ dx + x,  dy + y},
			{-dx + x,  dy + y},
			{ dy + x,  dx + y},
			{-dy + x,  dx + y},
			{-dx + x, -dy + y},
			{ dx + x, -dy + y},
			{-dy + x, -dx + y},
			{ dy + x, -dx + y}
		};

		SDL_RenderDrawPoints(renderer, points, 8);

		dy++;
		if ((accum -= (dy << 1) - 1) < 0) {
			dx--;
			accum += dx << 1;
		}
	}
}


//---------------
void SDL_InitAudio(void)
{
	printf("SDL_InitAudio\n");

	fluidSynth.settings = NULL;
	fluidSynth.synth = NULL;
	fluidSynth.adriver = NULL;

	// create the settings
	fluidSynth.settings = new_fluid_settings();
	if (fluidSynth.settings == NULL) {
		DoomRPG_Error("Failed to create the settings");
	}

	// create the synthesizer
	fluidSynth.synth = new_fluid_synth(fluidSynth.settings);
	if (fluidSynth.synth == NULL) {
		DoomRPG_Error("Failed to create the synthesizer");
	}

	// create the audio driver
	fluidSynth.adriver = new_fluid_audio_driver(fluidSynth.settings, fluidSynth.synth);
	if (fluidSynth.synth == NULL) {
		DoomRPG_Error("Failed to create the audio driver");
	}

	if (fluid_is_soundfont("gm.sf2")) {
		fluid_synth_sfload(fluidSynth.synth, "gm.sf2", 1);
	}
	else {
		DoomRPG_Error("Cannot find the soundfont %s file", "gm.sf2");
	}

	if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) < 0) {
		DoomRPG_Error("Could not initialize SDL Mixer: %s", Mix_GetError());
	}
}

void SDL_CloseAudio(void) {

	delete_fluid_audio_driver(fluidSynth.adriver);
	delete_fluid_synth(fluidSynth.synth);
	delete_fluid_settings(fluidSynth.settings);

	Mix_Quit();
}

//--------------------

int SDL_GameControllerGetButtonID(void)
{
	int deadZoneLeft, deadZoneRight;

	deadZoneLeft = (sdlController.deadZoneLeft * 32768) / 100;
	deadZoneRight = (sdlController.deadZoneRight * 32768) / 100;

	if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_A)) {
		return CONTROLLER_BUTTON_A;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_B)) {
		return CONTROLLER_BUTTON_B;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_X)) {
		return CONTROLLER_BUTTON_X;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_Y)) {
		return CONTROLLER_BUTTON_Y;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_BACK)) {
		return CONTROLLER_BUTTON_BACK;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_START)) {
		return CONTROLLER_BUTTON_START;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_LEFTSTICK)) {
		return CONTROLLER_BUTTON_LEFT_STICK;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_RIGHTSTICK)) {
		return CONTROLLER_BUTTON_RIGHT_STICK;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_LEFTSHOULDER)) {
		return CONTROLLER_BUTTON_LEFT_BUMPER;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_RIGHTSHOULDER)) {
		return CONTROLLER_BUTTON_RIGHT_BUMPER;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_DPAD_UP)) {
		return CONTROLLER_BUTTON_DPAD_UP;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_DPAD_DOWN)) {
		return CONTROLLER_BUTTON_DPAD_DOWN;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_DPAD_LEFT)) {
		return CONTROLLER_BUTTON_DPAD_LEFT;
	}
	else if (SDL_GameControllerGetButton(sdlController.gGameController, SDL_CONTROLLER_BUTTON_DPAD_RIGHT)) {
		return CONTROLLER_BUTTON_DPAD_RIGHT;
	}
	else if (SDL_GameControllerGetAxis(sdlController.gGameController, SDL_CONTROLLER_AXIS_TRIGGERLEFT)) {
		return CONTROLLER_BUTTON_LEFT_TRIGGER;
	}
	else if (SDL_GameControllerGetAxis(sdlController.gGameController, SDL_CONTROLLER_AXIS_TRIGGERRIGHT)) {
		return CONTROLLER_BUTTON_RIGHT_TRIGGER;
	}
	else {

		// Y axis motion
		int16_t yVal = SDL_GameControllerGetAxis(sdlController.gGameController, SDL_CONTROLLER_AXIS_LEFTY);
		// Below of dead zone
		if (yVal < -deadZoneLeft) {
			return CONTROLLER_BUTTON_LAXIS_UP;
		}
		// Above of dead zone
		else if (yVal > deadZoneLeft) {
			return CONTROLLER_BUTTON_LAXIS_DOWN;
		}

		// X axis motion
		int16_t xVal = SDL_GameControllerGetAxis(sdlController.gGameController, SDL_CONTROLLER_AXIS_LEFTX);
		// Left of dead zone
		if (xVal < -deadZoneLeft) {
			return CONTROLLER_BUTTON_LAXIS_LEFT;
		}
		// Right of dead zone
		else if (xVal > deadZoneLeft) {
			return CONTROLLER_BUTTON_LAXIS_RIGHT;
		}


		// Y axis motion
		yVal = SDL_GameControllerGetAxis(sdlController.gGameController, SDL_CONTROLLER_AXIS_RIGHTY);
		// Below of dead zone
		if (yVal < -deadZoneRight) {
			return CONTROLLER_BUTTON_RAXIS_UP;
		}
		// Above of dead zone
		else if (yVal > deadZoneRight) {
			return CONTROLLER_BUTTON_RAXIS_DOWN;
		}

		// X axis motion
		xVal = SDL_GameControllerGetAxis(sdlController.gGameController, SDL_CONTROLLER_AXIS_RIGHTX);
		// Left of dead zone
		if (xVal < -deadZoneRight) {
			return CONTROLLER_BUTTON_RAXIS_LEFT;
		}
		// Right of dead zone
		else if (xVal > deadZoneRight) {
			return CONTROLLER_BUTTON_RAXIS_RIGHT;
		}
	}

	return CONTROLLER_BUTTON_INVALID;
}

char buttonNames[][16] = {
	"Gamepad A",
	"Gamepad B",
	"Gamepad X",
	"Gamepad Y",
	"Back",
	"Start",
	"Left Stick",
	"Right Stick",
	"Left Bumper",
	"Right Bumper",
	"D-Pad Up",
	"D-Pad Down",
	"D-Pad Left",
	"D-Pad Right",
	"L-Stick Up",
	"L-Stick Down",
	"L-Stick Left",
	"L-Stick Right",
	"R-Stick Up",
	"R-Stick Down",
	"R-Stick Left",
	"R-Stick Right",
	"Left Trigger",
	"Right Trigger"
};

char *SDL_GameControllerGetNameButton(int id) {

	if (id != CONTROLLER_BUTTON_INVALID) {
		return buttonNames[id];
	}

	return "";
}

int SDL_JoystickGetButtonID(void)
{
	int numAxes, deadZoneLeft, deadZoneRight;

	deadZoneLeft = (sdlController.deadZoneLeft * 32768) / 100;
	deadZoneRight = (sdlController.deadZoneRight * 32768) / 100;

	if (SDL_JoystickGetButton(sdlController.gJoystick, 0)) {
		return CONTROLLER_BUTTON_Y;
	}
	else if (SDL_JoystickGetButton(sdlController.gJoystick, 1)) {
		return CONTROLLER_BUTTON_B;
	}
	else if (SDL_JoystickGetButton(sdlController.gJoystick, 2)) {
		return CONTROLLER_BUTTON_A;
	}
	else if (SDL_JoystickGetButton(sdlController.gJoystick, 3)) {
		return CONTROLLER_BUTTON_X;
	}
	else if (SDL_JoystickGetButton(sdlController.gJoystick, 4)) {
		return CONTROLLER_BUTTON_LEFT_TRIGGER;
	}
	else if (SDL_JoystickGetButton(sdlController.gJoystick, 5)) {
		return CONTROLLER_BUTTON_RIGHT_TRIGGER;
	}
	else if (SDL_JoystickGetButton(sdlController.gJoystick, 6)) {
		return CONTROLLER_BUTTON_LEFT_BUMPER;
	}
	else if (SDL_JoystickGetButton(sdlController.gJoystick, 7)) {
		return CONTROLLER_BUTTON_RIGHT_BUMPER;
	}
	else if (SDL_JoystickGetButton(sdlController.gJoystick, 8)) {
		return CONTROLLER_BUTTON_BACK;
	}
	else if (SDL_JoystickGetButton(sdlController.gJoystick, 9)) {
		return CONTROLLER_BUTTON_START;
	}
	else {
		numAxes = SDL_JoystickNumAxes(sdlController.gJoystick);

		// Y axis motion
		int16_t yVal = SDL_JoystickGetAxis(sdlController.gJoystick, 1);
		// Below of dead zone
		if (yVal < -deadZoneLeft) {
			return (numAxes <= 2) ? CONTROLLER_BUTTON_DPAD_UP : CONTROLLER_BUTTON_LAXIS_UP;
		}
		// Above of dead zone
		else if (yVal > deadZoneLeft) {
			return (numAxes <= 2) ? CONTROLLER_BUTTON_DPAD_DOWN : CONTROLLER_BUTTON_LAXIS_DOWN;
		}

		// X axis motion
		int16_t xVal = SDL_JoystickGetAxis(sdlController.gJoystick, 0);
		// Left of dead zone
		if (xVal < -deadZoneLeft) {
			return (numAxes <= 2) ? CONTROLLER_BUTTON_DPAD_LEFT : CONTROLLER_BUTTON_LAXIS_LEFT;
		}
		// Right of dead zone
		else if (xVal > deadZoneLeft) {
			return (numAxes <= 2) ? CONTROLLER_BUTTON_DPAD_RIGHT : CONTROLLER_BUTTON_LAXIS_RIGHT;
		}

		// Y axis motion
		yVal = SDL_JoystickGetAxis(sdlController.gJoystick, 2);
		// Below of dead zone
		if (yVal < -deadZoneRight) {
			return CONTROLLER_BUTTON_RAXIS_UP;
		}
		// Above of dead zone
		else if (yVal > deadZoneRight) {
			return CONTROLLER_BUTTON_RAXIS_DOWN;
		}

		// X axis motion
		xVal = SDL_JoystickGetAxis(sdlController.gJoystick, 3);
		// Left of dead zone
		if (xVal < -deadZoneRight) {
			return CONTROLLER_BUTTON_RAXIS_LEFT;
		}
		// Right of dead zone
		else if (xVal > deadZoneRight) {
			return CONTROLLER_BUTTON_RAXIS_RIGHT;
		}
	}
	
	return CONTROLLER_BUTTON_INVALID;
}

char mouseButtonNames[][20] = {
	"Mouse Left",
	"Mouse Middle",
	"Mouse Right",
	"Mouse X1",
	"Mouse X2",
	"Mouse Wheel Up",
	"Mouse Wheel Down",
	"Mouse Motion Up",
	"Mouse Motion Down",
	"Mouse Motion Left",
	"Mouse Motion Right"
};

char* SDL_MouseGetNameButton(int id)
{
	if (id != MOUSE_BUTTON_INVALID) {
		return mouseButtonNames[id];
	}

	return "";
}

