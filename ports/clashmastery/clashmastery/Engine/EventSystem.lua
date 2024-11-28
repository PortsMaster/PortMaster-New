local EventSystem = {}

function EventSystem.initialize()
    EventSystem.listeners = {}
end

function EventSystem.createListener(eventType, callback)
    local listener = {
        type = eventType,
        callback = callback
    }
    if not EventSystem.listeners[eventType] then
        EventSystem.listeners[eventType] = {}
    end
    table.insert(EventSystem.listeners[eventType], listener)
    return listener
end

function EventSystem.broadcast(eventType, eventData)
    local listeners = EventSystem.listeners[eventType]
    if listeners then
        for k = 1,#listeners do
            local listener = listeners[k]
            listener.callback(eventData)
        end
    end
end

return EventSystem