This is not an actual steam emulator. This does not break, bypass or circumvent any DRM or license checks. The game does not perform license checks in the first place.
If the game actually checked for licenses or app ownership the game would simply crash and exit because the neccessary functions are not defined here.
All it does is tell the app that steam is running, and return stub values to some function calls related to highscores and leaderboards, allowing the game's social features to fail gracefully.
This was implemented clean room by just looking where the game was crashing in gdb, no Valve documentation or Decompilation was used. Thank you Terry for leaving debug symbols in your game. <3
For full disclosure, the source code is included, licensed as MIT. If there are any concerns, please contact me. Cheers, BinaryCounter.

Source (steam_stub.c): 

// Does absolutely nothing, doesn't even include the functions to perform license checks. 
// The app would immediately crash if it actually tried to check for game ownership
// Implements juuuuust enough for the game to ask for leaderboards and never get an answer

//  Build with:
//  gcc -shared -fPIC -o libsteam_api.so steam_stub.c

#include <stdbool.h>
#include <stdint.h>

typedef char (*VirtualFunction)(void* this_ptr);
struct clazz {VirtualFunction* vtable;};

char ret0() {return 0;} //For when we just want to return 0 in virtual functions
bool SteamAPI_Init() { return true; } //Steam is "running"
bool SteamAPI_RestartAppIfNecessary(uint32_t app_id) { return false; } // Never restart the app
void SteamAPI_RunCallbacks() {} //We don't do any callbacks
void SteamAPI_RegisterCallResult() {} 
void SteamAPI_UnregisterCallResult() {}
// SteamRemoteStorage
VirtualFunction storage_vtable[] = {[0x90/sizeof(VirtualFunction)] = ret0}; // Some sort of highscore getter
struct clazz storage_class = { storage_vtable };
void* SteamRemoteStorage(void) {return &storage_class;}
//SteamUser
VirtualFunction user_vtable[] = {};
struct clazz user_class = { user_vtable };
void* SteamUser(void) {return &user_class;}
//SteamUserStats
VirtualFunction userstats_vtable[]={[0xb8/sizeof(VirtualFunction)] = ret0, // Associated with finding leaderboards
                                    [0x38/sizeof(VirtualFunction)] = ret0, // Obviously the function to set achievements, takes a string parameter like "ACHIEVEMENT_HEXAGON", returns nothing
                                    [0x50/sizeof(VirtualFunction)] = ret0};// No idea what this does, but gets called after setting achievements
struct clazz userstats_class = { userstats_vtable };
void* SteamUserStats(void) {return &userstats_class;}