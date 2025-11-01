require("./steam")

ACHIEVEMENT_KEYS = {
    END_REACHED    = "end_reached",
    BONK           = "bonk",
    ALL_MEDALS     = "all_medals",
    LOBBY_COMPLETE = "lobby_complete",
}

local unlock_achievements_queue = {}

function set_achievement(key)
    local success = Steam.userStats.setAchievement(key)

    if(not success) then
        print("[STEAM ERROR]: key doesn't exist in steam or stats weren't requested")
        return
    end

    success = Steam.userStats.storeStats()

    if(not success) then
        print("[STEAM ERROR]: Stats not published or stats weren't requested")
    end
end

function unlock_achievement(key)
    if(Steam) then
        if(not SteamState.user_stats_received) then
            table.insert(unlock_achievements_queue, key)
            request_stats()

            return
        end

        set_achievement(key)
    end
end

function unlock_queued_achievements()
    if(not SteamState.user_stats_received) then
        return
    end

    for _, achievement_key in pairs(unlock_achievements_queue) do
        set_achievement(achievement_key)
    end

    unlock_achievements_queue = {}
end

function reset_achievements()
    if(Steam and dev_mode) then
        local success = Steam.userStats.resetAllStats(true)

        if(not success) then
            print("[STEAM ERROR]: Stats not requested")
        end

        request_stats()
    end
end