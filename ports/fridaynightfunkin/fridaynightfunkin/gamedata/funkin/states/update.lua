local UpdateState = State:extend("UpdateState")

local updateVersion = ''

function UpdateState.check(goToState)
	if Project.flags.checkForUpdates and not UpdateState.closed then
		print('Checking for updates...')

		local code, response = Https.request("https://raw.githubusercontent.com/Stilic/FNF-LOVE/main/project.lua")
		if code == 200 then
			local curVersion = Project.version
			local githubVersion = load(response)().version
			print('Github version: ' .. githubVersion)
			print('Your version: ' .. curVersion)
			if curVersion ~= githubVersion then
				if goToState then game.switchState(UpdateState(githubVersion), true) end
				return false
			end
		else
			print('Error: ' .. code)
		end
	end
	return true
end

function UpdateState:new(version)
	UpdateState.super.new(self)
	if version then updateVersion = version end
end

function UpdateState:enter()
	-- Update Presence
	if Discord then
		Discord.changePresence({details = "In the Menus", state = "Update Screen"})
	end

	local bg = Sprite():loadTexture(paths.getImage('menus/menuDesat'))
	bg.color = {0.1, 0.1, 0.1}
	self:add(bg)

	local textmoment = "Oh look, an update! you are running an outdated version."
		.. "\nCurrent Version: " .. Project.version
		.. " - Update Version: " .. updateVersion
		.. "\n\n Press BACK to proceed."

	local textupdate = Text(0, 0, textmoment, paths.getFont('phantommuff.ttf', 30),
		Color.WHITE, 'center')
	textupdate:screenCenter()
	textupdate.y = textupdate.y - 40
	self:add(textupdate)

	self.blackScreen = Graphic(0, 0, game.width, game.height, Color.BLACK)
	self.blackScreen.visible = false
	self:add(self.blackScreen)

	UpdateState.super.enter(self)
end

function UpdateState:update(dt)
	if controls:pressed('accept') then
		love.system.openURL('https://github.com/Stilic/FNF-LOVE/tree/main')
		game.switchState(TitleState())
	elseif controls:pressed('back') then
		util.playSfx(paths.getSound('cancelMenu'))
		self.blackScreen.visible = true
		game.switchState(TitleState())
	end
end

return UpdateState
