-- A handy way to load and cache game resources

local resource = {
    images = {},
    fonts  = {},
    pathToImages = '',
    pathToFonts  = '',
    pathToAudio = '',
    -- more later
}

function resource.image(path, ...)
    path = resource.pathToImages .. path
    if not resource.images[path] then
        resource.images[path] = love.graphics.newImage(path, ...)
    end
    return resource.images[path]
end

function resource.font(path, ...)
    path = resource.pathToFonts .. path
    if not resource.fonts[path] then
        resource.fonts[path] = love.graphics.newFont(path, ...)
        local fnt = resource.fonts[path]
    end
    return resource.fonts[path]
end

function resource.imageFont(path, ...)
    path = resource.pathToFonts .. path
    if not resource.fonts[path] then
        resource.fonts[path] = love.graphics.newImageFont(path, ...)
        local fnt = resource.fonts[path]
    end
    return resource.fonts[path]
end

return resource