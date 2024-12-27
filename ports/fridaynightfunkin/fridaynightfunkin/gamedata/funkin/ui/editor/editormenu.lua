---@class EditorMenu
local EditorMenu = SpriteGroup:extend("EditorMenu")

function EditorMenu:new(completionCallback)
	EditorMenu.super.new(self)

	self.exit = false
	self.completionCallback = completionCallback

	self.optionShit = {
		{"charter",   "Chart Editor"},
		{"character", "Character Editor"},
		{"charter",   "Cutscene Editor"}
	}
	self.curSelected = 1

	self.bg = Graphic(0, 0, game.width, game.height, Color.BLACK)
	self.bg.alpha = 0
	self.bg:setScrollFactor()
	self:add(self.bg)

	self.grpText = SpriteGroup()
	self.grpText:setScrollFactor()
	self:add(self.grpText)

	self.grpIcon = SpriteGroup()
	self.grpIcon:setScrollFactor()
	self:add(self.grpIcon)
end

function EditorMenu:enter(parent)
	self.parent = parent

	self.throttles = {}
	self.throttles.left = Throttle:make({controls.down, controls, "ui_left"})
	self.throttles.right = Throttle:make({controls.down, controls, "ui_right"})
	self.throttles.up = Throttle:make({controls.down, controls, "ui_up"})
	self.throttles.down = Throttle:make({controls.down, controls, "ui_down"})

	for i = 0, #self.optionShit - 1 do
		local optionText = Alphabet(0, (70 * i) + 30,
			self.optionShit[i + 1][2], true, false)
		optionText.isMenuItem = true
		optionText.targetY = i
		self.grpText:add(optionText)
		optionText.ID = i + 1

		if optionText:getWidth() > 980 then
			local textScale = 980 / optionText:getWidth()
			optionText.scale.x = textScale
			for _, letter in ipairs(optionText.lettersArray) do
				letter.x = letter.x * textScale
				letter.offset.x = letter.offset.x * textScale
			end
		end

		local icon = Sprite()
		icon:loadTexture(paths.getImage("editor/menu/" .. self.optionShit[i + 1][1]))
		icon:updateHitbox()
		icon.ID = optionText.ID
		self.grpIcon:add(icon)
	end
	self.grpText.alpha = 1
	self.grpText.x = 0
	self.grpIcon.alpha = 1
	self.grpIcon.x = 0
	self.x = 0

	Timer.tween(0.4, self.bg, {alpha = 0.6}, 'in-out-quart')

	self:revive()
	self.visible = true
	self.exit = false

	self:changeSelection()
end

local triggerChoice = {
	["Chart Editor"] = function() game.switchState(ChartingState()) end,
	--["Character Editor"] = function() game.switchState(CharacterEditor()) end,
	["Cutscene Editor"] = function() game.switchState(CutsceneState()) end
}

function EditorMenu:update(dt)
	EditorMenu.super.update(self, dt)

	if not self.exit then
		if self.throttles.up:check() then self:changeSelection(shift and -2 or -1) end
		if self.throttles.down:check() then self:changeSelection(shift and 2 or 1) end

		if controls:pressed('back') then
			util.playSfx(paths.getSound('cancelMenu'))
			self.exit = true

			Timer.cancelTweensOf(self.grpText)
			Timer.tween(0.4, self.grpText, {x = -720, alpha = 0}, 'in-circ')

			Timer.cancelTweensOf(self.grpIcon)
			Timer.tween(0.4, self.grpIcon, {x = -720, alpha = 0}, 'in-circ')

			Timer.cancelTweensOf(self.bg)
			Timer.tween(0.4, self.bg, {alpha = 0}, 'in-out-quart', function()
				return self.parent:remove(self)
			end)
		end

		if controls:pressed('accept') then
			local switch = triggerChoice[self.optionShit[self.curSelected][2]]
			if switch then
				game.sound.music:stop()
				switch()
			end
		end
	end

	for _, icon in pairs(self.grpIcon.members) do
		local textTracker = nil
		for _, spr in pairs(self.grpText.members) do
			if icon.ID == spr.ID then textTracker = spr end
		end
		if textTracker then
			icon:setPosition(textTracker.x + textTracker:getWidth() + 10,
				textTracker.y - 30)
		end
	end
end

function EditorMenu:changeSelection(huh)
	if huh == nil then huh = 0 end
	util.playSfx(paths.getSound('scrollMenu'))

	self.curSelected = self.curSelected + huh

	if self.curSelected > #self.optionShit then
		self.curSelected = 1
	elseif self.curSelected < 1 then
		self.curSelected = #self.optionShit
	end

	local bullShit = 0

	for _, item in pairs(self.grpText.members) do
		item.targetY = bullShit - (self.curSelected - 1)
		bullShit = bullShit + 1

		item.alpha = 0.6

		if item.targetY == 0 then item.alpha = 1 end
	end

	for _, icon in pairs(self.grpIcon.members) do
		icon.alpha = icon.ID == self.curSelected and 1 or 0.6
	end
end

function EditorMenu:leave()
	self.grpText:clear()
	self.grpText.x = 0

	self.grpIcon:clear()
	self.grpIcon.x = 0

	self:kill()
	self.visible = false
	self.parent = nil

	if self.completionCallback then
		self.completionCallback()
	end
end

return EditorMenu
