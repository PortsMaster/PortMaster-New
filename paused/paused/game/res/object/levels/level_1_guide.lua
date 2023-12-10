-- extending the object class
local object = object:extend()

object.layer = -1

-- persistent is whether the object should remain while changing rooms or not
object.persistent = false

-- create is called once the object is just created in the room
function object:create(x, y, ...)
    self.guide1_image = resource.image("guide/double_jump.png")
    self.guide2_image = resource.image("guide/glide.png")
    self.guide1_text = "Press 'jump' in the air\nto double jump."
    self.guide2_text = "Hold 'jump' in the air\nto glide."

    self.label = objects.label({x = 24, y = 52, props = {text = ''}})

    self.guide = 1
    self.switchDelay = 0.05
end

-- update is called once every frame
function object:update(dt)
    if global.bunny and global.bunny.position.y > 80 and global.bunny.position.x > 100 then
        self.guide = 2
        
    end
end

-- draw is called once every draw frame
function object:draw()
    color.reset()
    if self.guide == 1 then
        self.label.text = self.guide1_text
        graphics.draw(self.guide1_image, 44, 74)
        global.level:selectCharacter(1)
        global.duckling.position.x = -100
        global.duckling.position.y = -100
    else
        if self.switchDelay > 0 then
            global.level:selectCharacter(2)
            self.switchDelay = self.switchDelay - love.timer.getDelta()
            return
        end
        if global.duckling.position.x < -50 then
            global.duckling.position = vector(30, 89)
            for i = 1, 4, 1 do
                objects.dust(30 + math.random(-5, 5), 89 + math.random(-5, 5))
                camera.shake(0.1, 0.02, 0.35, 0.15)
            end
        end
        self.label.text = self.guide2_text
        graphics.draw(self.guide2_image, 44, 74)
        global.level:selectCharacter(2)
    end
end

return object