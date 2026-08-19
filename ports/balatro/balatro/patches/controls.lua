-- PortMaster controller tweaks:
--   Start → options / back (stock splash handling kept)
--   R3 (rightstick) → toggle FPS counter

local fps_hud = {
    enabled = false,
    frames = 0,
    elapsed = 0,
    fps = 0,
    line = '',
}

local original_button_press_update = Controller.button_press_update
function Controller:button_press_update(button, dt)
    if button == 'rightstick' and not self.locks.frame then
        self.frame_buttonpress = true
        fps_hud.enabled = not fps_hud.enabled
        if not fps_hud.enabled then
            fps_hud.frames, fps_hud.elapsed, fps_hud.fps, fps_hud.line = 0, 0, 0, ''
        end
        return
    end

    if button == 'start' and not self.locks.frame then
        if G.OVERLAY_TUTORIAL then
            self.frame_buttonpress = true
            G.FUNCS.skip_tutorial_section()
            return
        end
        local claimed = self.button_registry[button]
        claimed = claimed and claimed[1] and not claimed[1].node.under_overlay
        if not claimed then
            self.frame_buttonpress = true
            if G.STATE == G.STATES.SPLASH then
                G:delete_run()
                G:main_menu()
            elseif not G.OVERLAY_MENU then
                G.FUNCS:options()
            elseif not G.OVERLAY_MENU.config.no_esc then
                G.FUNCS:exit_overlay_menu()
            end
            return
        end
    end
    return original_button_press_update(self, button, dt)
end

local fps_font
local original_game_draw = Game.draw
function Game:draw(...)
    local result = original_game_draw(self, ...)
    if not fps_hud.enabled then return result end

    fps_hud.frames = fps_hud.frames + 1
    fps_hud.elapsed = fps_hud.elapsed + (G.real_dt or love.timer.getDelta())
    if fps_hud.elapsed >= 0.25 then
        fps_hud.fps = fps_hud.frames / fps_hud.elapsed
        fps_hud.frames, fps_hud.elapsed = 0, 0
        local moveables, particles, cards, dead, dots = 0, 0, 0, 0, 0
        if G.MOVEABLES then
            for _, obj in pairs(G.MOVEABLES) do
                moveables = moveables + 1
                if not obj or obj.REMOVED then
                    dead = dead + 1
                elseif getmetatable(obj) == Particles then
                    particles = particles + 1
                    if obj.particles then dots = dots + #obj.particles end
                elseif getmetatable(obj) == Card then
                    cards = cards + 1
                end
            end
        end
        local events = 0
        if G.E_MANAGER and G.E_MANAGER.queues then
            for _, q in pairs(G.E_MANAGER.queues) do
                events = events + #q
            end
        end
        local heap_mb = collectgarbage('count') / 1024
        fps_hud.line = string.format(
            '%.0f FPS  mv %d  ev %d  pt %d/%d  %.0fMB',
            fps_hud.fps, moveables, events, particles, dots, heap_mb)
    end
    if fps_hud.line == '' then return result end

    fps_font = fps_font or love.graphics.newFont(14)
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setShader()
    love.graphics.setCanvas()
    love.graphics.setFont(fps_font)
    local pad = 6
    local w = fps_font:getWidth(fps_hud.line) + pad * 2
    local h = fps_font:getHeight() + pad
    local x, y = 8, 8
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle('fill', x, y, w, h, 4, 4)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(fps_hud.line, x + pad, y + pad * 0.5)
    love.graphics.pop()
    return result
end
