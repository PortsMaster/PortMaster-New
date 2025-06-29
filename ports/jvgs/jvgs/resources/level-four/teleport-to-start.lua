events.trigger{
    collision = function(self, event)
        local collider = event:getCollider()
        if common.isPlayer(collider) then
            collider:setPosition(jvgslua.Vector2D(2425, 1340))
        end
    end
}
