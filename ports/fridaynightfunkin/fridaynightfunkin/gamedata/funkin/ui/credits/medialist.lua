local MediaList = SpriteGroup:extend("MediaList")

function MediaList:reload(person)
	self:clear()

	local function makeThing(name, icon, i)
		local img = Sprite(0, 0, paths.getImage("menus/credits/social/" .. icon))
		img.y = (img.height * i) + (8 * i)
		img:setGraphicSize(img.width, 42)
		img:updateHitbox()
		img:setScrollFactor()
		self:add(img)

		local txt = Text(img.width + 10, img.y,
			name or "Missing", paths.getFont("vcr.ttf", 34))
		txt.y = img.y + (img.height - txt:getHeight()) / 2
		txt:setOutline("normal", 4)
		txt.antialiasing = false
		txt:setScrollFactor()
		self:add(txt)
	end

	if person.social then
		for i = #person.social, 1, -1 do
			local social = person.social[i]
			makeThing(social.text, social.name:lower(), #person.social - i)
		end
	end
end

return MediaList
