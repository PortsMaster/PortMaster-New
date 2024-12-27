local Settings = require "funkin.ui.options.settings"

local function percentvalue(value) return value .. "%" end
local data = {
	{"GENERAL"},
	{"autoPause", "Auto pause on lost focus", "boolean", function()
		local value = not ClientPrefs.data.autoPause
		ClientPrefs.data.autoPause = value
		love.autoPause = value
	end},
	{"backgroundDim", "Background dim", "number", function(add)
		local value = math.clamp(ClientPrefs.data.backgroundDim + add, 0, 100)
		ClientPrefs.data.backgroundDim = value
	end, percentvalue},
	-- {"notesBelowHUD", "Notes below HUD", "boolean"},
	{"flashingLights", "Flashing lights", "boolean"},
	{"downScroll",    "Down scroll",     "boolean"},
	{"middleScroll",  "Middle scroll",   "boolean"},
	{"ghostTap",      "Ghost tap",       "boolean"},
	{"noteSplash",    "Note splash",     "boolean"},
	{"botplayMode",   "Botplay",         "boolean"},
	{"playback", "Playback", "number", function(add)
		local value = math.clamp(ClientPrefs.data.playback + (add * 0.05), 0.1, 5)
		ClientPrefs.data.playback = value
	end, function(value) return "x" .. value end},
	-- {"timeType",      "Song time type",      "string", {"left", "elapsed"}},
	{"gameOverInfos", "Show game over info", "boolean"},

	{"AUDIO"},
	{"pauseMusic",    "Pause music",         "string", {"railways", "breakfast"}},
	{"hitSound", "Hit sound volume", "number", function(add)
		local value = math.clamp(ClientPrefs.data.hitSound + add, 0, 100)
		ClientPrefs.data.hitSound = value

		game.sound.play(paths.getSound('hitsound'), value / 100)
		return nil, true
	end, percentvalue},
	{"sfxVolume", "SFX volume", "number", function(add)
		local value = math.clamp(ClientPrefs.data.sfxVolume + add, 0, 100)
		ClientPrefs.data.sfxVolume = value
	end, percentvalue},
	{"menuMusicVolume", "Menu's music volume", "number", function(add)
		local value = math.clamp(ClientPrefs.data.menuMusicVolume + add, 0, 100)
		ClientPrefs.data.menuMusicVolume = value
	end, percentvalue},
	{"musicVolume", "Instrumental volume", "number", function(add)
		local value = math.clamp(ClientPrefs.data.musicVolume + add, 0, 100)
		ClientPrefs.data.musicVolume = value
	end, percentvalue},
	{"vocalVolume", "Vocals volume", "number", function(add)
		local value = math.clamp(ClientPrefs.data.vocalVolume + add, 0, 100)
		ClientPrefs.data.vocalVolume = value
	end, percentvalue},
	{"songOffset", "Song offset", "number"},
	{"calibration", "Calibrate", function(optionsUI)
		if optionsUI.aboutToGoToCalibration then return end
		util.playSfx(paths.getSound('scrollMenu'))
		optionsUI.aboutToGoToCalibration = true
		optionsUI.changingOption = false
	end}
}

local Gameplay = Settings:base("Gameplay", data)

function Gameplay:update(dt, optionsUI)
	if optionsUI.aboutToGoToCalibration and not self.wow then
		if self.crateThing then
			if controls:pressed("back") then
				util.playSfx(paths.getSound('cancelMenu'))

				optionsUI:remove(self.bg)
				optionsUI:remove(self.waitInputTxt)
				optionsUI:remove(self.waitInputTxt2)

				optionsUI.blockInput = false
				optionsUI.aboutToGoToCalibration = nil
				self.crateThing = false

				return true
			elseif controls:pressed('accept') then
				game.getState().transOut = CalibrationState.transOut
				game.switchState(CalibrationState())
				self.wow = true

				return true
			end
		else
			if not self.bg then
				self.bg = Graphic(0, 0, game.width, game.height, Color.BLACK)
				self.bg:setScrollFactor()
				self.bg.alpha = 0.5

				self.waitInputTxt = Text(0, 0, "Are you sure you want to enter Calibration?", paths.getFont("phantommuff.ttf", 40),
					Color.WHITE, "center", game.width)
				self.waitInputTxt:screenCenter('y')
				self.waitInputTxt:setScrollFactor()
				self.waitInputTxt.y = self.waitInputTxt.y - 40

				self.waitInputTxt2 = Text(0, 0, "Press Accept key to Continue, Press Escape key to Nevermind i think",
					paths.getFont("phantommuff.ttf", 24),
					Color.WHITE, "center", game.width)
				self.waitInputTxt2:screenCenter('y')
				self.waitInputTxt2:setScrollFactor()
				self.waitInputTxt2.y = self.waitInputTxt2.y + 40
			end
			optionsUI:add(self.bg)
			optionsUI:add(self.waitInputTxt)
			optionsUI:add(self.waitInputTxt2)
			self.crateThing = true
		end
	end
end

return Gameplay
