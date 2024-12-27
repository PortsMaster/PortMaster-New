local UIState = State:extend("UIState")

-- for new loxel ui testing
-- Fellyn

function UIState:enter()
	local bg = Sprite()
	bg:loadTexture(paths.getImage('menus/menuDesat'))
	bg.color = {0.15, 0.15, 0.15}
	bg:setScrollFactor()
	self:add(bg)

	self.uiList = {}

	self.navbarTest = ui.UINavbar({
		{"File", function()
			if self.windowTest ~= nil then
				self.windowTest.title = 'File!'
			end
			util.playSfx(paths.getSound("beep"))
		end},
		{"Edit", function()
			if self.windowTest ~= nil then
				self.windowTest.title = 'Edit!'
			end
			util.playSfx(paths.getSound("beep"))
		end},
		{"View", function()
			if self.windowTest ~= nil then
				self.windowTest.title = 'View!'
			end
			util.playSfx(paths.getSound("beep"))
		end},
		{"Help", function()
			if self.windowTest ~= nil then
				self.windowTest.title = 'Help!'
			end
			util.playSfx(paths.getSound("beep"))
		end},
		{"Window", function()
			self:add_UIWindow()
			util.playSfx(paths.getSound("beep"))
		end}
	})
	self:add(self.navbarTest)

	table.insert(self.uiList, self.navbarTest)

	self.inputTest = ui.UIInputTextBox(100, 150)
	self:add(self.inputTest)

	self.numStepTest = ui.UINumericStepper(100, 180)
	self:add(self.numStepTest)

	self.dropdownTest = ui.UIDropDown(250, 150, {
		'bf',
		'gf',
		'dad',
		'mom',
		'spooky',
		'pico',
		'tankman',
		'monster',
		'senpai',
		'spirit',
		'bf-pixel',
		'gf-pixel',
		'senpai-angry'
	})
	self:add(self.dropdownTest)
end

function UIState:add_UIWindow()
	if self.windowTest then
		if not self.windowTest.alive then
			self.windowTest:revive()
		else
			self.windowTest:kill()
		end
	else
		self.windowTest = ui.UIWindow(0, 0, nil, nil)
		self.windowTest:screenCenter()
		self:add(self.windowTest)
		table.insert(self.uiList, self.windowTest)

		self.checkboxTest = ui.UICheckbox(10, 10, 20)
		self.windowTest:add(self.checkboxTest)

		self.sliderTest = ui.UISlider(10, 80, 150, 10, 0, "horizontal")
		self.windowTest:add(self.sliderTest)
	end
end

return UIState
