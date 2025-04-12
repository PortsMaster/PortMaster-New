local splash2 = {}


function splash2.new(config, width, height)
    local self = {}
    self.config = config
    self.width = width
    self.height = height
    self.done = false
    self.skipped = false
    self.timer = 0
    self.duration = config.duration or 10

    function self:draw()
        self:drawBackground()
        love.graphics.setColor(1, 1, 1) -- Set color to white
        local font = love.graphics.getFont()
        local lines = {}
        for line in self.config.text:gmatch("[^\n]+") do
            table.insert(lines, line)
        end
        local textHeight = #lines * font:getHeight()
        local y = (self.height - textHeight) / 2
        for _, line in ipairs(lines) do
            local textWidth = font:getWidth(line)
            love.graphics.print(line, (self.width - textWidth) / 2, y)
            y = y + font:getHeight()
        end
    end

    function self:update(dt)
        self.timer = self.timer + dt
        if self.timer > self.duration then
            self.done = true
        end
    end

    function self:skip()
        self.done = true
        self.skipped = true
    end

    function self:loadBackground()
        -- Release previously loaded images (if any)
        if background then
            background:release()
            background = nil
        end
          
        -- Load images with nearest-neighbor filtering
        love.graphics.setDefaultFilter("nearest", "nearest")

        background = love.graphics.newImage("assets/background2.png")
        background:setFilter("nearest", "nearest")

        -- Restore default filter settings
        love.graphics.setDefaultFilter("linear", "linear")
    end

    function self:drawBackground()
        local windowWidth, windowHeight = love.graphics.getDimensions()

        -- Set the default filter to nearest for sharp pixel scaling
        love.graphics.setDefaultFilter("nearest", "nearest")

        -- Draw the background layer
        if background then
            local backgroundScale = windowHeight / background:getHeight()
            local backgroundWidth = background:getWidth() * backgroundScale
            local backgroundOffsetX = math.floor((windowWidth - backgroundWidth) / 2)
            love.graphics.draw(background, math.floor(backgroundOffsetX), 0, 0, backgroundScale, backgroundScale)
        end
    end

    -- Load the background image when the splash screen is created
    self:loadBackground()

    return self
end

return splash2