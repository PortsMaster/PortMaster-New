#include "leaderboards.h"
CSteamLeaderboards boards;

#include "leaderboards.cpp"


static char * characters[6] =
{
    "Lilac",
    "Spade",
    "Carol",
    "Carol",
    "Milla",
    "Torque",
};

static char * stages[18] =
{
    "Aqua Tunnel",
    "Dragon Valley",
    "Relic Maze",
    "Fortune Night",
    "Sky Battalion",
    "Jade Creek",
    "Thermal Base",
    "Battle Glacier",
    "Final Dreadnought 1",
    "Trap Hideout",
    "Pangu Lagoon",
    "Final Dreadnought 2",
    "Final Dreadnought 3",
    "Final Dreadnought 4",
    "Horizon Starport",
    "Rage Ravine",
    "Shuigang Palace",
    "???",
};

static char PERSONALMESSAGE[] =
    "I know some pirates or so forth might be reading this. If you like this "
    "game, please buy it. While I personally don't hate pirates, small "
    "companies like ours need all the business we can get. We put a lot of "
    "heart and soul into our work, and our biggest hope is that our fans "
    "enjoy these games. Please remember that.";

static void initialize_fp()
{
    // maybe we can use this in the future
}

void SteamObject::find_board(int char_id, int stage_id)
{
    if (!global_steam_obj.initialized)
        return;
    char leaderboardname[2048];
    char character[512];
    char stage[512];
    if (char_id < 0)
        char_id = 0;
    if (stage_id < -1)
        stage_id = 0;
    if (char_id > 5)
        char_id = 0;
    if (stage_id > 13)
        stage_id = 0;
    strcpy(character, characters[char_id]);
    if (stage_id == -1)
        sprintf(stage, "Adventure Mode");
    else
        strcpy(stage, stages[stage_id]);
    sprintf(leaderboardname,"%s - %s - Crystals", stage, character);
    boards.FindLeaderboard(leaderboardname);
    sprintf(leaderboardname,"%s - %s - Time", stage, character);
    boards.FindTimeLeaderboard(leaderboardname);
}

void SteamObject::upload_crystal(int value)
{
    if (!global_steam_obj.initialized)
        return;
    int details[1];
    details[0] = 0;
    boards.UploadScore(value, details);
}

void SteamObject::upload_time(int value)
{
    if (!global_steam_obj.initialized)
        return;
    int details[1];
    details[0] = 0;
    boards.UploadTimeScore(value, details);
}
