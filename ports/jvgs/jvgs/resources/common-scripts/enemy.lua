events.trigger{
    collision = function(self, event)
        local collider = event:getCollider()

        -- React only on player collision.
        if common.isPlayer(collider) and not common.isDead(self) and
                not common.isDead(collider) then

            local y = collider:getPosition():getY() + collider:getRadius():getY()
            if self:getPosition():getY() > y then
                common.damage(self, 1)
            else
                common.damage(collider, 1)
            end
        end
    end, 

    property = function(self, event)
        if event:getKey() == "health" and common.isDead(self) then
            effects.commonDie(self)
        end
    end
}
