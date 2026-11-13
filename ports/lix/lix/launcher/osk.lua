-- On-screen keyboard driven by d-pad / buttons.
--   A = type key, B = backspace, X = space, Y = toggle case,
--   Start = done, Select = cancel. Physical keyboards also work.

local osk = {}
osk.__index = osk

local LAYOUTS = {
    text = {
        { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
        { "q", "w", "e", "r", "t", "y", "u", "i", "o", "p" },
        { "a", "s", "d", "f", "g", "h", "j", "k", "l", "-" },
        { "z", "x", "c", "v", "b", "n", "m", "_", ".", "!" },
        { "SHIFT", "SPACE", "DEL", "OK" },
    },
    -- fb-server only accepts [A-Za-z0-9_-], max 10 chars
    nick = {
        { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
        { "q", "w", "e", "r", "t", "y", "u", "i", "o", "p" },
        { "a", "s", "d", "f", "g", "h", "j", "k", "l", "-" },
        { "z", "x", "c", "v", "b", "n", "m", "_" },
        { "SHIFT", "DEL", "OK" },
    },
    host = {
        { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
        { "q", "w", "e", "r", "t", "y", "u", "i", "o", "p" },
        { "a", "s", "d", "f", "g", "h", "j", "k", "l", "-" },
        { "z", "x", "c", "v", "b", "n", "m", ".", ":", "_" },
        { "CLEAR", "DEL", "OK" },
    },
    number = {
        { "1", "2", "3" },
        { "4", "5", "6" },
        { "7", "8", "9" },
        { "DEL", "0", "OK" },
    },
}

-- opts: title, value, kind ("text" | "host" | "number"), maxlen, allowed (lua pattern class)
function osk.new(opts, on_done)
    local self = setmetatable({}, osk)
    self.title = opts.title or "Enter text"
    self.value = tostring(opts.value or "")
    self.kind = opts.kind or "text"
    self.maxlen = opts.maxlen or 31
    self.allowed = opts.allowed
    self.layout = LAYOUTS[self.kind]
    self.row, self.col = 1, 1
    self.shift = false
    -- numbers: the first key typed replaces the pre-filled value
    self.fresh = (self.kind == "number")
    self.on_done = on_done
    return self
end

function osk:_accept(ch)
    if self.allowed and not ch:match(self.allowed) then return end
    if self.fresh then self.value = ""; self.fresh = false end
    if #self.value >= self.maxlen then return end
    self.value = self.value .. ch
end

function osk:_press(key)
    if key == "OK" then
        self.on_done(true, self.value)
    elseif key == "DEL" then
        self.fresh = false
        self.value = self.value:sub(1, -2)
    elseif key == "CLEAR" then
        self.value = ""
    elseif key == "SPACE" then
        self:_accept(" ")
    elseif key == "SHIFT" then
        self.shift = not self.shift
    else
        if self.shift then key = key:upper() end
        self:_accept(key)
    end
end

function osk:_clampcol()
    local n = #self.layout[self.row]
    if self.col > n then self.col = n end
end

-- action: up/down/left/right/a/b/x/y/start/back
function osk:action(a)
    local rows = #self.layout
    if a == "up" then
        self.row = (self.row - 2) % rows + 1; self:_clampcol()
    elseif a == "down" then
        self.row = self.row % rows + 1; self:_clampcol()
    elseif a == "left" then
        self.col = (self.col - 2) % #self.layout[self.row] + 1
    elseif a == "right" then
        self.col = self.col % #self.layout[self.row] + 1
    elseif a == "a" then
        self:_press(self.layout[self.row][self.col])
    elseif a == "b" then
        self.fresh = false
        self.value = self.value:sub(1, -2)
    elseif a == "x" then
        if self.kind == "text" then self:_accept(" ") end
    elseif a == "y" then
        self.shift = not self.shift
    elseif a == "start" then
        self.on_done(true, self.value)
    elseif a == "back" then
        self.on_done(false, self.value)
    end
end

function osk:textinput(t)
    for ch in t:gmatch(".") do self:_accept(ch) end
end

function osk:draw(fonts, colors, vprint)
    local W = 640
    love.graphics.setColor(colors.panel)
    love.graphics.rectangle("fill", 40, 40, W - 80, 400, 12, 12)
    love.graphics.setColor(colors.accent)
    vprint(self.title, fonts.title, 40, 56, W - 80, "center")

    -- value box
    love.graphics.setColor(colors.field)
    love.graphics.rectangle("fill", 80, 100, W - 160, 40, 6, 6)
    love.graphics.setColor(colors.text)
    local cursor = (math.floor(love.timer.getTime() * 2) % 2 == 0) and "_" or " "
    vprint(self.value .. cursor, fonts.big, 90, 107, W - 180, "left")

    -- keys
    local top = 160
    local rowh = 44
    for r, row in ipairs(self.layout) do
        local n = #row
        local gap = 6
        local total = W - 160
        local kw = (total - gap * (n - 1)) / n
        for c, key in ipairs(row) do
            local x = 80 + (c - 1) * (kw + gap)
            local y = top + (r - 1) * rowh
            local sel = (r == self.row and c == self.col)
            love.graphics.setColor(sel and colors.accent or colors.key)
            love.graphics.rectangle("fill", x, y, kw, rowh - 6, 6, 6)
            love.graphics.setColor(sel and colors.bg or colors.text)
            local label = key
            if #key == 1 and self.shift then label = key:upper() end
            if key == "SHIFT" and self.shift then label = "shift" end
            vprint(label, fonts.normal, x, y + 9, kw, "center")
        end
    end

    love.graphics.setColor(colors.dim)
    local hint = "A type   B delete   Start done   Select cancel"
    if self.kind == "text" then
        hint = "A type   B delete   X space   Y shift   Start done   Select cancel"
    elseif self.kind == "nick" then
        hint = "A type   B delete   Y shift   Start done   Select cancel"
    end
    vprint(hint, fonts.small, 40, 412, W - 80, "center")
end

return osk
