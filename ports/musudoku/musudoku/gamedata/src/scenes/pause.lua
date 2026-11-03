local ui = require("src.ui")
local theme = require("src.theme")
local sound = require("src.sound")

local Pause = { overlay = true }
Pause.__index = Pause

function Pause.new(app)
    local self = setmetatable({ app = app, t = 0, sel = 1 }, Pause)
    self.items = {
        { label = "Resume", run = function() self:resumeGame() end },
        { label = app.settings.boardOnly and "Show side panel" or "Distraction-free", run = function()
            app.settings.boardOnly = not app.settings.boardOnly
            app.saveSettings()
            app.pop()
        end },
        { label = "Check board", run = function() self:checkBoard() end },
        { label = "Restart puzzle", run = function()
            app.push("confirm", {
                title = "Restart this puzzle?",
                body = "Your numbers, notes and time will be cleared.",
                yes = "Restart",
                onYes = function()
                    app.game:restart()
                    app.saveGame()
                    app.setScene("play")
                end,
            })
        end },
        { label = "New puzzle", run = function() app.push("difficulty") end },
        { label = "Settings", run = function() app.push("settings") end },
        { label = "Exit to title", run = function()
            app.saveGame()
            app.setScene("title")
        end },
    }
    -- With mistake checking on, wrong numbers are already red.
    if app.settings.mistakes then table.remove(self.items, 3) end
    return self
end

-- Tells how many placed numbers are wrong, not which. Costs a hint.
function Pause:checkBoard()
    local app, g = self.app, self.app.game
    if g:checkPlaced() == 0 then
        app.push("confirm", {
            info = true,
            title = "Nothing to check",
            body = "You haven't placed any numbers yet.",
        })
        return
    end
    app.push("confirm", {
        title = "Check the board?",
        body = "Counts the wrong numbers without showing where they are. It counts as a hint"
            .. (g.pack and "." or ", so this solve won't set a best time."),
        yes = "Check",
        onYes = function()
            local placed, wrong = g:checkPlaced()
            g:countHint()
            app.saveGame()
            local title, body
            if wrong == 0 then
                title = "No mistakes"
                body = placed == 1 and "The number you've placed is right."
                    or ("All " .. ui.number(placed) .. " numbers you've placed are right.")
            else
                title = wrong == 1 and "1 number is wrong" or (ui.number(wrong) .. " numbers are wrong")
                body = "Out of the " .. ui.number(placed) .. " you've placed."
            end
            app.push("confirm", {
                info = true, title = title, body = body, yes = "Resume",
                onYes = function() app.pop() end, -- closes the pause menu too
            })
        end,
    })
end

function Pause:resumeGame()
    sound.play("close")
    self.app.pop()
end

function Pause:update(dt)
    self.t = self.t + dt
end

function Pause:busy()
    return self.t < 0.3
end

function Pause:action(a)
    if a == "up" then
        self.sel = (self.sel - 2) % #self.items + 1
        sound.play("menu")
    elseif a == "down" then
        self.sel = self.sel % #self.items + 1
        sound.play("menu")
    elseif a == "a" then
        if self.sel ~= 1 then sound.play("open") end
        self.items[self.sel].run()
    elseif a == "b" or a == "start" or a == "menu" then
        self:resumeGame()
    end
end

function Pause:draw()
    local p = ui.ease(self.t / 0.16)
    local w, h = 320, 76 + #self.items * 44 + 44
    local x, y = ui.card(w, h, p)

    theme.set("text", p)
    ui.text("Paused", x + 32, y + 26, 30, "bold")
    local g = self.app.game
    if g then
        theme.set("muted", p)
        ui.centered(ui.formatTime(g.elapsed), x + w - 32, y + 46, 18, "regular", "right")
    end

    for k, item in ipairs(self.items) do
        local cy = y + 100 + (k - 1) * 44
        local selected = (k == self.sel)
        if selected then
            theme.set("panel", p)
            ui.rect("fill", x + 16, cy - 19, w - 32, 38, 8)
            theme.set("accent", p)
            ui.rect("fill", x + 16, cy - 10, 4, 20, 2)
        end
        theme.set(selected and "text" or "muted", p)
        ui.centered(item.label, x + 34, cy, 20, selected and "bold" or "regular", "left")
    end

    ui.hints({ { "B", "Resume" }, { "A", "Select" } }, x + w - 24, y + h - 26, "right", p)
end

return Pause
