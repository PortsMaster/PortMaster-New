function create()
	local bg = Sprite(-600, -200):loadTexture(
		paths.getImage(SCRIPT_PATH .. "stageback"))
	bg.antialiasing = true
	bg:setScrollFactor(0.9, 0.9)
	bg:updateHitbox()
	self:add(bg)

	local stageFront = Sprite(-650, 600):loadTexture(paths.getImage(
		SCRIPT_PATH ..
		"stagefront"))
	stageFront:setGraphicSize(math.floor(stageFront.width * 1.1))
	stageFront:updateHitbox()
	stageFront.antialiasing = true
	stageFront:setScrollFactor(0.9, 0.9)
	self:add(stageFront)

	local stageCurtains = Sprite(-500, -300):loadTexture(paths.getImage(
		SCRIPT_PATH ..
		"stagecurtains"))
	stageCurtains:setGraphicSize(math.floor(stageCurtains.width * 0.9))
	stageCurtains:updateHitbox()
	stageCurtains.antialiasing = true
	stageCurtains:setScrollFactor(1.3, 1.3)
	self:add(stageCurtains)

	close()
end
