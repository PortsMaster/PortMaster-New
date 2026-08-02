-- Balatro display setup.
--
-- Two questions asked before the game starts: which layout to play with, and
-- whether to take the performance changes. Neither can be a setting inside the
-- game, because both decide how the patched archive is assembled -- by the time
-- the game is running, the build it was started from has already been made. So
-- they are asked here, the launcher builds to the answers, and the game that
-- opens afterwards is the one that was asked for.
--
-- The answers live in one file in the port's saves folder, which is also the
-- record of having asked: the questions come up when it is missing, and the
-- game's options menu offers to ask again by marking it. Nothing else is
-- written, and the game's own saves are untouched.
--
-- Written to be answerable before the button setup has run, which is the first
-- launch's order: the D-pad moves and START approves through whatever mapping
-- SDL has, and a pad SDL cannot map at all is read raw instead (see profiles
-- below), so this screen is never the thing standing between a device and its
-- button setup.

local OUTPUT_PATH = os.getenv('BALATRO_PM_SETUP_FILE')
local FONT_PATH = os.getenv('BALATRO_PM_SETUP_FONT')

-- Nothing here may leave the device sitting on a screen it cannot get off, so
-- an idle run answers with what is already highlighted and gets out of the way.
-- Longer than the button setup's minute: that screen is answered as fast as the
-- questions are read, and this one is read before it is answered.
local IDLE_TIMEOUT = 90
local NO_PAD_TIMEOUT = 12
-- Shown as a countdown rather than left for the player to discover by waiting,
-- and late enough that someone who is only reading is not hurried by it.
local SKIP_WARNING = 20
-- One press must not move two rows. Short enough that held-down navigation
-- still feels like a repeat rate rather than a stall.
local INPUT_COOLDOWN = 0.16
local AXIS_TRAVEL = 0.6
local AXIS_RETURN = 0.35

local BG = {0.09, 0.13, 0.17}
local PANEL = {0.16, 0.22, 0.28}
local ACCENT = {0.99, 0.37, 0.33}
local TEXT = {0.96, 0.96, 0.94}
local DIM = {0.62, 0.68, 0.72}

-- The order they are asked in is the order they take effect in: the layout
-- decides what the game looks like, and the performance answer decides how much
-- of that look is paid for every frame.
local PAGES = {
    {
        key = 'layout',
        title = 'Screen layout',
        default = 'small',
        options = {
            {
                value = 'small',
                label = 'Small screen',
                description = 'Rebuilt for a handheld panel: the playfield fills ' ..
                    'the screen, the sidebar becomes one status bar, and cards ' ..
                    'and text are larger.',
            },
            {
                value = 'original',
                label = 'Original Balatro',
                description = 'The desktop layout as the game ships it, ' ..
                    'letterboxed to fit the panel. Everything is drawn smaller.',
            },
        },
    },
    {
        key = 'performance',
        title = 'Performance improvements',
        default = 'on',
        options = {
            {
                value = 'on',
                label = 'On',
                description = 'CRT, bloom, shadows and screen shake off, the ' ..
                    'table background held still, and the full-screen shaders ' ..
                    'trimmed. Much lighter to draw.',
            },
            {
                value = 'off',
                label = 'Off',
                description = 'Every effect on and the background animating, ' ..
                    'exactly as on a desktop. On a weaker device the frame rate ' ..
                    'will show it.',
            },
        },
    },
}

local page_index = 1
local chosen = {}
local previous = {}
local state = 'ask'
local cooldown, idle, message_timer = 0, 0, 0
local changed = false
local fonts, font_data
local axis_rest, axis_held = {}, {}
local profiles = setmetatable({}, {__mode = 'k'})

--------------------------------------------------------------------------- io

-- Comment lines are skipped by the pattern rather than by looking for a `#`:
-- the only lines that mean anything are `key=value`.
local function read_existing()
    local values = {}
    if not OUTPUT_PATH then return values end
    local file = io.open(OUTPUT_PATH, 'r')
    if not file then return values end
    for line in file:lines() do
        local key, value = line:match('^%s*([%a_][%w_]*)%s*=%s*(%S+)')
        if key then values[key] = value end
    end
    file:close()
    return values
end

local function write_output()
    if not OUTPUT_PATH then return false end
    local file = io.open(OUTPUT_PATH, 'w')
    if not file then return false end
    file:write('# Balatro display setup.\n')
    file:write('# Choose "Display Setup" in the game\'s options menu to be asked\n')
    file:write('# again, or delete this file.\n')
    for _, page in ipairs(PAGES) do
        file:write(page.key .. '=' .. page.options[chosen[page.key]].value .. '\n')
    end
    file:close()
    return true
end

-- Whether anything is about to be rebuilt, which is the one thing worth saying
-- on the way out: a changed answer costs a wait that an unchanged one does not.
local function answers_changed()
    for _, page in ipairs(PAGES) do
        if page.options[chosen[page.key]].value ~= previous[page.key] then
            return true
        end
    end
    return false
end

local function save_and_quit()
    changed = answers_changed()
    write_output()
    state = 'saved'
    message_timer = changed and 2.2 or 1.2
end

-- An unhandled error would otherwise park the device on LÖVE's error screen,
-- which on a handheld cannot be dismissed. Record the answers as they stand and
-- get out of the way so the game still launches.
function love.errorhandler(_)
    pcall(write_output)
    return function() return 0 end
end

------------------------------------------------------------------- appearance

local sized_fonts = {}

local function font_at(size)
    size = math.max(8, math.floor(size))
    local font = sized_fonts[size]
    if not font then
        if font_data then
            local ok, made = pcall(love.graphics.newFont, font_data, size)
            font = ok and made or nil
        end
        font = font or love.graphics.newFont(size)
        sized_fonts[size] = font
    end
    return font
end

-- The panels this runs on are between 1:1 and 2.4:1, so the width a piece of
-- text gets varies by more than twice while the height it may take does not
-- vary at all. A size taken from the height alone therefore fits on some
-- devices and runs over what is under it on others. Ask for the largest size
-- that fits the space instead, and let the text be smaller on the panels where
-- it has to be.
local fitted = {}

local function fitted_font(text, largest, key, fits)
    key = text .. '|' .. key
    local font = fitted[key]
    if font then return font end
    local size = math.floor(largest)
    while size > 8 do
        font = font_at(size)
        if fits(font) then break end
        size = size - 1
    end
    font = font or font_at(8)
    fitted[key] = font
    return font
end

-- A paragraph, wrapped, in no more than the height it is given.
local function fitted_block(text, width, height, largest)
    return fitted_font(text, largest, math.floor(width) .. 'x' .. math.floor(height),
        function(font)
            local _, lines = font:getWrap(text, width)
            return font:getHeight()*#lines <= height
        end)
end

-- A single line, kept to one line.
local function fitted_line(text, width, largest)
    return fitted_font(text, largest, 'line' .. math.floor(width),
        function(font) return font:getWidth(text) <= width end)
end

-- The two sizes nothing has to be fitted into: an option's label sits in a box
-- built around it, and the one paragraph drawn without a height to respect is
-- the last thing on its screen.
local function build_fonts()
    sized_fonts, fitted = {}, {}
    local h = love.graphics.getHeight()
    fonts = {option = font_at(h*0.058), body = font_at(h*0.042)}
end

function love.load()
    -- The port's own font, read straight off disk: this is a bare LÖVE game
    -- folder, so the file is outside its filesystem and cannot be required.
    if FONT_PATH then
        local file = io.open(FONT_PATH, 'rb')
        if file then
            local contents = file:read('*a')
            file:close()
            local ok, data = pcall(love.filesystem.newFileData, contents, 'ui.ttf')
            if ok then font_data = data end
        end
    end
    build_fonts()

    -- Start on what is already in force, so re-running this to look at the
    -- other answer and leaving it alone changes nothing.
    local saved = read_existing()
    for _, page in ipairs(PAGES) do
        chosen[page.key] = 1
        for index, option in ipairs(page.options) do
            if option.value == (saved[page.key] or page.default) then
                chosen[page.key] = index
            end
        end
        previous[page.key] = page.options[chosen[page.key]].value
    end
end

function love.resize()
    build_fonts()
end

----------------------------------------------------------------------- input

-- What SDL can already do with a pad decides which of its events are listened
-- to. A pad SDL has a mapping for reports every press twice -- once raw and
-- once as a gamepad button -- so taking both would move two rows per press;
-- the gamepad events are the ones kept, because they are the ones that mean
-- the same thing on every device. A pad SDL cannot map reports only the raw
-- events, and this screen runs before the button setup that would fix that, so
-- those are read instead: any hat or axis moves, and any button approves --
-- there is no START to insist on when nothing is bound.
local function profile_of(joystick)
    local profile = profiles[joystick]
    if profile then return profile end

    local mapped = joystick.isGamepad and joystick:isGamepad() or false
    local bound = {}
    if mapped and love.joystick.getGamepadMappingString then
        local ok, line = pcall(love.joystick.getGamepadMappingString, joystick:getGUID())
        if ok and line then
            for control in string.gmatch(line, '([^,:]+):') do bound[control] = true end
        end
    end

    profile = {
        gamepad = mapped,
        dpad = mapped and bound.dpup and bound.dpdown or false,
        start = mapped and bound.start or false,
    }
    profiles[joystick] = profile
    return profile
end

local function move(delta)
    local page = PAGES[page_index]
    local index = chosen[page.key] + delta
    -- Clamped rather than wrapped: on an unmapped pad a stick answers as a
    -- D-pad, and a list that jumps from one end to the other under a noisy axis
    -- is how the wrong answer gets approved.
    if index < 1 then index = 1 end
    if index > #page.options then index = #page.options end
    chosen[page.key] = index
    cooldown = INPUT_COOLDOWN
end

local function approve()
    cooldown = INPUT_COOLDOWN
    if page_index < #PAGES then
        page_index = page_index + 1
    else
        save_and_quit()
    end
end

local function go_back()
    if page_index <= 1 then return end
    cooldown = INPUT_COOLDOWN
    page_index = page_index - 1
end

function love.gamepadpressed(joystick, button)
    idle = 0
    if state ~= 'ask' or cooldown > 0 or not profile_of(joystick).gamepad then
        return
    end
    if button == 'dpup' or button == 'dpleft' then
        move(-1)
    elseif button == 'dpdown' or button == 'dpright' then
        move(1)
    elseif button == 'start' then
        approve()
    elseif button == 'back' then
        go_back()
    end
end

function love.joystickpressed(joystick)
    idle = 0
    if state ~= 'ask' or cooldown > 0 or profile_of(joystick).start then return end
    approve()
end

function love.joystickhat(joystick, _, direction)
    idle = 0
    if state ~= 'ask' or cooldown > 0 or profile_of(joystick).dpad then return end
    -- Diagonals are two directions at once and belong to neither.
    if direction == 'u' or direction == 'l' then
        move(-1)
    elseif direction == 'd' or direction == 'r' then
        move(1)
    end
end

function love.keypressed(key)
    idle = 0
    if state ~= 'ask' then return end
    if key == 'up' or key == 'left' then
        move(-1)
    elseif key == 'down' or key == 'right' then
        move(1)
    elseif key == 'return' or key == 'kpenter' or key == 'space' then
        approve()
    elseif key == 'backspace' then
        go_back()
    elseif key == 'escape' then
        save_and_quit()
    end
end

-- An axis is read rather than announced, so a crossing has to be noticed here
-- and then not noticed again until the axis goes back to rest. Rest is whatever
-- each axis reads before anything has been touched, because a trigger sits at
-- one end of its travel rather than in the middle.
local function poll_axes()
    if state ~= 'ask' then return end
    for _, joystick in ipairs(love.joystick.getJoysticks()) do
        if not profile_of(joystick).dpad then
            local rest = axis_rest[joystick]
            if not rest then
                rest = {}
                for i = 1, joystick:getAxisCount() do rest[i] = joystick:getAxis(i) end
                axis_rest[joystick] = rest
                axis_held[joystick] = {}
            end
            local held = axis_held[joystick]
            for i = 1, joystick:getAxisCount() do
                local travel = joystick:getAxis(i) - (rest[i] or 0)
                if held[i] and math.abs(travel) < AXIS_RETURN then
                    held[i] = false
                elseif not held[i] and math.abs(travel) > AXIS_TRAVEL then
                    held[i] = true
                    idle = 0
                    if cooldown <= 0 then move(travel > 0 and 1 or -1) end
                end
            end
        end
    end
end

function love.update(dt)
    cooldown = math.max(0, cooldown - dt)

    if state == 'saved' then
        message_timer = message_timer - dt
        if message_timer <= 0 then love.event.quit() end
        return
    end

    poll_axes()

    idle = idle + dt
    if #love.joystick.getJoysticks() == 0 then
        if idle > NO_PAD_TIMEOUT then save_and_quit() end
        return
    end
    if idle > IDLE_TIMEOUT then save_and_quit() end
end

------------------------------------------------------------------------- draw

local function set_colour(colour, alpha)
    love.graphics.setColor(colour[1], colour[2], colour[3], alpha or 1)
end

-- printf wraps, so the height of what it drew is a line count rather than one
-- line's height. Measured with the same width it is drawn at.
local function wrapped(font, text, y, width, colour)
    local w = love.graphics.getWidth()
    local x = (w - width)/2
    love.graphics.setFont(font)
    set_colour(colour or TEXT)
    love.graphics.printf(text, x, y, width, 'center')
    local _, lines = font:getWrap(text, width)
    return y + font:getHeight()*#lines
end

local function draw_option(option, selected, y, width)
    local font = fonts.option
    local h = font:getHeight()*1.55
    local x = (love.graphics.getWidth() - width)/2
    set_colour(PANEL, selected and 1 or 0.55)
    love.graphics.rectangle('fill', x, y, width, h, h*0.24)
    set_colour(selected and ACCENT or DIM, selected and 1 or 0.35)
    love.graphics.setLineWidth(math.max(2, h*0.05))
    love.graphics.rectangle('line', x, y, width, h, h*0.24)
    love.graphics.setFont(font)
    set_colour(selected and TEXT or DIM)
    love.graphics.printf(option.label, x, y + (h - font:getHeight())/2, width, 'center')
    return y + h
end

-- One pip per question, filled in as they are passed.
local function draw_progress(y)
    local total = #PAGES
    local radius = math.max(3, love.graphics.getHeight()*0.009)
    local gap = radius*3.2
    local x = (love.graphics.getWidth() - gap*(total - 1))/2
    for i = 1, total do
        if i <= page_index then set_colour(ACCENT) else set_colour(DIM, 0.45) end
        love.graphics.circle('fill', x + gap*(i - 1), y, radius)
    end
end

-- Whole seconds until this run answers for itself, or nil while that is far
-- enough off to be worth saying nothing about. Which timeout is counting
-- depends on whether there is a pad, so this reads it back the same way
-- love.update decides it.
local function skip_countdown()
    local timeout = IDLE_TIMEOUT
    if #love.joystick.getJoysticks() == 0 then timeout = NO_PAD_TIMEOUT end
    local left = timeout - idle
    if left > SKIP_WARNING then return nil end
    return math.max(0, math.ceil(left))
end

-- Every fixed row on this screen is one line, and each has only its own height
-- before the next one starts, so wrapping any of them is how it lands on top of
-- what is under it. Shrink rather than wrap.
local function centred_line(text, y, largest, colour)
    local w = love.graphics.getWidth()
    local font = fitted_line(text, w*0.94, largest)
    love.graphics.setFont(font)
    set_colour(colour or TEXT)
    love.graphics.printf(text, w*0.03, y, w*0.94, 'center')
    return y + font:getHeight()
end

-- Any input at all puts idle back to zero, so this stays honest about what it
-- takes to stop it: pressing something is the whole of it.
local function draw_countdown(y)
    local left = skip_countdown()
    if not left then return end
    centred_line(string.format('Keeping these in %ds. Press anything to stay.',
        left), y, love.graphics.getHeight()*0.038, ACCENT)
end

function love.draw()
    local w, h = love.graphics.getDimensions()
    set_colour(BG)
    love.graphics.rectangle('fill', 0, 0, w, h)

    centred_line('BALATRO  ·  DISPLAY SETUP', h*0.05, h*0.045, DIM)

    if state == 'saved' then
        centred_line(changed and 'Saved. Rebuilding Balatro...'
            or 'Saved. Starting Balatro...', h*0.44, h*0.062)
        if changed then
            wrapped(fonts.body, 'The build is made once for these answers and ' ..
                'kept, so the next launch starts straight away.', h*0.56,
                w*0.78, DIM)
        end
        return
    end

    local page = PAGES[page_index]
    local y = centred_line(page.title, h*0.15, h*0.062, TEXT)

    y = y + h*0.045
    local option_w = math.min(w*0.72, h*1.15)
    for index, option in ipairs(page.options) do
        y = draw_option(option, index == chosen[page.key], y, option_w)
        y = y + h*0.022
    end

    -- What is left between the options and the countdown is the description's,
    -- and it is sized to take no more than that.
    local description = page.options[chosen[page.key]].description
    local top = y + h*0.03
    local font = fitted_block(description, w*0.78, h*0.775 - top, h*0.042)
    wrapped(font, description, top, w*0.78, DIM)

    draw_countdown(h*0.80)
    centred_line(page_index > 1
        and 'D-PAD to choose  ·  START to continue  ·  SELECT to go back'
        or 'D-PAD to choose  ·  START to continue', h*0.875, h*0.038, DIM)
    draw_progress(h*0.955)
end
