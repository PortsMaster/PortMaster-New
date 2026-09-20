#include "steamext.h"
#include <stdlib.h>
#include <iostream>
#include "fileio.h"
#include "path.h"
#include "platform.h"
#include "manager.h"

#ifdef CHOWDREN_IS_DESKTOP
#include <SDL.h>
#endif

// SteamGlobal

#ifdef CHOWDREN_ENABLE_STEAM
#include "steam/steam_api.h"
#include "steam/steamtypes.h"

class SteamGlobal
{
public:
    bool initialized;
    bool has_data;
    Frame::EventFunction download_success;
    Frame::EventFunction download_fail;

    SteamGlobal();
    static void on_close();
    bool is_ready();
    void init();

    STEAM_CALLBACK(SteamGlobal, receive_callback, UserStatsReceived_t,
                   receive_callback_data);

    void download_callback(RemoteStorageDownloadUGCResult_t * res);
};

static SteamGlobal global_steam_obj;

#ifdef CHOWDREN_IS_FP
#include "objects/steamfp/frontend.cpp"
#endif

SteamGlobal::SteamGlobal()
: initialized(false), has_data(false),
  receive_callback_data(this, &SteamGlobal::receive_callback)
{
}

void SteamGlobal::init()
{
    initialized = SteamAPI_Init();
    if (!initialized) {
        std::cout << "Could not initialize Steam API" << std::endl;
        return;
    }
	if (!SteamUserStats()->RequestCurrentStats())
		std::cout << "Could not request Steam stats" << std::endl;

#ifdef CHOWDREN_STEAM_APPID
    ISteamApps * ownapp = SteamApps();
    if (!ownapp->BIsSubscribedApp(CHOWDREN_STEAM_APPID)) {
        SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Steam error",
                                 "Please purchase the Steam version of the "
                                 "game if you want to play it on Steam.",
                                 NULL);
        exit(0);
    }
#endif

#ifdef CHOWDREN_IS_FP
    initialize_fp();
#endif
}

void SteamGlobal::on_close()
{
    SteamAPI_Shutdown();
}

bool SteamGlobal::is_ready()
{
    return has_data;
}

void SteamGlobal::receive_callback(UserStatsReceived_t * callback)
{
    if (SteamUtils()->GetAppID() != callback->m_nGameID)
        return;
    has_data = true;
}

void SteamGlobal::download_callback(RemoteStorageDownloadUGCResult_t * res)
{
    if (res->m_eResult == k_EResultOK) {
        if (download_success == NULL)
            return;
        (manager.frame->*download_success)();
    } else {
        if (download_fail == NULL)
            return;
        (manager.frame->*download_fail)();
    }
}

#endif

// SteamObject

SteamObject::SteamObject(int x, int y, int type_id)
: FrameObject(x, y, type_id)
{
#ifdef CHOWDREN_ENABLE_STEAM
    static bool initialized = false;
    if (initialized)
        return;
    initialized = true;
    global_steam_obj.init();
#endif
}

bool SteamObject::is_ready()
{
#ifdef CHOWDREN_ENABLE_STEAM
    return global_steam_obj.is_ready();
#else
    return true;
#endif
}

void SteamObject::update()
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return;
    SteamAPI_RunCallbacks();
#endif
}

int SteamObject::get_int(const std::string & name)
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return 0;
    int32 ret;
    if (!SteamUserStats()->GetStat(name.c_str(), &ret))
        return 0;
    return ret;
#else
    return 0;
#endif
}

void SteamObject::set_int(const std::string & name, int value)
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return;
    int32 v = value;
    SteamUserStats()->SetStat(name.c_str(), v);
#endif
}

void SteamObject::unlock_achievement(const std::string & name)
{
#ifndef NDEBUG
    std::cout << "Unlock achievement: " << name << std::endl;
#endif

#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return;
    SteamUserStats()->SetAchievement(name.c_str());
    SteamUserStats()->StoreStats();
#endif

#ifndef CHOWDREN_IS_DESKTOP
    platform_unlock_achievement(name);
#endif
}

void SteamObject::request_user_data()
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return;
    SteamUserStats()->RequestCurrentStats();
#endif
}

void SteamObject::store_user_data()
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return;
    SteamUserStats()->StoreStats();
#endif
}

#ifdef CHOWDREN_ENABLE_STEAM

struct SubCallback
{
    struct Call
    {
        CCallResult<SubCallback, SteamUGCRequestUGCDetailsResult_t> call;
    };

    UGCQueryHandle_t handle;
    Frame::EventFunction loop_callback, finish_callback;
    int received;
    vector<PublishedFileId_t> ids;
    vector<Call> calls;
    vector<SteamUGCDetails_t> details;

    void start(Frame::EventFunction loop, Frame::EventFunction finish)
    {
        loop_callback = loop;
        finish_callback = finish;
        // handle = SteamUGC()->CreateQueryUserUGCRequest(
        //     SteamUser()->GetSteamID().GetAccountID(), k_EUserUGCList_Published,
        //     k_EUGCMatchingUGCType_Items,
        //     k_EUserUGCListSortOrder_CreationOrderDesc,
        //     0, CHOWDREN_STEAM_APPID, 1);
        // SteamAPICall_t call_handle = SteamUGC()->SendQueryUGCRequest(handle);
        int count = std::min<int>(50, SteamUGC()->GetNumSubscribedItems());
        if (count <= 0) {
            (manager.frame->*finish_callback)();
            return;
        }

        received = 0;
        ids.resize(count);
        calls.resize(count);
        details.resize(count);
        SteamUGC()->GetSubscribedItems(&ids[0], count);

        SteamAPICall_t call_handle;
        for (int i = 0; i < count; ++i) {
            std::cout << "Requesting for " << ids[i] << std::endl;
            call_handle = SteamUGC()->RequestUGCDetails(ids[i], 0);
            calls[i].call.Set(call_handle, this, &SubCallback::on_callback);
        }
    }

	void on_callback(SteamUGCRequestUGCDetailsResult_t * result, bool fail)
	{
        std::cout << "Callback received!" << std::endl;
		if (fail) {
			std::cout << "Failed callback" << std::endl;
			return;
		}
		SteamUGCDetails_t & d = result->m_details;
		int index;
		for (index = 0; index < int(ids.size()); ++index) {
			if (ids[index] == d.m_nPublishedFileId)
				break;
		}

		details[index] = d;
		received++;
		if (received < int(ids.size()))
			return;

		finish();
	}

	void finish()
	{
        SteamObject::SubResult & r = SteamObject::sub_result;
        for (int i = 0; i < int(ids.size()); ++i) {
			SteamUGCDetails_t & d = details[i];
            r.index = i;
            r.cloud_path = d.m_pchFileName;
            r.publish_id = i;
            (manager.frame->*loop_callback)();
        }

        (manager.frame->*finish_callback)();
    }
};

static SubCallback ugc_callback;
#endif

bool SteamObject::get_subs(Frame::EventFunction loop,
                           Frame::EventFunction finish)
{
#ifdef CHOWDREN_ENABLE_STEAM
    ugc_callback.start(loop, finish);
    return true;
#else
    return false;
#endif
}

void SteamObject::clear_achievement(const std::string & name)
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return;
    SteamUserStats()->ClearAchievement(name.c_str());
    SteamUserStats()->StoreStats();
#endif
}

void SteamObject::clear_achievements()
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return;
    SteamUserStats()->ResetAllStats(true);
    SteamUserStats()->StoreStats();
#endif
}

bool SteamObject::is_achievement_unlocked(const std::string & name)
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return false;
    bool achieved;
    SteamUserStats()->GetAchievement(name.c_str(), &achieved);
    return achieved;
#else
    return false;
#endif
}

int SteamObject::get_unlocked(const std::string & name)
{
    return (int)is_achievement_unlocked(name);
}

void SteamObject::upload(const std::string & name)
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return;
    std::string filename = get_path_filename(name);
    const char * filename_c = filename.c_str();
    char * data;
    size_t size;
    if (!read_file(filename_c, &data, &size))
        return;
    SteamRemoteStorage()->FileWrite(filename_c, data, size);
#endif
}

void SteamObject::download(const std::string & name)
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return;
    std::string filename = get_path_filename(name);
    const char * filename_c = filename.c_str();
    if (!SteamRemoteStorage()->FileExists(filename_c))
        return;

    int32 size = SteamRemoteStorage()->GetFileSize(filename_c);
    std::string value;
    value.resize(size);
    SteamRemoteStorage()->FileRead(filename_c, &value[0], size);
    FSFile fp(name.c_str(), "w");
    if (!fp.is_open())
        return;
    fp.write(&value[0], value.size());
    fp.close();
#endif
}

bool SteamObject::has_app(int app)
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return false;
    return SteamApps()->BIsSubscribedApp(app);
#else
    return false;
#endif
}

#ifdef CHOWDREN_ENABLE_STEAM
struct DownloadCall
{
    CCallResult<DownloadCall, RemoteStorageDownloadUGCResult_t> call;

	void on_callback(RemoteStorageDownloadUGCResult_t * result, bool fail)
    {
        global_steam_obj.download_callback(result);
        delete this;
    }
};

#endif

void SteamObject::download(const std::string & name, int priority,
                           int content_id,
                           Frame::EventFunction success,
                           Frame::EventFunction fail)
{
#ifdef CHOWDREN_ENABLE_STEAM
    global_steam_obj.download_success = success;
    global_steam_obj.download_fail = fail;
    std::string filename = convert_path(name);
    SteamAPICall_t handle;
    UGCHandle_t id = ugc_callback.details[content_id].m_hFile;
    handle = SteamRemoteStorage()->UGCDownloadToLocation(id, filename.c_str(),
                                                         priority);
    DownloadCall * call = new DownloadCall();
	call->call.Set(handle, call, &DownloadCall::on_callback);
    std::cout << "Download: " << id << " " << name << " " << priority
        << std::endl;
#endif
}

const std::string & SteamObject::get_user_name()
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return empty_string;
    static std::string name;
    name = SteamFriends()->GetPersonaName();
    return name;
#else
    return empty_string;
#endif
}

int SteamObject::get_user_id()
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return 0;
    return SteamUser()->GetSteamID().GetAccountID();
#else
    return 0;
#endif
}

bool SteamObject::is_activated()
{
#ifdef CHOWDREN_ENABLE_STEAM
    if (!global_steam_obj.initialized)
        return true;
    SteamUserStats()->RequestCurrentStats();
    ISteamApps * ownapp = SteamApps();
    return ownapp->BIsSubscribedApp(CHOWDREN_STEAM_APPID);
#else
	return true;
#endif
}

#if !defined(CHOWDREN_ENABLE_STEAM) && defined(CHOWDREN_IS_FP)
void SteamObject::find_board(int char_id, int stage_id)
{
}

void SteamObject::upload_crystal(int value)
{
}

void SteamObject::upload_time(int value)
{
}
#endif

SteamObject::SubResult SteamObject::sub_result;
