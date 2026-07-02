/*
 * steam_stub.c — Minimal Steam API stub for The Impossible Game
 *
 * Does absolutely nothing to check for game ownership or DRM — the app would
 * immediately crash if it actually tried to verify a license. This stub only
 * provides just enough for the game to initialize, register callbacks, and
 * request stats/achievements without crashing.
 * The game binary links against libsteam_api.so and calls into it at startup
 * to initialise Steam, register callbacks, and request stats/achievements.
 *
 * Build (x86 32-bit):
 *   gcc -m32 -shared -fPIC -o libsteam_api.so steam_stub.c
 */

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>  /* NULL */

/* Generic vtable infrastructure */

typedef void* (*VFunc)(void*);

static void* ret_null(void *self) { (void)self; return NULL; }
static void* ret_void(void *self) { (void)self; return NULL; }

/* Generic object: 64-slot vtable, all entries are ret_null.
   Every interface function that the game might call virtual methods on
   returns this object so no slot is ever NULL. */
#define GENERIC_VTABLE_SIZE 64
VFunc generic_vtable[GENERIC_VTABLE_SIZE];

__attribute__((constructor))
static void init_generic_vtable(void) {
    for (int i = 0; i < GENERIC_VTABLE_SIZE; i++)
        generic_vtable[i] = ret_null;
}

static void* generic_obj[] = { generic_vtable };

/* Core Steam API functions */

bool SteamAPI_Init(void)                                    { return true;  }
bool SteamAPI_RestartAppIfNecessary(uint32_t app_id)        { (void)app_id; return false; }
void SteamAPI_RunCallbacks(void)                            {}
void SteamAPI_RegisterCallResult(void)                      {}
void SteamAPI_UnregisterCallResult(void)                    {}
void SteamAPI_RegisterCallback(void *cb, int id)            { (void)cb; (void)id; }
void SteamAPI_UnregisterCallback(void *cb)                  { (void)cb; }

/* Simple interface accessors */

void* SteamRemoteStorage(void) { return generic_obj; }
void* SteamUser(void)          { return generic_obj; }
void* SteamUserStats(void)     { return generic_obj; }
void* SteamFriends(void)       { return generic_obj; }
void* SteamUtils(void)         { return generic_obj; }
void* SteamMatchmaking(void)   { return generic_obj; }
void* SteamApps(void)          { return generic_obj; }
void* SteamNetworking(void)    { return generic_obj; }
void* SteamScreenshots(void)   { return generic_obj; }
void* SteamHTTP(void)          { return generic_obj; }
void* SteamUnifiedMessages(void){ return generic_obj; }

/* ISteamClient vtable */

static void* isc_CreateSteamPipe(void *s)             { (void)s; return NULL; }
static void* isc_BReleaseSteamPipe(void *s)           { (void)s; return NULL; }
static void* isc_ConnectToGlobalUser(void *s)         { (void)s; return NULL; }
static void* isc_CreateLocalUser(void *s)             { (void)s; return NULL; }
static void* isc_ReleaseUser(void *s)                 { (void)s; return NULL; }
static void* isc_GetISteamUser(void *s)               { (void)s; return generic_obj; }
static void* isc_GetISteamGameServer(void *s)         { (void)s; return generic_obj; }
static void* isc_SetLocalIPBinding(void *s)           { (void)s; return NULL; }
static void* isc_GetISteamFriends(void *s)            { (void)s; return generic_obj; }
static void* isc_GetISteamUtils(void *s)              { (void)s; return generic_obj; }
static void* isc_GetISteamMatchmaking(void *s)        { (void)s; return generic_obj; }
static void* isc_GetISteamMatchmakingServers(void *s) { (void)s; return generic_obj; }
static void* isc_GetISteamGenericInterface(void *s)   { (void)s; return generic_obj; }
static void* isc_GetISteamUserStats(void *s)          { (void)s; return generic_obj; }
static void* isc_GetISteamGameServerStats(void *s)    { (void)s; return generic_obj; }
static void* isc_GetISteamApps(void *s)               { (void)s; return generic_obj; }
static void* isc_GetISteamNetworking(void *s)         { (void)s; return generic_obj; }
static void* isc_GetISteamRemoteStorage(void *s)      { (void)s; return generic_obj; }
static void* isc_GetISteamScreenshots(void *s)        { (void)s; return generic_obj; }
/* Slots beyond index 18 are unknown but must not be NULL. */
static void* isc_unknown(void *s)                     { (void)s; return generic_obj; }

#define STEAMCLIENT_VTABLE_SIZE 64
VFunc steamclient_vtable[STEAMCLIENT_VTABLE_SIZE];

__attribute__((constructor))
static void init_steamclient_vtable(void) {
    for (int i = 0; i < STEAMCLIENT_VTABLE_SIZE; i++)
        steamclient_vtable[i] = isc_unknown;
    steamclient_vtable[0]  = isc_CreateSteamPipe;
    steamclient_vtable[1]  = isc_BReleaseSteamPipe;
    steamclient_vtable[2]  = isc_ConnectToGlobalUser;
    steamclient_vtable[3]  = isc_CreateLocalUser;
    steamclient_vtable[4]  = isc_ReleaseUser;
    steamclient_vtable[5]  = isc_GetISteamUser;
    steamclient_vtable[6]  = isc_GetISteamGameServer;
    steamclient_vtable[7]  = isc_SetLocalIPBinding;
    steamclient_vtable[8]  = isc_GetISteamFriends;
    steamclient_vtable[9]  = isc_GetISteamUtils;
    steamclient_vtable[10] = isc_GetISteamMatchmaking;
    steamclient_vtable[11] = isc_GetISteamMatchmakingServers;
    steamclient_vtable[12] = isc_GetISteamGenericInterface;
    steamclient_vtable[13] = isc_GetISteamUserStats;
    steamclient_vtable[14] = isc_GetISteamGameServerStats;
    steamclient_vtable[15] = isc_GetISteamApps;
    steamclient_vtable[16] = isc_GetISteamNetworking;
    steamclient_vtable[17] = isc_GetISteamRemoteStorage;
    steamclient_vtable[18] = isc_GetISteamScreenshots;
}

static void* steamclient_obj[] = { steamclient_vtable };
void* SteamClient(void) { return steamclient_obj; }
