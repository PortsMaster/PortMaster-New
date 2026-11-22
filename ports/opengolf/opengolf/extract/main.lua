-- Extracts archives and runs long commands with a message on screen. Shared copy:
-- recipes/templates/includes/extract/
-- Runs as the port's user, so nothing is left on screen afterwards (pm_message's window
-- can't be closed on sudo CFWs such as ArkOS/dArkOS), and redraws only when needed so it
-- leaves the CPU to the work it is waiting for.
--
-- usage: love extract [--text MESSAGE] [--dir DIR] [--run CMD] ARCHIVE...
--   ARCHIVE: .tar.gz/.tgz, .tar.xz, .tar or .zip, extracted into DIR (default: current dir).
--   --run CMD: shell command run in the current dir (e.g. a rom converter). Archives and
--   commands can be mixed and run in the order given.
--   Exits 0 when all steps succeed. On an error it shows the message until a button is
--   pressed and exits 1.
-- tar uses -o (don't restore owners: FAT/exFAT SD cards have none; busybox and GNU).

local text = "Extracting game data, this can take a few minutes..."
local thread, failed, font
local steps = {}

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
    local dir, archives = ".", false
    local i = 1
    while args[i] do
        if args[i] == "--text" then text, i = args[i + 1], i + 2
        elseif args[i] == "--dir" then dir, i = args[i + 1], i + 2
        elseif args[i] == "--run" then
            local cmd = args[i + 1] or ""
            local name = (cmd:match("^%S+") or "command"):match("[^/]*$")
            steps[#steps + 1] = { cmd = cmd, err = name .. " failed. Check log.txt and launch again." }
            i = i + 2
        else
            local archive = args[i]
            local f = io.open(archive)
            if not f then return fail(archive:match("[^/]*$") .. " not found. Reinstall the port.") end
            f:close()
            local cmd = command(archive, dir)
            if not cmd then return fail("Unknown archive type: " .. archive) end
            steps[#steps + 1] = { cmd = cmd, err = "Extraction failed. Check free space and launch again." }
            archives = true
            i = i + 1
        end
    end
    if #steps == 0 then return fail("Nothing to do.") end
    if archives then os.execute("mkdir -p " .. q(dir)) end
    local cmds = {}
    for n, step in ipairs(steps) do cmds[n] = step.cmd end
    thread = love.thread.newThread([[
        for n, cmd in ipairs({ ... }) do
            print(cmd)
            local rc = os.execute(cmd)
            if rc ~= 0 and rc ~= true then
                love.thread.getChannel("rc"):push(n)
                return
            end
        end
        love.thread.getChannel("rc"):push(0)
    ]])
    thread:start(unpack(cmds))
end

function love.update()
    if failed then return end
    local n = love.thread.getChannel("rc"):pop()
    if n == 0 then love.event.quit(0)
    elseif n then fail(steps[n].err)
    elseif thread:getError() then
        print(thread:getError())
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

-- Instead of drawing every vsync: handle events 10 times a second, draw when the text
-- changed and otherwise once a second (keeps the screen right after focus/mode changes)
function love.run()
    love.load(love.arg.parseGameArguments(arg), arg)
    local drawn, last = nil, 0
    return function()
        love.event.pump()
        for name, a, b, c, d, e, f in love.event.poll() do
            if name == "quit" then return a or 0 end
            love.handlers[name](a, b, c, d, e, f)
        end
        love.update()
        local now = love.timer.getTime()
        if love.graphics.isActive() and (text ~= drawn or now - last >= 1) then
            love.graphics.origin()
            love.draw()
            love.graphics.present()
            drawn, last = text, now
        end
        love.timer.sleep(0.1)
    end
end
