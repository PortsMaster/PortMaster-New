events.trigger{
    collision = function(self, event)
        local im = jvgslua.InputManager_getInstance()
        im:sendQuitEvent()
    end
}
