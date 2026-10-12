local asyncHttp = {}
local pendingCallbacks = {}

local threadCode = [[
    local url, osName = ...
    local result = ""

    if osName == "Windows" then
        local cmd = string.format('powershell -NoProfile -Command "(Invoke-WebRequest -Uri \'%s\' -UseBasicParsing).Content"', url)
        local handle = io.popen(cmd)
        if handle then
            result = handle:read("*a")
            handle:close()
        end
    elseif osName == "Linux" then

        local cmd = string.format('python3 -c "import urllib.request; print(urllib.request.urlopen(\'%s\').read().decode(\'utf-8\'))"', url)
        local handle = io.popen(cmd)
        if handle then
            result = handle:read("*a")
            handle:close()
        end

        if result == "" or result:find("Traceback") then
            local fallbackHandle = io.popen(string.format('curl -s "%s"', url))
            if fallbackHandle then
                result = fallbackHandle:read("*a")
                fallbackHandle:close()
            end
        end
    elseif osName == "Android" then
        local ok, res = pcall(function()
            local luaj = require("luaj")
            local activity = love.window.toAndroid and select(2, love.window.toAndroid()) or luaj.activity

            local URL = luaj.import("java.net.URL")
            local conn = URL(url):openConnection()
            conn:setRequestMethod("GET")

            local BufferedReader = luaj.import("java.io.BufferedReader")
            local InputStreamReader = luaj.import("java.io.InputStreamReader")
            local reader = BufferedReader(InputStreamReader(conn:getInputStream()))

            local sb = ""
            local line = reader:readLine()
            while line ~= nil do
                sb = sb .. line
                line = reader:readLine()
            end
            reader:close()
            return sb
        end)
        if ok and res then
            result = res
        end
    end

    love.thread.getChannel("http_response"):push(result or "")
]]

function asyncHttp.get(url, callback)
    local thread = love.thread.newThread(threadCode)
    table.insert(pendingCallbacks, callback)
    thread:start(url, love.system.getOS())
end

function asyncHttp.update()
    local channel = love.thread.getChannel("http_response")
    local response = channel:pop()

    if response and #pendingCallbacks > 0 then
        local callback = table.remove(pendingCallbacks, 1)
        callback(response)
    end
end

return asyncHttp