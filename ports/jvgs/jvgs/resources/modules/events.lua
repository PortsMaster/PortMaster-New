events = {
    trigger = function(events)
        local event = jvgslua.EntityEventManager_getInstance():getPendingEvent()
        local self = event:getSource()
        local f = events[event:getType()]
        if f then f(self, event) end
    end
}
