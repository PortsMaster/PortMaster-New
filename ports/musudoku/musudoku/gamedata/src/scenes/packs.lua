local ui = require("src.ui")
local theme = require("src.theme")
local sound = require("src.sound")
local packs = require("src.packs")

-- Lists the puzzle files in the packs folder.
local Packs = {}
Packs.__index = Packs

local VISIBLE = 6

function Packs.new(app)
    local self = setmetatable({ app = app, t = 0, sel = 1, top = 1 }, Packs)
    self:refresh()
    return self
end

function Packs:refresh()
    self.dir = packs.dir()
    self.files = packs.list(self.dir)
    self.sel = math.max(1, math.min(self.sel, #self.files))
end

function Packs:resume()
    self:refresh()
end

function Packs:update(dt)
    self.t = self.t + dt
end

function Packs:action(a)
    local n = #self.files
    if a == "b" or a == "start" then
        sound.play("close")
        if #self.app.stack > 1 then self.app.pop() else self.app.setScene("title") end
    elseif a == "y" then
        sound.play("menu")
        self:refresh()
    elseif n == 0 then
        return
    elseif a == "up" then
        self.sel = (self.sel - 2) % n + 1
        sound.play("menu")
    elseif a == "down" then
        self.sel = self.sel % n + 1
        sound.play("menu")
    elseif a == "a" then
        sound.play("open")
        self.app.push("pack", self.files[self.sel])
    end
    if self.sel < self.top then self.top = self.sel end
    if self.sel >= self.top + VISIBLE then self.top = self.sel - VISIBLE + 1 end
end

local function sizeText(bytes)
    if bytes >= 1024 * 1024 then return string.format("%.1f MB", bytes / 1048576) end
    return string.format("%d KB", math.max(1, math.floor(bytes / 1024 + 0.5)))
end

function Packs:detail(file)
    local p = self.app.packProgress[file.file]
    if p and p.count > 0 and p.size == file.size then
        local solved = packs.solvedCount(p)
        local text = ui.number(p.count) .. (p.count == 1 and " puzzle" or " puzzles")
        if solved > 0 then text = text .. ", " .. ui.number(solved) .. " solved" end
        return text, solved / p.count
    end
    return sizeText(file.size) .. ", not opened yet", nil
end

function Packs:drawEmpty()
    theme.set("text")
    ui.text("No puzzle packs yet", 64, 118, 24, "bold")
    theme.set("muted")
    ui.text("Copy puzzle files into this folder, then press Y to refresh:", 64, 158, 16, "regular", "left", 592)
    theme.set("panel")
    ui.rect("fill", 48, 188, 624, 44, 8)
    theme.set("text")
    ui.text(self.dir, 64, 200, 15, "bold", "left", 592)
    theme.set("muted")
    ui.text("Use .txt, .sdm, .sdk or .csv files. Put one puzzle per line, as 81 characters with 0 or . for empty cells. Grids of 9 lines also work, and extra columns such as ratings or solutions are ignored.",
        64, 252, 16, "regular", "left", 592)
end

function Packs:draw()
    theme.set("text")
    ui.text("Puzzle packs", 64, 40, 36, "bold")

    if #self.files == 0 then
        self:drawEmpty()
        ui.hints({ { "Y", "Refresh" }, { "B", "Back" } }, 696, 452, "right")
        return
    end

    local x, w, h, y0 = 64, 592, 52, 104
    for k = self.top, math.min(#self.files, self.top + VISIBLE - 1) do
        local file = self.files[k]
        local y = y0 + (k - self.top) * (h + 4)
        local selected = (k == self.sel)
        if selected then
            theme.set("panel")
            ui.rect("fill", x - 16, y, w + 32, h, 10)
            theme.set("accent")
            ui.rect("fill", x - 16, y + 14, 5, h - 28, 2)
        end
        theme.set(selected and "text" or "muted")
        ui.centered(file.name, x, y + h / 2, 22, selected and "bold" or "regular", "left")
        local text, fraction = self:detail(file)
        theme.set("muted")
        ui.centered(text, x + w, y + h / 2, 15, "regular", "right")
        if fraction and fraction > 0 then
            theme.set("accent", 0.8)
            ui.rect("fill", x, y + h - 7, math.max(4, (w * 0.35) * fraction), 3, 1.5)
        end
    end

    if #self.files > VISIBLE then
        theme.set("muted")
        ui.centered(self.sel .. " of " .. #self.files, 64, 452, 14, "regular", "left")
    end
    ui.hints({ { "Y", "Refresh" }, { "B", "Back" }, { "A", "Open" } }, 696, 452, "right")
end

return Packs
