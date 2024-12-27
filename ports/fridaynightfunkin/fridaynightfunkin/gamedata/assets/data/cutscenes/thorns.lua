local doof, music

function create()
	local dialogue = love.filesystem.read(paths.getPath('songs/thorns/dialogue.txt')):split('\n')
	local red = Graphic(-150, -150, game.width * 2, game.height * 2, Color.convert({255, 27, 49}))
	local white = Graphic(-150, -150, game.width * 2, game.height * 2, Color.WHITE)
	local black = Graphic(-150, -150, game.width * 2, game.height * 2, Color.BLACK)

	local senpaiEvil = Sprite()
	senpaiEvil:setFrames(paths.getSparrowAtlas('stages/school-evil/senpaiCrazy'))
	senpaiEvil:addAnimByPrefix('idle', 'Senpai Pre Explosion', 24, false)
	senpaiEvil:setGraphicSize(math.floor(senpaiEvil.width * 6))
	senpaiEvil:setScrollFactor()
	senpaiEvil:updateHitbox()
	senpaiEvil:screenCenter()
	senpaiEvil.antialiasing = false
	senpaiEvil.x = senpaiEvil.x + 280

	music = game.sound.play(paths.getMusic('gameplay/LunchboxScary'), 0.8, true, true)

	doof = DialogueBox(dialogue, 2)
	doof:setScrollFactor()
	doof.cameras = {state.camNotes}
	doof.finishThing = function()
		state:startCountdown()
		close()
	end

	red:setScrollFactor()
	state:add(red)

	white:setScrollFactor()
	white.alpha = 0

	black:setScrollFactor()
	state:add(black)

	for delay = 1, 7 do
		Timer.after(0.3 * delay, function()
			black.alpha = black.alpha - 0.15
			if black.alpha < 0 then
				state:remove(black)
			end
		end)
	end

	state.camHUD.visible, state.camNotes.visible = false, false

	Timer.after(2.1, function()
		state:add(senpaiEvil)
		senpaiEvil.alpha = 0
		state:add(white)
		for delay = 1, 7 do
			Timer.after(0.3 * delay, function()
				senpaiEvil.alpha = senpaiEvil.alpha + 0.15
				if senpaiEvil.alpha > 1 then
					senpaiEvil.alpha = 1

					Timer.tween(2.4, game.camera, {zoom = state.stage.camZoom - 0.2}, 'in-sine')

					senpaiEvil:play('idle')
					game.sound.play(paths.getSound('gameplay/Senpai_Dies'), 1, false, true, function()
						state:remove(senpaiEvil)
						state:remove(red)
						state:remove(white)
						game.camera.zoom = state.stage.camZoom
						state:add(doof)
						state.camHUD.visible, state.camNotes.visible = true, true
						state.camHUD:flash(Color.WHITE, 4)
					end)
					Timer.after(2.4, function()
						game.camera.zoom = 1.4
						Timer.tween(1, game.camera, {zoom = state.stage.camZoom - 0.2}, 'out-circ')
						game.camera:shake(0.005, 2.5)
					end)
					Timer.after(3.2, function()
						Timer.tween(1.6, white, {alpha = 1})
					end)
				end
			end)
		end
	end)
end

function postUpdate(dt)
	if controls:pressed('accept') and doof.isEnding then
		music:stop()
	end
end
