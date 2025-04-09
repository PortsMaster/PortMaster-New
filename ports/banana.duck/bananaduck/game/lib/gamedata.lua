local gamedata = {
    loaded = {data = {}},
    isWeb = false,
    _changed = {}
}


local id, content
-- Loads the save file, this has to be called only once.
function gamedata.load(file)
    id = file or 'data'

    -- Load from the save file if it exists.
    if love.filesystem.getInfo(id) then
        content = love.filesystem.read(id)
        gamedata.loaded[id] = lume.deserialize(content or '{}')
    else
        gamedata.loaded[id] = {}
    end

    gamedata.isWeb = (love.system.getOS() == "Web")
end

-- Saves the file to the disk.
-- Note: it's handled in automatically, and it's only called if something is changed
function gamedata.save(file)
    id = file or 'data'
    if gamedata.loaded[id] and gamedata._changed[id] then
        gamedata._changed[id] = nil
        -- Web doesn't support threads, so we have to use the main thread.
        -- This results in a slight delay, so it's recommended to only save while not playing.
        if gamedata.isWeb then
            love.filesystem.write(id, lume.serialize(gamedata.loaded[id]))
        else
            love.thread.newThread([[
                local file, data = ...
                love.filesystem.write(file, data)
            ]]):start(file or 'data', lume.serialize(gamedata.loaded[id]))
        end
        
    end
end


-- Gets some data.
function gamedata.get(data, file)
    id = file or 'data'
    
    if not gamedata.loaded[id] then
        gamedata.load(id)
    end

    return gamedata.loaded[id][data]
end


-- Sets some data.
-- Note: the save file is updated automatically (in update function) when the data is changed.
function gamedata.set(data, value, file)
    id = file or 'data'
    
    if not gamedata.loaded[id] then
        gamedata.load(id)
    end

    if gamedata.loaded[id][data] ~= value then
        gamedata.loaded[id][data] = value
        gamedata._changed[id] = true
    end
    
end


-- Checks if some data exists.
function gamedata.has(data, file)
    id = file or 'data'
    
    if not gamedata.loaded[id] then
        gamedata.load(id)
    end

    return (gamedata.loaded[id][data] ~= nil)
end

-- Resets the save data table.
function gamedata.clear(file)
    id = file or 'data'
    
    if not gamedata.loaded[id] then
        gamedata.load(id)
    end

    gamedata.loaded[id] = {}
    gamedata._changed[id] = true
end

-- Get the save data table.
function gamedata.getAll(file)
    id = file or 'data'
    
    if not gamedata.loaded[id] then
        gamedata.load(id)
    end

    return gamedata.loaded[id]
end

-- Replaces the saved data table with another table.
function gamedata.setAll(t, file)
    id = file or 'data'
    
    if not gamedata.loaded[id] then
        gamedata.load(id)
    end

    gamedata.loaded[id] = t
end


-- Saves all changed files. Should be called at the end of the update cycle.
function gamedata.update()
    for key, _ in pairs(gamedata._changed) do
        gamedata.save(key)
    end
end

return gamedata