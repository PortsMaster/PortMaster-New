local object = object:extend()
object.tag = "checkpoint"

local HOVER_SPEED = 0.5

function object:create(ldtkEntity)
    self.position = vector(ldtkEntity.x - 1, ldtkEntity.y)

    self.spriteInactive = sprite("objects/checkpoint-inactive.png")
    self.spriteActive = sprite("objects/checkpoint-active.png")
    self.sprite = self.spriteInactive

    self.id = ldtkEntity.props.id
    self.flipped = ldtkEntity.props.flipped
    
    self.target = ldtkEntity.props.point and vector(ldtkEntity.props.point.cx * 8, ldtkEntity.props.point.cy * 8) or self.position
    
    self.target.x = self.target.x + ldtkEntity.props.offsetX
    self.target.y = self.target.y + ldtkEntity.props.offsetY

    self.hoverSpeed = HOVER_SPEED
    self.hoverTimer = 0
    
    self.offset = 0
    game.world:add(self, self.position.x - 7, self.position.y - 8, 24, 24)
    game.shadows:add(self)

    self.playerSet = not (ldtk:getCurrentName() .. self.id == game.checkpoint)
    self.skipFrame = true
end

function object:update(dt)
    if game.paused then
        return
    end

    if not self.playerSet then
        if self.skipFrame then
            self.skipFrame = false
        elseif game.player ~= nil then
            self.playerSet = true
            self.sprite = self.spriteActive
            game.player.position.x = self.target.x + 2
            game.player.position.y = self.target.y + 2
            game.world:update(game.player, game.player.position.x, game.player.position.y)
            game.player.flipped = self.flipped
        end
    end
    
    if self.hoverTimer < 0 then
        self.hoverTimer = self.hoverSpeed
        self.offset = self.offset == 1 and 0 or 1
    else
        self.hoverTimer = self.hoverTimer - dt
    end
end

function object:playerEnter()
    if self.sprite == self.spriteInactive then
        game.checkpoint = ldtk:getCurrentName() .. self.id
        self.sprite = self.spriteActive
        self.playerSet = true
        if game.crown then
            gamedata.set("crown_" .. game.crown, true, "game.sav")
        end
        -- play sound
        game.playSound("checkpoint.wav")
    end
end

function object:draw()
    if game.subpixel then
        self.sprite:draw(self.position.x, self.position.y + self.offset)
    else
        self.sprite:draw(math.floor(self.position.x), math.floor(self.position.y) + self.offset)
    end

    if DEBUG then
        graphics.setColor(0, 0, 1, 0.5)
        graphics.rectangle("fill", game.world:getRect(self))
    end
end

function object:remove()
    game.shadows:remove(self)
    game.world:remove(self)
end

return object