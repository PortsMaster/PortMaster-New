events.trigger{
    collision = function(self, event)
        -- Only after being dropped
        if self:isCollisionChecker() then
            local collider = event:getCollider()
            common.damage(collider, 100)
            effects.stars(self:getPosition(), 5)
            self:setGarbage()
        end
    end
}
