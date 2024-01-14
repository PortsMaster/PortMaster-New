simpleScale = {}
--Your Game's Aspect Ratio
local gAspectRatio
--The Window's Aspect Ratio
local wAspectRatio
--The scale between the game and the window's aspect ratio
simpleScale.scale = 1

local xt, yt = 0, 0, 1
local gameW, gameH, windowW, windowH = 800, 600, 800, 600

-- Declares your game's width and height, and sets the window size/settings
-- To be used instead of love.window.setMode
--    [gw] and [gh] are the width and height of the initial game
--    [sw] and [sh] (optional) are the width and height of the final window
--    [settings] (optional) are settings for love.window.setMode
function simpleScale.setWindow(gw, gh, sw, sh, settings)
	sw = sw or gw
	sh = sh or gh
	gAspectRatio = gw/gh
	gameW = gw
	gameH = gh
	simpleScale.updateWindow(sw, sh, settings)
end

-- Updates the Window size/settings
-- To be used instead of love.window.setMode
--    [sw] and [sh] are the width and height of the new Window
--    [settings] (optional) are settings for love.window.setMode
function simpleScale.updateWindow(sw, sh, settings)
	love.window.setMode(sw, sh, settings)
	windowW, windowH = love.graphics.getWidth(), love.graphics.getHeight()
	wAspectRatio = windowW/windowH

	--Window aspect ratio is TALLER than game
	if gAspectRatio > wAspectRatio then
		scale = windowW/gameW
		xt = 0
		yt = windowH/2 - (scale*gameH)/2

	--Window aspect ratio is WIDER than game
	elseif gAspectRatio < wAspectRatio then
		scale = windowH/gameH
		xt = windowW/2 - (scale*gameW)/2
		yt = 0

	--Window and game aspect ratios are EQUAL
	else
		scale = windowW/gameW

		xt = 0
		yt = 0
	end
	simpleScale.scale = scale
end

-- If you screen is resizable on drag, you'll need to call this to make sure
-- the appropriate screen values stay updated
-- You can call it on love.update() with no trouble
function simpleScale.resizeUpdate()
	windowW, windowH = love.graphics.getWidth(), love.graphics.getHeight()
	wAspectRatio = windowW/windowH

	--Window aspect ratio is TALLER than game
	if gAspectRatio > wAspectRatio then
		scale = windowW/gameW
		xt = 0
		yt = windowH/2 - (scale*gameH)/2

	--Window aspect ratio is WIDER than game
	elseif gAspectRatio < wAspectRatio then
		scale = windowH/gameH
		xt = windowW/2 - (scale*gameW)/2
		yt = 0

	--Window and game aspect ratios are EQUAL
	else
		scale = windowW/gameW

		xt = 0
		yt = 0
	end
	simpleScale.scale = scale
end

function simpleScale.getScale()
	return scale
end

function simpleScale.getHBlackBox()
	if gAspectRatio > wAspectRatio then
		return math.abs((gameH*scale - (windowH))/2)
	else
		return 0
	end
end

function simpleScale.getWBlackBox()
	if gAspectRatio > wAspectRatio then
		return 0
	else
		return math.abs((gameW*scale - (windowW))/2)
	end
end

-- Transforms the game's window relative to the entire window
-- Call this at the beginning of love.draw()
function simpleScale.set()
	love.graphics.push()
	love.graphics.translate(xt, yt)
	love.graphics.scale(scale, scale)
end

-- Untransforms the game's window
-- Call this at the end of love.draw
-- You can optionally make the letterboxes a specific color by passing
--    [color] (optional) a table of color values
function simpleScale.unSet(color)
	love.graphics.scale(1/scale, 1/scale)
	love.graphics.translate(-xt, -yt)
	love.graphics.pop()

	--Draw the Letterboxes
	local r,g,b,a = love.graphics.getColor()
	local originalColor = love.graphics.getColor()
	local boxColor
	if color == nil then
		boxColor = {0,0,0}
	else
		boxColor = color
	end
	love.graphics.setColor(boxColor)
	--Horizontal bars
	if gAspectRatio > wAspectRatio then
		love.graphics.rectangle("fill", 0, 0, windowW, math.abs((gameH*scale - (windowH))/2))
		love.graphics.rectangle("fill", 0, windowH, windowW, -math.abs((gameH*scale - (windowH))/2))
		--Vertical bars
	elseif gAspectRatio < wAspectRatio then
		love.graphics.rectangle("fill", 0, 0, math.abs((gameW*scale - (windowW))/2),windowH)
		love.graphics.rectangle("fill", windowW, 0, -math.abs((gameW*scale - (windowW))/2),windowH)
	end
	love.graphics.setColor(r,g,b,a)
end
