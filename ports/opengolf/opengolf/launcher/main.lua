-- Generic PortMaster settings launcher. Shared copy: recipes/templates/includes/launcher/
-- Each port supplies launcher/config.lua:
--   config.title, config.subtitle, config.help   text shown on the screen
--   config.notice (optional) warning drawn in a large bold font below the items
--   config.items  { { id, label, kind = "text", maxlen, allowed } or
--                   { id, label, kind = "number", min, max, maxlen } or (whole numbers, keypad)
--                   { id, label, kind = "choice", choices = { { value, label }, ... } } }
--                 any item: help = "...", visible = function(values) -> bool (e.g. sub-options
--                 shown only while a choice has a certain value)
--   config.load(path) -> table of values keyed by item id
--   config.save(path, values) -> ok, err
--
-- usage: love launcher <game_config> <launch_file>
--   game_config  the game's config file (edited on Play / Save)
--   launch_file  shell file written on exit (LAUNCHER_PLAY=0/1), sourced by the port script

local config = require("config")
local osk = require("osk")

local VW, VH = 640, 480

local colors = {
    bg     = { 0.06, 0.08, 0.14 },
    panel  = { 0.10, 0.14, 0.24, 0.97 },
    field  = { 0.03, 0.05, 0.10 },
    key    = { 0.17, 0.24, 0.38 },
    row    = { 0.13, 0.19, 0.32 },
    accent = { 1.00, 0.78, 0.30 },
    text   = { 0.95, 0.97, 1.00 },
    dim    = { 0.62, 0.68, 0.80 },
    warn   = { 1.00, 0.45, 0.40 },
}

local fonts = {}
local paths = {}
local values
local sel = 1
local keyboard = nil
local toast, toastTime = nil, 0
local transform = { scale = 1, ox = 0, oy = 0 }
-- seconds until the game starts by itself (LAUNCHER_AUTOSTART in conf.lua); nil once cancelled
local autostart = (tonumber(LAUNCHER_AUTOSTART) or 0) > 0 and tonumber(LAUNCHER_AUTOSTART) or nil

local allItems = { { id = "_play", label = "Play " .. config.title } }
for _, it in ipairs(config.items) do allItems[#allItems + 1] = it end
-- launcher/controls.png comes from Controls4PM at build time ("controls" in recipe.json)
if love.filesystem.getInfo("controls.png") then
    allItems[#allItems + 1] = { id = "_controls", label = "Controls", help = "Show the button layout" }
end
allItems[#allItems + 1] = { id = "_quit", label = "Save and quit" }
local items = allItems

-- Rebuild the list of shown items after a value changed, keeping the selected item
local function refreshItems()
    local current = items[sel]
    items = {}
    for _, it in ipairs(allItems) do
        if not it.visible or it.visible(values) then items[#items + 1] = it end
    end
    sel = math.min(sel, #items)
    for i, it in ipairs(items) do if it == current then sel = i end end
end
local controlsImage, showControls = nil, false

local function choiceIndex(it)
    for i, c in ipairs(it.choices) do
        if c[1] == values[it.id] then return i end
    end
    return 1
end

local function valueLabel(it)
    if it.kind == "choice" then return it.choices[choiceIndex(it)][2] end
    return tostring(values[it.id] or "")
end

local function finish(launch)
    local ok, err = config.save(paths.config, values)
    if not ok then print("launcher: " .. tostring(err)) end
    local f = io.open(paths.launch, "w")
    if f then
        f:write("# Written by the " .. config.title .. " launcher\nLAUNCHER_PLAY=" .. (launch and 1 or 0) .. "\n")
        f:close()
    end
    love.event.quit(0)
end

local function editText(it)
    keyboard = osk.new({ title = it.label, value = values[it.id], kind = "nick", maxlen = it.maxlen or 20,
                         allowed = it.allowed or "[%w_%-]" }, function(ok, value)
        keyboard = nil
        if not ok then return end
        if value == "" then
            toast, toastTime = it.label .. " cannot be empty", 2.5
        else
            values[it.id] = value
        end
    end)
end

local function editNumber(it)
    keyboard = osk.new({ title = it.label, value = values[it.id], kind = "number", maxlen = it.maxlen or 5 },
                       function(ok, value)
        keyboard = nil
        local n = ok and tonumber(value)
        if not ok then return end
        if not n or (it.min and n < it.min) or (it.max and n > it.max) then
            toast, toastTime = it.label .. ": enter " .. (it.min or 0) .. " to " .. (it.max or "any"), 2.5
        else
            values[it.id] = n
        end
    end)
end

local function cycle(it, dir)
    local n = #it.choices
    values[it.id] = it.choices[(choiceIndex(it) - 1 + dir) % n + 1][1]
end

local function handleAction(action)
    autostart = nil
    if showControls then showControls = false return end
    if keyboard then keyboard:action(action) return end
    local it = items[sel]
    if action == "up" then sel = (sel - 2) % #items + 1
    elseif action == "down" then sel = sel % #items + 1
    elseif action == "start" then finish(true)
    elseif action == "back" then finish(false)
    elseif it.kind == "choice" and (action == "left" or action == "right" or action == "a") then
        cycle(it, action == "left" and -1 or 1)
        refreshItems()
    elseif action == "a" then
        if it.id == "_play" then finish(true)
        elseif it.id == "_quit" then finish(false)
        elseif it.id == "_controls" then
            -- string path, not ImageData: newImage(ImageData) crashes the Mali driver
            controlsImage = controlsImage or love.graphics.newImage("controls.png")
            showControls = true
        elseif it.kind == "text" then editText(it)
        elseif it.kind == "number" then editNumber(it) end
    end
end

---------------------------------------------------------------------------
-- Input (gamepad with held-direction repeat, plus keyboard)
---------------------------------------------------------------------------
local held = { action = nil, t = 0 }
local REPEAT_DELAY, REPEAT_RATE = 0.35, 0.08
local DIRS = { up = true, down = true, left = true, right = true }

local function press(action)
    handleAction(action)
    if DIRS[action] then held.action, held.t = action, REPEAT_DELAY end
end

local function release(action)
    if held.action == action then held.action = nil end
end

local PAD_MAP = {
    dpup = "up", dpdown = "down", dpleft = "left", dpright = "right",
    a = "a", b = "b", x = "x", y = "y", start = "start", back = "back",
}

function love.gamepadpressed(_, button)
    if PAD_MAP[button] then press(PAD_MAP[button]) end
end

function love.gamepadreleased(_, button)
    if PAD_MAP[button] then release(PAD_MAP[button]) end
end

local axisState = {}
function love.gamepadaxis(js, axis, value)
    if axis ~= "leftx" and axis ~= "lefty" then return end
    local st = axisState[js:getID()] or {}
    axisState[js:getID()] = st
    local neg = (axis == "leftx") and "left" or "up"
    local pos = (axis == "leftx") and "right" or "down"
    local want = (value < -0.5) and neg or ((value > 0.5) and pos or nil)
    if st[axis] ~= want then
        if st[axis] then release(st[axis]) end
        if want then press(want) end
        st[axis] = want
    end
end

local KEY_MAP = {
    up = "up", down = "down", left = "left", right = "right",
    ["return"] = "a", kpenter = "a", space = "a", escape = "back",
}
local OSK_KEY_MAP = {
    up = "up", down = "down", left = "left", right = "right",
    ["return"] = "start", kpenter = "start", backspace = "b", escape = "back",
}

function love.keypressed(key)
    local a = (keyboard and OSK_KEY_MAP or KEY_MAP)[key]
    if a then handleAction(a) end
end

function love.textinput(t)
    if keyboard then keyboard:textinput(t) end
end

---------------------------------------------------------------------------
-- Love callbacks
---------------------------------------------------------------------------
local function updateTransform()
    local w, h = love.graphics.getDimensions()
    local s = math.min(w / VW, h / VH)
    transform.scale = s
    transform.ox = math.floor((w - VW * s) / 2)
    transform.oy = math.floor((h - VH * s) / 2)
end

function love.load(args)
    paths.config = args[1]
    paths.launch = args[2] or "launch.cfg"
    love.keyboard.setKeyRepeat(true)
    updateTransform()
    -- fonts are created at the final pixel size so they stay sharp when scaled
    local function f(px) return love.graphics.newFont(math.max(8, math.floor(px * transform.scale + 0.5))) end
    fonts.small, fonts.normal, fonts.big, fonts.title, fonts.logo = f(13), f(17), f(22), f(22), f(40)
    values = config.load(paths.config)
    refreshItems()
end

function love.resize()
    updateTransform()
end

function love.update(dt)
    if autostart then
        autostart = autostart - dt
        if autostart <= 0 then finish(true) return end
    end
    if held.action then
        held.t = held.t - dt
        if held.t <= 0 then handleAction(held.action); held.t = REPEAT_RATE end
    end
    if toast then
        toastTime = toastTime - dt
        if toastTime <= 0 then toast = nil end
    end
end

-- Text is drawn unscaled at screen resolution for sharpness; everything
-- else is laid out in a 640x480 virtual space.
local function vprint(text, font, x, y, w, align)
    local s = transform.scale
    love.graphics.push()
    love.graphics.origin()
    love.graphics.translate(transform.ox, transform.oy)
    love.graphics.setFont(font)
    love.graphics.printf(text, math.floor(x * s), math.floor(y * s), math.floor(w * s), align or "left")
    love.graphics.pop()
end

local function drawMain()
    love.graphics.setColor(colors.text)
    vprint(config.title, fonts.logo, 0, 40, VW, "center")
    love.graphics.setColor(colors.dim)
    vprint(config.subtitle or "", fonts.small, 0, 90, VW, "center")

    -- rows shrink from 32px when there are many items, so they stay clear of the help text
    local rows = 0
    for _, it in ipairs(items) do if it.id ~= "_play" then rows = rows + 1 end end
    local space = VH - 88 - 130 - 48 - (config.notice and 36 or 0)
    local step = math.max(20, math.min(32, math.floor(space / math.max(rows, 1))))
    local y = 130
    for i, it in ipairs(items) do
        local s = (i == sel)
        if it.id == "_play" then
            love.graphics.setColor(s and colors.accent or colors.row)
            love.graphics.rectangle("fill", 160, y - 4, VW - 320, 34, 17, 17)
            love.graphics.setColor(s and colors.bg or colors.text)
            vprint(it.label, fonts.big, 160, y + 1, VW - 320, "center")
            y = y + 48
        else
            if s then
                love.graphics.setColor(colors.accent[1], colors.accent[2], colors.accent[3], 0.18)
                love.graphics.rectangle("fill", 40, y - 3, VW - 80, step - 4, 8, 8)
                love.graphics.setColor(colors.accent)
                love.graphics.rectangle("line", 40, y - 3, VW - 80, step - 4, 8, 8)
            end
            love.graphics.setColor(s and colors.accent or colors.text)
            local ty = y + 2 - (32 - step) / 2
            vprint(it.label, fonts.normal, 56, ty, 300, "left")
            local v = it.kind and valueLabel(it)
            if v then
                if it.kind == "choice" and s then v = "<  " .. v .. "  >" end
                love.graphics.setColor(s and colors.text or colors.dim)
                vprint(v, fonts.normal, 300, ty, VW - 356, "right")
            end
            y = y + step
        end
    end

    if config.notice then
        -- bold: printed twice, one screen pixel apart
        love.graphics.setColor(colors.warn)
        for dx = 0, 1 do
            vprint(config.notice, fonts.big, 40 + dx / transform.scale, y + 4, VW - 80, "center")
        end
    end

    local it = items[sel]
    love.graphics.setColor(colors.dim)
    vprint(it.help or config.help or "", fonts.small, 40, VH - 80, VW - 80, "center")

    local hint = "A select   Up/Down move   Start play   Select exit"
    if it.kind == "choice" then hint = "Left/Right change   Up/Down move   Start play   Select exit" end
    if autostart then hint = ("Starting in %d...   press any button for settings"):format(math.ceil(autostart)) end
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.rectangle("fill", 0, VH - 30, VW, 30)
    love.graphics.setColor(colors.dim)
    vprint(hint, fonts.small, 0, VH - 23, VW, "center")
end

function love.draw()
    love.graphics.clear(colors.bg)
    love.graphics.push()
    love.graphics.translate(transform.ox, transform.oy)
    love.graphics.scale(transform.scale)
    love.graphics.setScissor(transform.ox, transform.oy, VW * transform.scale, VH * transform.scale)

    if showControls then
        local iw, ih = controlsImage:getDimensions()
        local s = math.min(VW / iw, (VH - 30) / ih)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(controlsImage, (VW - iw * s) / 2, (VH - 30 - ih * s) / 2, 0, s, s)
        love.graphics.setColor(colors.dim)
        vprint("Press any button to return", fonts.small, 0, VH - 23, VW, "center")
    else
        drawMain()
    end

    if keyboard then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, 0, VW, VH)
        keyboard:draw(fonts, colors, vprint)
    end

    if toast then
        love.graphics.setColor(0, 0, 0, 0.85)
        love.graphics.rectangle("fill", 120, 104, VW - 240, 28, 8, 8)
        love.graphics.setColor(colors.warn)
        vprint(toast, fonts.normal, 120, 108, VW - 240, "center")
    end

    love.graphics.setScissor()
    love.graphics.pop()
end
