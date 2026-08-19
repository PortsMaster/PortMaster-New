local OUTPUT_PATH = os.getenv('BALATRO_PM_SETUP_FILE')
local FONT_PATH = os.getenv('BALATRO_PM_SETUP_FONT')

local IDLE_TIMEOUT = 90
local NO_PAD_TIMEOUT = 12
local SKIP_WARNING = 20
local INPUT_COOLDOWN = 0.16
local AXIS_TRAVEL = 0.6
local AXIS_RETURN = 0.35

local BG = {0.09, 0.13, 0.17}
local PANEL = {0.16, 0.22, 0.28}
local ACCENT = {0.99, 0.37, 0.33}
local TEXT = {0.96, 0.96, 0.94}
local DIM = {0.62, 0.68, 0.72}

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
        key = 'font',
        title = 'Game font',
        default = 'nunito',
        options = {
            {
                value = 'nunito',
                label = 'Nunito',
                description = 'The clearer handheld font. Default with the small ' ..
                    'screen layout; also works with the original layout.',
            },
            {
                value = 'original',
                label = 'Original Balatro',
                description = 'Keep m6x11, the pixel font the game ships with. ' ..
                    'Default with the original layout; also works with small screen.',
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
    {
        key = 'fps',
        title = 'Frame rate',
        default = '60',
        options = {
            {
                value = '60',
                label = '60 FPS',
                description = 'Smooth default. Uses a little more power and heat ' ..
                    'on weaker handhelds.',
            },
            {
                value = '40',
                label = '40 FPS',
                description = 'A middle ground: still comfortable to play, with ' ..
                    'less load than 60.',
            },
            {
                value = '30',
                label = '30 FPS',
                description = 'Lightest option for battery and heat. Best on ' ..
                    'weaker devices or when docked to a heavy HDMI output.',
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

function love.errorhandler(_)
    pcall(write_output)
    return function() return 0 end
end

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

local function fitted_block(text, width, height, largest)
    return fitted_font(text, largest, math.floor(width) .. 'x' .. math.floor(height),
        function(font)
            local _, lines = font:getWrap(text, width)
            return font:getHeight()*#lines <= height
        end)
end

local function fitted_line(text, width, largest)
    return fitted_font(text, largest, 'line' .. math.floor(width),
        function(font) return font:getWidth(text) <= width end)
end

local function build_fonts()
    sized_fonts, fitted = {}, {}
    local h = love.graphics.getHeight()
    fonts = {option = font_at(h*0.058), body = font_at(h*0.042)}
end

local function option_index(page, value)
    for index, option in ipairs(page.options) do
        if option.value == value then return index end
    end
    return 1
end

local function default_font_for_layout(layout)
    if layout == 'original' then return 'original' end
    return 'nunito'
end

local function set_font_for_layout(layout)
    local font_page
    for _, page in ipairs(PAGES) do
        if page.key == 'font' then font_page = page break end
    end
    if not font_page then return end
    chosen.font = option_index(font_page, default_font_for_layout(layout))
end

function love.load()
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

    local saved = read_existing()
    local layout_value = saved.layout or 'small'
    local font_fallback = default_font_for_layout(layout_value)
    for _, page in ipairs(PAGES) do
        local fallback = page.default
        if page.key == 'font' then fallback = font_fallback end
        chosen[page.key] = option_index(page, saved[page.key] or fallback)
        previous[page.key] = page.options[chosen[page.key]].value
    end
end

function love.resize()
    build_fonts()
end

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
    if index < 1 then index = 1 end
    if index > #page.options then index = #page.options end
    chosen[page.key] = index
    if page.key == 'layout' then
        set_font_for_layout(page.options[index].value)
    end
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

local function set_colour(colour, alpha)
    love.graphics.setColor(colour[1], colour[2], colour[3], alpha or 1)
end

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

local function skip_countdown()
    local timeout = IDLE_TIMEOUT
    if #love.joystick.getJoysticks() == 0 then timeout = NO_PAD_TIMEOUT end
    local left = timeout - idle
    if left > SKIP_WARNING then return nil end
    return math.max(0, math.ceil(left))
end

local function centred_line(text, y, largest, colour)
    local w = love.graphics.getWidth()
    local font = fitted_line(text, w*0.94, largest)
    love.graphics.setFont(font)
    set_colour(colour or TEXT)
    love.graphics.printf(text, w*0.03, y, w*0.94, 'center')
    return y + font:getHeight()
end

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
