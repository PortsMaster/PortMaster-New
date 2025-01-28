function rocket_load()
	rocketscores = {}
	if gameno == 1 then
		rocketscores[1] = 3000
		rocketscores[2] = 7000
		rocketscores[3] = 11000
		rocketscores[4] = 15000
	else
		rocketscores[1] = 3200
		rocketscores[2] = 3400
		rocketscores[3] = 3600
		rocketscores[4] = 3700
	end
	
	for i = 4, 1, -1 do
		if scorescore >= rocketscores[i] then
			if i < 4 then
				love.audio.stop(musicrocket1to3)
				love.audio.play(musicrocket1to3)
			else
				love.audio.stop(musicrocket4)
				love.audio.play(musicrocket4)
			end
			rockettimer = love.timer.getTime()
			gamestate = "rocket"..tostring(i)
			currenttime = love.timer.getTime()
			timelapsed = currenttime - rockettimer
			break
		end
	end

	if gamestate == "failed" then
		failed_checkhighscores()
	end
	
end

function rocket_update()
	--check for sequence over
	if gamestate == "rocket4" then
		if timelapsed > 41.1 then
			failed_checkhighscores()
		end
	else
		if timelapsed > 31.5 then
			failed_checkhighscores()
		end
	end
end

function rocket_draw()
	--FULLSCREEN OFFSET
	if fullscreen then
		love.graphics.translate(fullscreenoffsetX, fullscreenoffsetY)
		
		--scissor
		love.graphics.setScissor(fullscreenoffsetX, fullscreenoffsetY, 160*scale, 144*scale)
	end
	
	currenttime = love.timer.getTime()
	timelapsed = currenttime - rockettimer
	
	--background
	love.graphics.draw( rocketbackground, 0, 0, 0, scale, scale)
	if gamestate == "rocket4" then
		love.graphics.draw( bigrockettakeoffbackground, 54*scale, 60*scale, 0, scale, scale)
	end
	
	--rocket position
	if gamestate == "rocket4" then
		rocketpos = 112 - 112*((timelapsed-12)/18)
	else
		rocketpos = 112 - 112*((timelapsed-8)/18)
	end
	
	--fire
	if gamestate == "rocket4" then
		if timelapsed > 13 then
			if math.mod( math.floor(timelapsed*8), 2) == 0 then
				love.graphics.draw( firebig1, 68*scale, round(rocketpos*scale), 0, scale, scale)
			else
				love.graphics.draw( firebig2, 68*scale, round(rocketpos*scale), 0, scale, scale)
			end
		end
	else
		if timelapsed > 8.5 then
			if math.mod( math.floor(timelapsed*8), 2) == 0 then
				love.graphics.draw( fire1, 77*scale, round(rocketpos*scale), 0, scale, scale)
			else
				love.graphics.draw( fire2, 76*scale, round(rocketpos*scale), 0, scale, scale)
			end
		end
	end
	
	--rocket
	if gamestate == "rocket4" then
		if timelapsed < 12 then
			love.graphics.draw( bigrocketbackground, 64*scale, 48*scale, 0, scale, scale)
		else
			love.graphics.draw( spaceshuttle, 64*scale, round(rocketpos*scale), 0, scale, scale, 0, 64)--18 seconds for 112 pixels
		end
	else
		if timelapsed < 8 then
			if gamestate == "rocket1" then
				love.graphics.draw( rocket1, 75*scale, 84*scale, 0, scale, scale)
			elseif gamestate == "rocket2" then
				love.graphics.draw( rocket2, 76*scale, 74*scale, 0, scale, scale)
			elseif gamestate == "rocket3" then
				love.graphics.draw( rocket3, 72*scale, 56*scale, 0, scale, scale)
			end
		else
			if gamestate == "rocket1" then
				love.graphics.draw( rocket1, 75*scale, round(rocketpos*scale), 0, scale, scale, 0, 28)
			elseif gamestate == "rocket2" then
				love.graphics.draw( rocket2, 76*scale, round(rocketpos*scale), 0, scale, scale, 0, 38)
			elseif gamestate == "rocket3" then
				love.graphics.draw( rocket3, 72*scale, round(rocketpos*scale), 0, scale, scale, 0, 56)
			end
		end
	end
	
	--smoke
	if gamestate == "rocket4" then
		if timelapsed > 3 and timelapsed < 8 then
			if math.mod( math.floor(timelapsed*6), 2) == 0 then
				love.graphics.draw( smoke1left, 50*scale, 106*scale, 0, scale, scale)
				love.graphics.draw( smoke1right, 92*scale, 106*scale, 0, scale, scale)
			end
		elseif timelapsed > 8 and timelapsed < 13 then
			if math.mod( math.floor(timelapsed*6), 2) == 0 then
				love.graphics.draw( smoke2left, 44*scale, 98*scale, 0, scale, scale)
				love.graphics.draw( smoke2right, 92*scale, 98*scale, 0, scale, scale)
			end
		end
	else
		if timelapsed > 3 and timelapsed < 8.5 then
			if math.mod( math.floor(timelapsed*6), 2) == 0 then
				love.graphics.draw( smoke1left, 56*scale, 106*scale, 0, scale, scale)
				love.graphics.draw( smoke1right, 86*scale, 106*scale, 0, scale, scale)
			end
		end
	end
	
	--text
	if gamestate == "rocket4" then
		symbolsnumber = 0
		for i = 16, 1, -1 do
			if timelapsed > 35.2 + 1.6*(i/16) then
				symbolsnumber = i
				break
			end
		end
		love.graphics.print(string.sub("congratulations!", 1, symbolsnumber), 16*scale, 32*scale, 0, scale)
		for i = 1, symbolsnumber do
			love.graphics.draw( congratsline, (9+(8*i-1))*scale, 40*scale, 0, scale, scale)
		end
	end
	
	--FULLSCREEN OFFSET
	if fullscreen then
		love.graphics.translate(-fullscreenoffsetX, -fullscreenoffsetY)
		
		--scissor
		love.graphics.setScissor()
	end
end