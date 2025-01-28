controls = {}
controls.settings = {}

controls.settings.left = {"key", {"left"}}
controls.settings.right = {"key", {"right"}}
controls.settings.up = {"key", {"up"}}
controls.settings.down = {"key", {"down"}}
controls.settings["return"] = {"key", {"return", "kpenter"}}
controls.settings.escape = {"key", {"escape"}}
controls.settings.rotateleft = {"key", {"y", "z", "w"}}
controls.settings.rotateright = {"key", {"x"}}

--player 2
controls.settings.leftp2 = {"key", {"j"}}
controls.settings.rightp2 = {"key", {"k"}}
controls.settings.downp2 = {"key", {"m"}}
controls.settings.rotateleftp2 = {"key", {"o"}}
controls.settings.rotaterightp2 = {"key", {"p"}}

function controls.check(t, key)
	if controls.settings[t][1] == "key" then
		for i = 1, #controls.settings[t][2] do
			if key == controls.settings[t][2][i] then
				return true
			end
		end
		return false
	end
end

function controls.isDown(t)
	if controls.settings[t][1] == "key" then
		for i = 1, #controls.settings[t][2] do
			if love.keyboard.isDown(controls.settings[t][2][i]) then
				return true
			end
		end
		return false
	end
end
