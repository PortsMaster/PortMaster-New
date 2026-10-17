-- Font manager to handle loading and managing fonts
local love = require("love")
local gameState = require("src.states.gameState")
local fontManager = {}

-- Font cache (now stores combined path and size keys)
local fonts = {}

-- Fallback fonts list (Correctly indexing GameConfig.FONTS.FALLBACK_FONTS)
local fallbackFontPaths = GameConfig.FONTS.FALLBACK_FONTS
local fallbackFonts = {}

-- Initialize the font manager
function fontManager.init()
    fontManager.clearCache()
end

-- Clears the loaded fonts cache.
function fontManager.clearCache()
    fonts = {}
    fallbackFonts = {}

    -- Load fallbacks at native scale as well
    local currentScale = GameConfig.SCALE or 1
    local fallbackSize = math.floor(16 * currentScale)

    for _, path in ipairs(fallbackFontPaths) do
        local success, font = pcall(function()
            return love.graphics.newFont(path, fallbackSize)
        end)
        if success and font then
            table.insert(fallbackFonts, font)
        else
            print("Warning: Failed to load fallback font: " .. path)
        end
    end

    fontManager.getFont(16)
    fontManager.getFont(20)
    fontManager.getFont(30)
    fontManager.getFont(40)
end

-- Inside fontManager.lua

function fontManager.getFont(size)
    size = size or 16 -- Simply use the requested size!

    local activeFontPath = GameConfig.FONTS.DEFAULT_FONT

    local cacheKey = activeFontPath .. "_" .. tostring(size)

    if fonts[cacheKey] then
        return fonts[cacheKey]
    end

    local success, font = pcall(function()
        local newFont = love.graphics.newFont(activeFontPath, size)
        if newFont and fallbackFonts and #fallbackFonts > 0 then
            local unpacker = table.unpack or unpack
            newFont:setFallbacks(unpacker(fallbackFonts))
        end
        return newFont
    end)

    if success and font then
        fonts[cacheKey] = font
        return font
    else
        local defaultLoveFont = love.graphics.newFont(size)
        if defaultLoveFont and fallbackFonts and #fallbackFonts > 0 then
            local unpacker = table.unpack or unpack
            defaultLoveFont:setFallbacks(unpacker(fallbackFonts))
        end
        fonts[cacheKey] = defaultLoveFont
        return fonts[cacheKey]
    end
end

return fontManager
