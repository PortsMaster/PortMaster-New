events.trigger{
    collision = function(self, event)
        effects.staticText(self:getPosition() + jvgslua.Vector2D(0, -100),
                "do not jump on spikey enemies")
        self:setGarbage()
    end
}
