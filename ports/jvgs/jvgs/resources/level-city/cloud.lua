events.trigger{
    collision = function(self, event)
        if common.isPlayer(event:getCollider()) then
            effects.nextLevelAnimation(event:getCollider())
            self:setTimer(2000)
        end
    end,

    timer = function(self, event)
        common.nextLevel("resources/level-four/level.xml")
    end
}
