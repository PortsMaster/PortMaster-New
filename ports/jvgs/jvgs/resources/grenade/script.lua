events.trigger{
    spawn = function(self, event)
        self:setTimer(1000 + 4000 * math.random())
    end,

    collision = function(self, event)
        local collider = event:getCollider()
        if not common.isPlayer(collider) then
            common.damage(collider, 1)
            self:setGarbage()
        end
    end,

    timer = function(self, event)
        local am = jvgslua.AudioManager_getInstance()
        am:playSound("resources/grenade/explosion.ogg")

        -- Some effects
        effects.stars(self:getPosition(), 3, {"skull"})
        effects.text(self:getPosition(), "Boom!")

        local level = self:getLevel()
        for i = 0, level:getNumberOfEntities() - 1 do
            local entity = level:getEntity(i)
            if entity:getPosition():getDistance(self:getPosition()) < 150 then
                common.damage(entity, 1)
            end
        end
        self:setGarbage()
    end
}
