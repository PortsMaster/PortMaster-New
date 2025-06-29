events.trigger{
    collision = function(self, event)
        effects.staticText(self:getPosition() + jvgslua.Vector2D(0, -100),
                "jump on enemies to kill them")
        self:setGarbage()
    end
}
