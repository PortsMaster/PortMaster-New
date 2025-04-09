-- extending the object class
local object = object:extend()

object.layer = 0

-- create is called once the object is just created in the room
function object:create(x, y, ...)

    camera.setPosition(0, -128)
    self.lines = {
        {'', 0.5},
        {'A game by\n HAMDY ELZANQALI', 2.5},
        {'Made with LOVE, Literally!', 2.5}
        
    }
    self.number_of_lines = #self.lines
    self.current = 1
    self.timer = self.lines[self.current][2]
    self.text = ''
    self.font_offset = 0

    self.game_logo = resource.image('game-logo.png')
    self.pressAnyTime = 1.5
    self.pressAnyTimer = self.pressAnyTime
    self.showPressAny = false
    self.changed = false
end

-- update is called once every frame
function object:update(dt)
    if self.timer < 0 then
        if self.current + 1> self.number_of_lines then
            camera.y = math.lerp(camera.y, 0, 5 * dt)
            if self.pressAnyTimer < 0 then
                self.showPressAny = not self.showPressAny
                self.pressAnyTimer = self.pressAnyTime
            else
                self.pressAnyTimer = self.pressAnyTimer - dt
            end

            if (input.anyGamepadPressed() or input.anyKeyPressed()) and not self.changed then
                self.changed = true
                objects.splash('cutscenes/1', 0.7, 0.25, 0.15)
            end
            return
        else
            self.current = self.current + 1
            self.timer = self.lines[self.current][2]
            camera.shake(0.05, 0.02, 0.5, 0.25)
        end

        self.text = self.lines[self.current][1]
        self.font_offset = (font.main:getHeight(self.text) / 2)
    else
        if input.anyGamepadPressed() or input.anyKeyPressed() then
            self.timer = -1
        end

        self.timer = self.timer - dt
    end
end

-- draw is called once every draw frame
function object:draw()
    color.light_grey:set()
    graphics.printf(self.text, 0, -64 - self.font_offset, 128, 'center')

    
    if self.showPressAny then
        color.light_grey:set()
        graphics.printf('Press any key to start', 0, 104, 128, 'center')
    end
end

return object