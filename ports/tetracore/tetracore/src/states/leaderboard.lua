local asyncHttp = require("src.utils.asyncHttp")

local Leaderboard = {}

local UPSTASH_HOST = "https://better-starfish-176171.upstash.io"
local UPSTASH_TOKEN = "gQAAAAAAArArAAIgcDEwMzI3NDk2MWYyZDY0MmI1YjUyMjBiNTBmYzM4MGZlZA"

function Leaderboard.fetch(callback)
    local url = string.format("%s/zrevrange/leaderboard/0/9/WITHSCORES?_token=%s", UPSTASH_HOST, UPSTASH_TOKEN)

    asyncHttp.get(url, function(data)
        if data and data ~= "" and not data:find("error") then
            callback(data)
        else
            print("Fetch failed or error response:", data)
            callback(nil)
        end
    end)
end

function Leaderboard.submit(name, score, callback)
    local url = string.format("%s/zadd/leaderboard/%d/%s?_token=%s", UPSTASH_HOST, score, name, UPSTASH_TOKEN)

    asyncHttp.get(url, function(data)
        if data and data ~= "" and not data:find("error") then
            if callback then callback(true) end
        else
            print("Submit failed:", data)
            if callback then callback(false) end
        end
    end)
end

return Leaderboard
