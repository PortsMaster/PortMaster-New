events.trigger{
    collision = function(self, event)
        local collider = event:getCollider()

        -- Player reached end, prepare for end.
        if common.isPlayer(collider) and self:getBool("girl-arrived") then
            local em = jvgslua.EffectManager_getInstance()
            local fe = jvgslua.FadeEffect(20000)
            collider:setController(nil)
            collider:setPositioner(nil)
            collider:setVelocity(jvgslua.Vector2D(0, 0))
            em:addEffect(fe)
            self:setTimer(20000)
            common.dispose(self)

        -- Girl reached the end, wait for player.
        elseif collider:getId() == "girl" then
            collider:setController(nil)
            collider:setVelocity(jvgslua.Vector2D(0, 0))
            self:setBool("girl-arrived", true)
        end
    end,

    timer = function(self, event)
        common.nextLevel("resources/level-credits/level.xml")
        local pm = jvgslua.PersistenceManager_getInstance()
        pm:set("level", "resources/level-intro/level.xml")
    end
}
