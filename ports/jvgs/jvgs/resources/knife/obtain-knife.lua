events.trigger{
    collision = function(self, event)
        local collider = event:getCollider()
        if common.isPlayer(collider) then
            local sprite = jvgslua.Sprite("resources/player/knife-sprite.xml")
            collider:setSprite(sprite)
            collider:set("weapon", "knife")
            self:setGarbage()
            effects.staticText(self:getPosition() + jvgslua.Vector2D(0, -100),
                    "B button to throw a knife")
        end
    end
}
