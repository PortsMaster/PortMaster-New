-- extending the object class
local object = object:extend()

object.layer = 0

-- create is called once the object is just created in the room
function object:create()
    self.pages = {
        "A game by:\nHamdy Elzanqali\n\nMusic:\nLet's be silly\nBy ChillMindscapes",
        "Tools I used:\n\nLOVE FRAMEWORK + LUA\nASEPRITE - Sprite editor\nChiptone - FOR SFX",
        "Libraries I found useful:\n\nclassic by rxi\nlume by rxi\nvector by themousery\nrequire by kikito\nJSON.LUA by rxi\nTEsound by drhayes",
        "MISC\n\nEDG32 color palette by ENDESGA\n\nInitially inspired by a game \ncalled Sulka by Kultisti\n\nThanks to anyone who helped.",
        "\n\n\n     AND YOU, obviously!",
    }
    self.current = 1
    self.length = #self.pages
    self.offset = 0
end


function object:next()
    self.current = self.current + 1
    if self.current > self.length then
        self.current = 1
    end
    self.offset = font.main:getHeight(self.pages[self.current]) / 2
end

function object:previous()
    self.current = self.current - 1
    if self.current < 1 then
        self.current = self.length
    end

    self.offset = font.main:getHeight(self.pages[self.current]) / 2
end

-- draw is called once every draw frame
function object:draw()
    color.reset()
    graphics.print(self.pages[self.current], 16, 20)
end

return object