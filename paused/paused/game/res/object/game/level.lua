-- extending the object class
local object = object:extend()

object.layer = 1000
--It's always called last

object.CHARACTERS = {
    'bunny',
    'duckling'
}
object.number_of_characters = #object.CHARACTERS

object.TIME_SCALE_CHANGE_RATE = 0.15

-- create is called once the object is just created in the room
function object:create(entity)
    self.name = entity.props.name
    self.number = entity.props.number
    self.character = entity.props.character
    self.stats = entity.props.stats
    self.pausedIndicator = resource.image('pause.png')
    self.resumeIndicator = resource.image('resume.png')
    self.skull = resource.image('skull.png')
    self.clock = resource.image('clock.png')
    self.selectIndicator = resource.image('select.png')
    self.timerScale = 1

    global.level = self
    global.paused = false
    global.dead = false
    self.lost = false

    self.pauseMenu = {
        {
            'RESUME',
            nil,
            function ()
                global.paused = false
            end
        },
        {
            'RESTART',
            nil,
            function ()
                objects.splash(room.current, 0.5, 0, 0.1)
            end
        },
        {
            'FULLSCREEN: ',
            function ()
                return global.settings.fullscreen and 'ON' or 'OFF'
            end,
            function ()
                global.setFullscreen(not global.settings.fullscreen)
            end
        },
        {
            'SREEN SHAKES: ',
            function ()
                return tostring(math.floor(global.settings.screenShakes * 100)) .. '%'
            end,
            function ()
                local power = global.settings.screenShakes
                power = power + 0.25
                if power > 1 then
                    power = 0
                end

                global.setScreenShakes(power)
            end,
            function ()
                local power = global.settings.screenShakes
                power = power + 0.25
                if power > 1 then
                    power = 0
                end

                global.setScreenShakes(power)
            end,
            function ()
                local power = global.settings.screenShakes
                power = power - 0.25
                if power < 0 then
                    power = 1
                end

                global.setScreenShakes(power)
            end
        },
        {
            'SOUND: ',
            function ()
                return tostring(global.settings.sound)
            end,
            function ()
                global.setSound(global.settings.sound + 1)
            end,
            function ()
                global.setSound(global.settings.sound + 1)
            end,
            function ()
                global.setSound(global.settings.sound - 1)
            end
        },
        {
            'MUSIC: ',
            function ()
                return tostring(global.settings.music)
            end,
            function ()
                global.setMusic(global.settings.music + 1)
            end,
            function ()
                global.setMusic(global.settings.music + 1)
            end,
            function ()
                global.setMusic(global.settings.music - 1)
            end
        },
        {
            'QUIT',
            nil,
            function ()
                love.event.quit()
            end,
        }
    }
    self.number_of_options = #self.pauseMenu
    self.selection = 1

    if global.isWeb then
        self.pauseMenu[#self.pauseMenu] = nil
        self.number_of_options = self.number_of_options - 1
    end


    self:selectCharacter(self.character)
    
    if global.timer == nil then
        global.timer =  0
    end

    if global.deathCounter == nil then
        global.deathCounter = 0
    end

    camera.y = 0
end

-- update is called once every frame
function object:update(dt)
    if self.timerScale < 1 then
        self.timerScale = self.timerScale + dt / self.TIME_SCALE_CHANGE_RATE / game.timeScale
        game.timeScale = self.timerScale
    else
        self.timerScale = 1
    end

    if input.get 'pause' then
        global.paused = not global.paused
        self.selection = 1
        self.timerScale = 1
        -- TODO: play sound
    end
    
    self:selectCharacter(self.character)

    if global.paused then
        if input.get 'ui_down' then
            self.selection = self.selection + 1
            if self.selection > self.number_of_options then
                self.selection = 1
            end
            global.playSound('menu-select.wav')
        end

        if input.get 'ui_up' then
            self.selection = self.selection - 1
            if self.selection < 1 then
                self.selection = self.number_of_options
            end
            global.playSound('menu-select.wav')
        end

        if input.get 'ui_right' then
            if self.pauseMenu[self.selection][4] then
                self.pauseMenu[self.selection][4]()
                global.playSound('menu-change.wav')
            end
        end

        if input.get 'ui_left' then
            if self.pauseMenu[self.selection][5] then
                self.pauseMenu[self.selection][5]()
                global.playSound('menu-change.wav')
            end
        end

        if input.get 'ui_action' then
            if self.pauseMenu[self.selection][3] then
                self.pauseMenu[self.selection][3]()
                global.playSound('menu-change.wav')
            end
        end
        return
    end

    if input.get 'action' then
        self:switchCharacter()
    end

    if input.get 'reload' then
        objects.splash(room.current, 0.5, 0, 0.1)
    end
    
    if self.stats then
        global.timer = global.timer + dt
    end


end

-- draw is called once every draw frame
function object:draw()
    color.light_grey:set()
    graphics.printf((self.number and tostring(self.number) .. '. ' or '') .. self.name, 0, camera.baseHeight - 14, camera.baseWidth, 'center')

    color.reset()
    local indent = (global.timer > 3600 and 8 or 0)
    if not global.paused then 
        graphics.draw(self.pausedIndicator, camera.baseWidth - 16, 8)
    else
        graphics.draw(self.resumeIndicator, camera.baseWidth - 16, 8)
    end
    graphics.draw(self.clock, 8, 8)
    graphics.draw(self.skull, indent + 40, 8)

    color.light_grey:set()
    graphics.print(self:getFormattedTime(global.timer), 18, 8.5)
    graphics.print(tostring(global.deathCounter), indent + 50, 8.5)

    if global.paused then
        color.black:set(0.85)
        graphics.rectangle('fill', -camera._resolution_offset.x, -camera._resolution_offset.y, camera.width, camera.height)
        
        color.white:set()
        local y = (camera.baseHeight / 2) - math.floor(self.number_of_options / 2) * 8 - 4
        graphics.print('PAUSED', 35, y - 4)
        
        for index, option in ipairs(self.pauseMenu) do
            graphics.print(option[1] .. (option[2] and option[2]() or ''), 35, y + index * 8)
        end

        color.reset()
        graphics.draw(self.selectIndicator, 30, y + self.selection * 8 + 1)
    end

end

function object:getFormattedTime(time)
    local result = ''
    local minutes = math.floor(time / 60)
    local hours = math.floor(minutes / 60)
    minutes = minutes - hours * 60
    local seconds = math.floor(time - 60 * minutes - 3600 * hours)

    if hours > 0 then
        if hours < 10 then
            result = result .. '0'
        end
        result = result .. tostring(hours) .. ':'
    end

    if minutes < 10 then
        result = result .. '0'
    end
    result = result .. tostring(minutes) .. ':'
    
    if seconds < 10 then
        result = result .. '0'
    end

    result = result .. tostring(seconds)

    return result
end

function object:lose()
    if not self.lost then
        --TODO: play lose sound
        global.playSound('death.wav')
        self.lost = true
        if self.stats then
            global.deathCounter = global.deathCounter + 1
        end
        objects.splash(room.current, 0.5, 0.3, 0.15)
        global.dead = true
    end
end

function object:switchCharacter()
    self.character = self.character + 1
    if self.character > self.number_of_characters then
        self.character = 1
    end
    self:selectCharacter(self.character)
    self.timerScale = 0
end

function object:selectBunny()
    self:selectCharacter(1)
end

function object:selectDuckling()
    self:selectCharacter(2)
end

function object:selectCharacter(character)
    for id, value in ipairs(self.CHARACTERS) do
        if global[value] then
            global[value].paused = not (id == character)
        end
    end
end

function object:remove()
    global.level = nil
end

return object