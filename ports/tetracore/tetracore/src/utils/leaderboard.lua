local asyncHttp = require("src.utils.asyncHttp")
local json = require("libs.json")

local Leaderboard = {}

local UPSTASH_HOST = "https://better-starfish-176171.upstash.io"
local UPSTASH_TOKEN = "gQAAAAAAArArAAIgcDEwMzI3NDk2MWYyZDY0MmI1YjUyMjBiNTBmYzM4MGZlZA"

local function urlEncode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "%%20")
    end
    return str or ""
end

function Leaderboard.count(callback)
    local url = string.format("%s/zcard/leaderboard?_token=%s", UPSTASH_HOST, UPSTASH_TOKEN)

    asyncHttp.get(url, function(data)
        if data and data ~= "" and not data:find("error") then
            local decoded = json.decode(data)
            local count = decoded and decoded.result or 0
            callback(count)
        else
            callback(0)
        end
    end)
end

function Leaderboard.fetch(callback)
    local url = string.format("%s/zrevrange/leaderboard/0/19/WITHSCORES?_token=%s", UPSTASH_HOST, UPSTASH_TOKEN)

    asyncHttp.get(url, function(data)
        if data and data ~= "" and not data:find("error") then
            callback(data)
        else
            print("Fetch failed or error response:", data)
            callback(nil)
        end
    end)
end

function Leaderboard.submit(name, score, enforceGT, callback)
    local cleanName = urlEncode(name)
    local url = ""

    if enforceGT then
        url = string.format("%s/zadd/leaderboard/%d/%s?GT=true&_token=%s", UPSTASH_HOST, score, cleanName, UPSTASH_TOKEN)
    else
        url = string.format("%s/zadd/leaderboard/%d/%s?_token=%s", UPSTASH_HOST, score, cleanName, UPSTASH_TOKEN)
    end

    asyncHttp.get(url, function(data)
        if data and data ~= "" and not data:find("error") then
            if callback then callback(true) end
        else
            print("Submit failed:", data)
            if callback then callback(false) end
        end
    end)
end

function Leaderboard.getLowestScore(callback)
    Leaderboard.fetch(function(data)
        if not data then
            callback(0)
            return
        end

        local decoded = json.decode(data)
        local rawList = decoded and decoded.result or decoded

        if type(rawList) == "table" and #rawList >= 2 then
            local minScore = tonumber(rawList[#rawList]) or 0
            callback(minScore)
        else
            callback(0)
        end
    end)
end

return Leaderboard
