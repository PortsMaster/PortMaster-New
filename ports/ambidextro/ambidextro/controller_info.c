#include <SDL2/SDL.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
    if (SDL_Init(SDL_INIT_GAMECONTROLLER) != 0) {
        printf("Failed to initialize SDL: %s\n", SDL_GetError());
        return 1;
    }

    int num_joysticks = SDL_NumJoysticks();
    printf("Detected controllers: %d\n", num_joysticks);

    for (int i = 0; i < num_joysticks; ++i) {
        if (SDL_IsGameController(i)) {
            SDL_JoystickGUID guid = SDL_JoystickGetDeviceGUID(i);
            char guid_str[33];
            SDL_JoystickGetGUIDString(guid, guid_str, sizeof(guid_str));

            const char* name = SDL_GameControllerNameForIndex(i);
            printf("Controller #%d\n", i);
            printf("  Name: %s\n", name);
            printf("  GUID: %s\n", guid_str);
        }
    }

    SDL_Quit();
    return 0;
}
