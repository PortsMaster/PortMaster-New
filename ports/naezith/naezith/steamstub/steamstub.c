// Minimal libsteam_api.so stand-in for Remnants of Naezith on PortMaster.
// Not a Steam emulator: it tells the game that Steam is running but not logged on, so the game
// starts in its own offline mode (scores are not submitted) and achievement calls go nowhere.
// It performs no ownership or license checks and implements none: every interface method the
// game might reach through the C++ vtables returns 0 (false / null).
// Based on BinaryCounter's Steam stub from the Papers, Please PortMaster port.
// Build: gcc -shared -fPIC -O2 -o libsteam_api.so steamstub.c

#include <stdbool.h>
#include <stdint.h>

// Generic stand-in for every Steam C++ interface (ISteamClient, ISteamUser, ...): a non-null
// object whose virtual methods all return 0.
struct dummy { void **vtable; };
static void *dummy_vtable[128];
static struct dummy dummy_iface = { dummy_vtable };
static void *dummy_method(void) { return 0; }
__attribute__((constructor)) static void init_dummy(void)
{
    for (unsigned i = 0; i < sizeof dummy_vtable / sizeof *dummy_vtable; i++)
        dummy_vtable[i] = (void *)dummy_method;
}

bool SteamAPI_Init(void) { return true; }
bool SteamAPI_IsSteamRunning(void) { return true; }
bool SteamAPI_RestartAppIfNecessary(uint32_t app_id) { (void)app_id; return false; }
void SteamAPI_Shutdown(void) {}
void SteamAPI_RunCallbacks(void) {}
void SteamAPI_RegisterCallback(void *cb, int id) { (void)cb; (void)id; }
void SteamAPI_UnregisterCallback(void *cb) { (void)cb; }
int32_t SteamAPI_GetHSteamPipe(void) { return 1; }
int32_t SteamAPI_GetHSteamUser(void) { return 1; }

void *SteamInternal_CreateInterface(const char *ver) { (void)ver; return &dummy_iface; }

// Matches the context init struct steam_api.h places in the game's own .bss:
// { void (*pFn)(void *ctx); uintptr_t counter; <context storage> }.
// The storage size belongs to the game's SDK version, so never write to it here;
// only the game's own init callback may fill it.
struct context_init { void (*init)(void *ctx); uintptr_t counter; char ctx[]; };
void *SteamInternal_ContextInit(void *data)
{
    struct context_init *c = data;
    if (c->counter != 1) {
        c->counter = 1;
        if (c->init) c->init(c->ctx);
    }
    return c->ctx;
}

bool SteamAPI_ISteamUser_BLoggedOn(void *self) { (void)self; return false; }
uint64_t SteamAPI_ISteamUser_GetSteamID(void *self) { (void)self; return 76561197960265728ULL; }
uint32_t SteamAPI_ISteamUser_GetAuthSessionTicket(void *self, void *ticket, int max, uint32_t *len, ...)
{ (void)self; (void)ticket; (void)max; if (len) *len = 0; return 0; }
void SteamAPI_ISteamUser_CancelAuthTicket(void *self, uint32_t h) { (void)self; (void)h; }
bool SteamAPI_ISteamUserStats_RequestCurrentStats(void *self) { (void)self; return true; }
bool SteamAPI_ISteamUserStats_SetAchievement(void *self, const char *name) { (void)self; (void)name; return true; }
bool SteamAPI_ISteamUserStats_StoreStats(void *self) { (void)self; return true; }
uint32_t SteamAPI_ISteamUtils_GetAppID(void *self) { (void)self; return 590590; }
