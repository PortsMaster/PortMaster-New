--Last line of "function love.draw()"
	drawCursor()

--End of file
function drawCursor()
	if integral then
		cursorImage:setFilter("nearest", "nearest")
	else
		cursorImage:setFilter("linear", "linear")
	end
    local mouseX, mouseY = love.mouse.getPosition()
    love.graphics.draw(cursorImage, mouseX, mouseY, 0, scaling)
end