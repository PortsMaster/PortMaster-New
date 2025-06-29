events.trigger{
    collision = function(self, event)
        local level = self:getLevel()
        local id, number = string.match(self:getId(), "^(.+)-(.+)$")
        local ball = level:getEntityById("ball-" .. number)

        if ball then
            self:setGarbage()
            ball:getPositioner():setGravity(jvgslua.Vector2D(0, 0.003))
            ball:setCollisionChecker(true)
        end
    end
}
