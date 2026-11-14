-- Extracts archives with a message on screen. Shared copy: recipes/templates/includes/extract/
-- Runs as the port's user, so nothing is left on screen afterwards (pm_message's window
-- can't be closed on sudo CFWs such as ArkOS/dArkOS).
--
-- usage: love extract [--text MESSAGE] [--dir DIR] ARCHIVE...
--   .tar.gz/.tgz, .tar.xz, .tar or .zip, extracted in order into DIR (default: current dir).
--   Exits 0 when all are extracted. On an error it shows the message until a button is
--   pressed and exits 1.
-- tar uses -o (don't restore owners: FAT/exFAT SD cards have none; busybox and GNU).

local text = "Extracting game data, this can take a few minutes..."
local thread, failed, font

local function fail(msg)
    print("Error: " .. msg)
    failed = true
    text = "Error: " .. msg .. "\n\nPress any button."
end

local function q(s) return "'" .. s:gsub("'", "'\\''") .. "'" end

local function command(archive, dir)
    local a, d = q(archive), q(dir)
    if archive:match("%.tar%.gz$") or archive:match("%.tgz$") then
        return "gunzip -c " .. a .. " | tar -xof - -C " .. d
    elseif archive:match("%.tar%.xz$") then
        return "xz -dc " .. a .. " | tar -xof - -C " .. d
    elseif archive:match("%.tar$") then
        return "tar -xof " .. a .. " -C " .. d
    elseif archive:match("%.zip$") then
        return "unzip -oq " .. a .. " -d " .. d
    end
end

function love.load(args)
    local dir, cmds = ".", {}
    local i = 1
    while args[i] do
        if args[i] == "--text" then text, i = args[i + 1], i + 2
        elseif args[i] == "--dir" then dir, i = args[i + 1], i + 2
        else
            local archive = args[i]
            local f = io.open(archive)
            if not f then return fail(archive:match("[^/]*$") .. " not found. Reinstall the port.") end
            f:close()
            local cmd = command(archive, dir)
            if not cmd then return fail("Unknown archive type: " .. archive) end
            cmds[#cmds + 1] = cmd
            i = i + 1
        end
    end
    if #cmds == 0 then return fail("No archive given.") end
    font = love.graphics.newFont(math.max(12, math.floor(love.graphics.getHeight() / 24)))
    os.execute("mkdir -p " .. q(dir))
    thread = love.thread.newThread([[
        for _, cmd in ipairs({ ... }) do
            print(cmd)
            local rc = os.execute(cmd)
            if rc ~= 0 and rc ~= true then
                love.thread.getChannel("rc"):push(false)
                return
            end
        end
        love.thread.getChannel("rc"):push(true)
    ]])
    thread:start(unpack(cmds))
end

function love.update()
    if failed then return end
    local ok = love.thread.getChannel("rc"):pop()
    if ok == true then love.event.quit(0)
    elseif ok == false or thread:getError() then
        if thread:getError() then print(thread:getError()) end
        fail("Extraction failed. Check free space and launch again.")
    end
end

local function close() if failed then love.event.quit(1) end end
love.gamepadpressed = close
love.keypressed = close

function love.draw()
    local w, h = love.graphics.getDimensions()
    font = font or love.graphics.newFont(math.max(12, math.floor(h / 24)))
    love.graphics.clear(0.06, 0.08, 0.14)
    love.graphics.setFont(font)
    local _, lines = font:getWrap(text, w * 0.8)
    love.graphics.printf(text, w * 0.1, (h - #lines * font:getHeight()) / 2, w * 0.8, "center")
end
