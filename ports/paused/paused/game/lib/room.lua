--[[
    A basic room/scene/level implementation
]]
local room = {
    _queue = {},
    _queueSize = 0,
    layers = {},
    pathToRooms = '',   -- path to rooms
    instances = {},     -- table of layers to instances.
    current = '',       -- always the room loaded last.
}

-- sets the path of the rooms.
function room.setRooms(path)
    room.pathToRooms = path
end

-- clears current room and loads the new one.
function room.goTo(rm)
    room.clear(false)
    room.load(rm)
end

-- reloads current room
function room.reload()
    room.goTo(room.current)
end

-- clears the current room.
function room.clear(clearPersistent)
    room._isLoading = true
    room._addToQueue(
        function()
            if clearPersistent then
                for _, layer in ipairs(room.layers) do
                    for key, instance in pairs(room.instances[layer]) do
                        instance:remove()
                    end
                end
        
                room.instances = {}
            else
                for _, layer in ipairs(room.layers) do
                    for key, instance in pairs(room.instances[layer]) do
                        if not instance.persistent then
                            instance:remove()
                            room.instances[layer][key] = nil
                        end
                    end
                end
            end
            room._isLoading = false
        end
    )
    
end

local function runFile(name)
	local ok, chunk, err = pcall(love.filesystem.load, name) -- load the chunk safely
	if not ok    then  return false, "Failed loading code: "..chunk  end
	if not chunk then  return false, "Failed reading file: "..err    end

	local ok, value = pcall(chunk) -- execute the chunk safely
	if not ok then  return false, "Failed calling chunk: "..tostring(value)  end

	return true, value -- success!
end

-- loads a room.
function room.load(rm)
    room._addToQueue(function ()
        room.current = rm
        local ok, err = runFile (room.pathToRooms .. rm .. ".lua")
        if not ok then
            error(err)
        end
    end)
end

-- checks if a room exists.
function room.exists(rm)
    return love.filesystem.getInfo(room.pathToRooms .. rm .. '.lua') ~= nil
end

-- updates room instances.
function room.update(dt)
    for _, layer in ipairs(room.layers) do
        for _, instance in pairs(room.instances[layer]) do
            instance:update(dt)
        end
    end

    -- queued actions
    for pos, func in ipairs(room._queue) do
        func()
        room._queue[pos] = nil
    end

    room._queueSize = 0
end

-- draws room instances.
function room.draw()
    for _, layer in ipairs(room.layers) do
        for _, instance in pairs(room.instances[layer]) do
            instance:draw()
        end
    end
end

-- adds an action to the queue.
function room._addToQueue(func)
    room._queueSize = room._queueSize + 1
    room._queue[room._queueSize] = func
end

-- adds the object to the room.
function room._add(obj, ...)
    local arg = {...}
    room._addToQueue(function ()
        if not room.instances[obj.layer] then
            room.instances[obj.layer] = {}
            room._sortLayers()
        end
        room.instances[obj.layer][obj] = obj
        obj:create(unpack(arg))
    end)
end

-- removes an object from the room.
function room._remove(obj)
    room._addToQueue(function ()
        if not room.instances[obj.layer] then
            return
        end
        room.instances[obj.layer][obj] = nil

        if table.isempty(room.instances[obj.layer]) then
            room.instances[obj.layer] = nil
            room._sortLayers()
        end

        obj:remove()
    end)
end

-- changes the layer of an object.
function room._changeLayer(obj, newLayer)
    if obj.layer == newLayer then
        return
    end
    room._addToQueue(function ()
        -- remove the object from the old layer
        room.instances[obj.layer][obj] = nil

        if table.isempty(room.instances[obj.layer]) then
            room.instances[obj.layer] = nil
            room._sortLayers()
        end

        -- add the object to the new layer
        obj.layer = newLayer

        if not room.instances[obj.layer] then
            room.instances[obj.layer] = {}
            room._sortLayers()
        end
        
        room.instances[obj.layer][obj] = obj
    end)
end

local pos
-- sorts the layers.
function room._sortLayers()
    pos = 1
    room.layers = {}
    for layer, _ in pairs(room.instances) do
        room.layers[pos] = layer
        pos = pos + 1
    end
    table.sort(room.layers)
end

return room