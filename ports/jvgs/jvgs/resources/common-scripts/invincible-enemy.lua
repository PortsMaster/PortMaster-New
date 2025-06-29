events.trigger{
    collision = function(self, event)
        local collider = event:getCollider()
        if not common.isDead(self) and not common.isDead(collider) then
            common.damage(collider, 1)
        end
    end,

    property = function(self, event)
        if event:getKey() == "health" and common.isDead(self) then
            effects.commonDie(self)
        end
    end
}
