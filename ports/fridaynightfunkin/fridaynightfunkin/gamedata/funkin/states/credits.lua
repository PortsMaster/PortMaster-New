local CreditsState = State:extend("CreditsState")

local UserList = require "funkin.ui.credits.userlist"
local UserCard = require "funkin.ui.credits.usercard"

-- would it be funny if the x renamed to twitter instead to mock elon musk
CreditsState.defaultData = {
	{
		header = "Engine Team",
		credits = {
			{
				name = "Stilic",
				icon = "stilic",
				color = "#FFCA45",
				description = "something",
				social = {
					{name = "X",      text = "@stilic_dev"},
					{name = "Github", text = "/Stilic"}
				}
			},
			{
				name = "Raltyro",
				icon = "ralty",
				color = "#FF4545",
				description = "something",
				social = {
					{name = "X",       text = "@raltyro"},
					{name = "Youtube", text = "@Raltyro"},
					{name = "Github",  text = "/Raltyro"}
				}
			},
			{
				name = "Fellyn",
				icon = "fellyn",
				color = "#E49CFA",
				description = "something",
				social = {
					{name = "X",       text = "@FellynnLol_"},
					{name = "Youtube", text = "@FellynnMusic_"},
					{name = "Github",  text = "/FellynYukira"}
				}
			},
			{
				name = "Victor Kaoy",
				icon = "vickaoy",
				color = "#D1794D",
				description = "something",
				social = {
					{name = "X", text = "@vk15_"}
				}
			},
			{
				name = "Blue Colorsin",
				icon = "bluecolorsin",
				color = "#2B56FF",
				description = "something",
				social = {
					{name = "X",       text = "@BlueColorsin"},
					{name = "Youtube", text = "@BlueColorsin"},
					{name = "Github",  text = "/BlueColorsin"}
				}
			},
			{
				name = "Ralsin",
				icon = "ralsin",
				color = "#383838",
				description = "something",
				social = {
					{name = "X",       text = "@ralsi_"},
					{name = "Youtube", text = "@ralsin"},
					{name = "Github",  text = "/Ralsin"}
				}
			}
		}
	},
	{
		header = "Funkin' Team",
		credits = {
			{
				name = "Ninjamuffin99",
				icon = "ninjamuffin",
				color = "#FF392B",
				description = "Programmer of Friday Night Funkin'",
				social = {
					{name = "X",       text = "@ninja_muffin99"},
					{name = "Youtube", text = "@camerontaylor5970"},
					{name = "Github",  text = "/ninjamuffin99"}
				}
			},
			{
				name = "Phantom Arcade",
				icon = "phantomarcade",
				color = "#EBC73B",
				description = "Animator of Friday Night Funkin'",
				social = {
					{name = "X",       text = "@PhantomArcade3K"},
					{name = "Youtube", text = "@PhantomArcade"}
				}
			},
			{
				name = "EvilSk8r",
				icon = "evilsk8r",
				color = "#5EED3E",
				description = "Artist of Friday Night Funkin'",
				social = {
					{name = "X", text = "@evilsk8r"}
				}
			},
			{
				name = "Kawai Sprite",
				icon = "kawaisprite",
				color = "#4185FA",
				description = "Musician of Friday Night Funkin'",
				social = {
					{name = "X",       text = "@kawaisprite"},
					{name = "Youtube", text = "@KawaiSprite"}
				}
			}
		}
	}
}

function CreditsState:enter()
	CreditsState.super.enter(self)

	if Discord then
		Discord.changePresence({details = "In the Menus", state = "Credits"})
	end

	self.data = {}

	self.lastHeight = 0
	self.curSelected = 1
	self.curTab = 1

	self.camFollow = {x = game.width / 2, y = game.height / 2}
	game.camera:follow(self.camFollow, nil, 8)
	game.camera:snapToTarget()

	self.bg = Sprite(0, 0, paths.getImage('menus/menuDesat'))
	self:add(util.responsiveBG(self.bg))

	self.bd = BackDrop(0, 0, game.width, game.height, 72, nil, {0, 0, 0, 0}, 26)
	self.bd:setScrollFactor()
	self.bd.alpha = 0.5
	self:add(self.bd)

	local creditsMod = paths.getJSON('data/credits')
	if creditsMod then
		for i = 1, #creditsMod do table.insert(self.data, creditsMod[i]) end
	end
	for i = 1, #self.defaultData do
		table.insert(self.data, self.defaultData[i])
	end

	self.userList = UserList(self.data)
	self:add(self.userList)

	self.userCard = UserCard(10 + self.userList:getWidth() + 10, 10,
		game.width - self.userList:getWidth() - 30, game.height - 130)
	self:add(self.userCard)

	self:changeSelection()

	local colorBG = Color.fromString(self.userList:getCurrent().color or "#DF7B29")
	self.bg.color = colorBG
	self.bd.color = Color.saturate(self.bg.color, 0.4)

	self.throttles = {}
	self.throttles.up = Throttle:make({controls.down, controls, "ui_up"})
	self.throttles.down = Throttle:make({controls.down, controls, "ui_down"})

	if love.system.getDevice() == "Mobile" then
		self.buttons = VirtualPadGroup()
		local w = 134

		local down = VirtualPad("down", 0, game.height - w)
		local up = VirtualPad("up", 0, down.y - w)
		local back = VirtualPad("escape", game.width - w, down.y, nil, nil, Color.RED)

		self.buttons:add(down)
		self.buttons:add(up)
		self.buttons:add(back)

		self:add(self.buttons)
	end
end

function CreditsState:update(dt)
	CreditsState.super.update(self, dt)
	if self.throttles then
		if self.throttles.up:check() then self:changeSelection(-1) end
		if self.throttles.down:check() then self:changeSelection(1) end
	end
	if controls:pressed("back") then
		util.playSfx(paths.getSound('cancelMenu'))
		game.switchState(MainMenuState())
	end

	local u = self.userList
	if u.bar.y > game.camera.scroll.y + game.height - u.bar.height then
		self.camFollow.y = u.bar.y - game.height / 2 + 74
	elseif u.bar.y < self.camFollow.y - game.height / 2 + 74 then
		self.camFollow.y = u.bar.y + game.height / 2 - 94
	end

	local colorBG = Color.fromString(self.userList:getCurrent().color or "#DF7B29")
	self.bg.color = Color.lerpDelta(self.bg.color, colorBG, 3, dt)
	self.bd.color = Color.saturate(self.bg.color, 0.4)
end

function CreditsState:changeSelection(n)
	if n == nil then n = 0 end
	util.playSfx(paths.getSound('scrollMenu'))

	self.userList:changeSelection(n)
	self.userCard:reload(self.userList:getCurrent())
end

return CreditsState
