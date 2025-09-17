events.trigger{
    collision = function(self, event)
        local collider = event:getCollider()
        if common.isPlayer(collider) then
            local sprite = jvgslua.Sprite("resources/player/grenade-sprite.xml")
            collider:setSprite(sprite)
            collider:set("weapon", "grenade")
            self:setGarbage()
            effects.staticText(self:getPosition() + jvgslua.Vector2D(0, -100),
                    "left ctrl to throw a grenade")
        end
    end
}
