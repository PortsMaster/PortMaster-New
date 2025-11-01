local Object = require("./classic")

ImageTrigger = Object.extend(Object)

ImageTrigger.image = love.graphics.newImage("paper_drawing.png")
Audio.create_sound("sounds/page_flip.ogg", "page_flip", "static", 4)

local H_PADDING = 8

function ImageTrigger.new(self, pos, id)
    self.id = id

    self.pos = V2(pos.x - H_PADDING*0.5, pos.y)
    self.width = ImageTrigger.image:getWidth() + H_PADDING
    self.height = ImageTrigger.image:getHeight()

    self.opened = false
    self.should_close = false

    self.opened_t = 0
end

function ImageTrigger:update(dt)
    if(self.opened) then
        self.opened_t = math.min(self.opened_t + dt, 1)
    else
        self.opened_t = math.max(self.opened_t - dt, 0)
    end

    if(self.opened and self.should_close) then
        self.opened = false
        Audio.play_sound("page_flip", 0.9, 0.9, 0.8)
        UI.remove_queued_museum_image(self.id)
    end
    self.should_close = true
end

function ImageTrigger:triggered_by_player()
    self.should_close = false
    if(not self.opened) then
        UI.draw_museum_image(self.id)
        Audio.play_sound("page_flip")
    end
    self.opened = true
end

function ImageTrigger:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y),
        V2(self.pos.x + self.width, self.pos.y + self.height)
    )
end

function ImageTrigger:draw()
    if false then
        draw_hitbox(self)
    end

    local opened_y_offset = 0
    if(self.opened) then
        opened_y_offset = lume.lerp(0, 4, easeOut(self.opened_t))
    else
        opened_y_offset = lume.lerp(0, 4, easeIn(self.opened_t))
    end
    love.graphics.draw(ImageTrigger.image, self.pos.x + H_PADDING*0.5, self.pos.y - opened_y_offset)
end
