This is not an actual steam emulator. This does not break, bypass or circumvent any DRM or license checks. The game does not perform license checks in the first place.
If the game actually checked for licenses or app ownership the game would simply crash and exit because the neccessary functions are not defined here.
All it does is tell the app that steam is running (but we're not logged in and the game has no valid app ID), and provide stub implementations for some functions related to achievements, allowing the game to interact with them without crashing.
This was implemented clean room by just looking where the game was crashing in gdb, no Valve documentation or Decompilation was used.
For full disclosure, the source code is included, licensed as MIT. If there are any concerns, please contact me. Cheers, BinaryCounter.

Source (steam_stub.c): 

// Does absolutely nothing, doesn't even include the functions to perform license checks.
// The app would immediately crash if it actually tried to check for game ownership
// Implements juuuuust enough for the game to be able to send achievements into the void

//  Build with:
//  gcc -shared -fPIC -o libsteam_api.so steam_stub.c

#include <stdbool.h>
#include <stdint.h>

typedef char (*VirtualFunction)(void* this_ptr);
struct clazz {VirtualFunction* vtable;};

char ret0() {return 0;} //For when we just want to return 0 in virtual functions
bool SteamAPI_Init() { return true; } //Steam is "running"
void SteamAPI_RegisterCallback() {} //We don't do any callbacks
void SteamAPI_RunCallbacks() {}
void SteamAPI_UnregisterCallback() {}
//SteamUser
VirtualFunction user_vtable[] = {[0x04/sizeof(VirtualFunction)] = ret0}; //Checks if user is logged in. We return false (truthfully)
struct clazz user_class = { user_vtable };
void* SteamUser(void) {return &user_class;}
//SteamClient
VirtualFunction client_vtable[] = {
[0x54/sizeof(VirtualFunction)] = ret0};  // Sets a handler for steam error messages. Just return 0....
struct clazz client_class = { client_vtable };
void* SteamClient(void) {return &client_class;}
//SteamUtils
VirtualFunction utils_vtable[] = {
[0x24/sizeof(VirtualFunction)] = ret0}; // Gets the current app ID . We don't have one, so we return 0 (invalid ID)
struct clazz utils_class = { utils_vtable };
void* SteamUtils(void) {return &utils_class;}
//SteamUserStats
VirtualFunction userstats_vtable[]={
                                    [0x1c/sizeof(VirtualFunction)] = ret0, // Something related to setting achievements, previously crashed the game after tutorial (first achievement)
                                    [0x38/sizeof(VirtualFunction)] = ret0, // Obviously the function to set achievements, takes a string parameter like "NEW_ACHIEVEMENT", returns nothing
                                    [0x50/sizeof(VirtualFunction)] = ret0};// No idea what this does, but gets called after setting achievements
struct clazz userstats_class = { userstats_vtable };
void* SteamUserStats(void) {return &userstats_class;}
