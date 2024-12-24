local Mouse = {
	LEFT = 1,
	RIGHT = 2,
	MIDDLE = 3,

	wheel = 0,
	x = 0,
	y = 0,
	screenX = 0,
	screenY = 0,
	deltaX = 0,
	deltaY = 0,
	deltaScreenX = 0,
	deltaScreenY = 0,
	__prevX = 0,
	__prevY = 0,
	__prevScreenX = 0,
	__prevScreenY = 0,

	isMoved = false,

	justPressed = false,
	justPressedLeft = false,
	justPressedRight = false,
	justPressedMiddle = false,

	pressed = false,
	pressedLeft = false,
	pressedRight = false,
	pressedMiddle = false,

	justReleased = false,
	justReleasedLeft = false,
	justReleasedRight = false,
	justReleasedMiddle = false,

	released = true,
	releasedLeft = true,
	releasedRight = true,
	releasedMiddle = true
}

function Mouse.reset()
	if Mouse.wheel ~= 0 then Mouse.wheel = 0 end
	if Mouse.isMoved then Mouse.isMoved = false end
	if Mouse.justPressed then
		Mouse.justPressed = false
		Mouse.justPressedLeft = false
		Mouse.justPressedRight = false
		Mouse.justPressedMiddle = false
	end
	if Mouse.justReleased then
		Mouse.justReleased = false
		Mouse.justReleasedLeft = false
		Mouse.justReleaseddRight = false
		Mouse.justReleasedMiddle = false
	end
	Mouse.deltaX = 0
	Mouse.deltaY = 0
	Mouse.deltaScreenX = 0
	Mouse.deltaScreenY = 0
end

function Mouse.overlaps(obj, cam)
	local camera = cam or game.camera
	local mouseX, mouseY = Mouse.x + camera.scroll.x,
		Mouse.y + camera.scroll.y
	if obj then
		if obj:is(Group) then
			for _, o in ipairs(obj.members) do
				if o and (o.x and o.y and o.width and o.height) then
					Mouse.overlaps(o, cam)
				end
			end
		elseif obj:is(Object) then
			return mouseX >= obj.x and mouseX <= obj.x + obj.width and mouseY >=
				obj.y and mouseY <= obj.y + obj.height
		end
	end
	return false
end

function Mouse.onPressed(button)
	if button == Mouse.LEFT then
		Mouse.justPressedLeft = true
		Mouse.pressedLeft = true
		Mouse.justReleasedLeft = false
		Mouse.releasedLeft = false
	elseif button == Mouse.RIGHT then
		Mouse.justPressedRight = true
		Mouse.pressedRight = true
		Mouse.justReleasedRight = false
		Mouse.releasedRight = false
	elseif button == Mouse.MIDDLE then
		Mouse.justPressedMiddle = true
		Mouse.pressedMiddle = true
		Mouse.justReleasedMiddle = false
		Mouse.releasedMiddle = false
	end
	Mouse.justPressed = true
	Mouse.pressed = true
	Mouse.justReleased = false
	Mouse.released = false
end

function Mouse.onReleased(button)
	if button == Mouse.LEFT then
		Mouse.justPressedLeft = false
		Mouse.pressedLeft = false
		Mouse.justReleasedLeft = true
		Mouse.releasedLeft = true
	elseif button == Mouse.RIGHT then
		Mouse.justPressedRight = false
		Mouse.pressedRight = false
		Mouse.justReleasedRight = true
		Mouse.releasedRight = true
	elseif button == Mouse.MIDDLE then
		Mouse.justPressedMiddle = false
		Mouse.pressedMiddle = false
		Mouse.justReleasedMiddle = true
		Mouse.releasedMiddle = true
	end
	Mouse.justPressed = false
	Mouse.pressed = false
	Mouse.justReleased = true
	Mouse.released = true
end

function Mouse.onMoved(x, y)
	local winWidth, winHeight = love.graphics.getDimensions()
	local scale = math.min(winWidth / game.width, winHeight / game.height)

	Mouse.__prevX = Mouse.x
	Mouse.__prevY = Mouse.y
	Mouse.__prevScreenX = Mouse.screenX
	Mouse.__prevScreenY = Mouse.screenY

	Mouse.x, Mouse.y = (x - (winWidth - scale * game.width) / 2) / scale,
		(y - (winHeight - scale * game.height) / 2) / scale

	Mouse.screenX, Mouse.screenY = x, y
	Mouse.isMoved = true

	Mouse.deltaX = Mouse.x - Mouse.__prevX
	Mouse.deltaY = Mouse.y - Mouse.__prevY
	Mouse.deltaScreenX = Mouse.screenX - Mouse.__prevScreenX
	Mouse.deltaScreenY = Mouse.screenY - Mouse.__prevScreenY
end

return Mouse
