local level = {}

level.events = {}
level.listeners = {}

function level:resetEvents()
    for index, value in pairs(level.events) do
        level.events[index] = nil
    end
end

function level:resetListeners()
    for key, value in pairs(level.listeners) do
        level.listeners[key] = nil
    end
end

function level:fireEvent(event)
    level.events[event] = true
end

function level:listenToEvent(object, event, func)
    level.listeners[object] = level.listeners[object] or {}
    level.listeners[object][event] = func
end

function level:stopListentionToEvent()
    if level.listeners[object] then
        level.listeners[object][event] = nil
    end
end

function level:updateEvents()
    for listener, events in pairs(level.listeners) do
        for event, func in pairs(events) do
            if level.events[event] then
                func()
            end
        end
    end

    level:resetEvents()
end

return level