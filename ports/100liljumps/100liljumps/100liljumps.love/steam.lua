SteamState = {
    user_stats_received = false,
}

-- Override Steam callbacks

function on_user_stats_received(data)
    print("[STEAM]: User stats received: ", data.result)

    if(data.result) then
        SteamState.user_stats_received = true
    end
end

function request_stats()
    if(Steam) then
        -- Set callback
        Steam.userStats.onUserStatsReceived = on_user_stats_received

        local success = Steam.userStats.requestCurrentStats()
        if not success then
            print("[ERROR]: Steam user not logged in")
        end
    end
end