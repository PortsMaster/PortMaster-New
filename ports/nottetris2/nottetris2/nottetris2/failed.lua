function failed_load()
	gamestate = "failed"
	tetribodies = {} -- CLEAR ALL
	tetrishapes = {} -- PIECES
	love.audio.play(gameover2)
end

function failed_draw()
	--FULLSCREEN OFFSET
	if fullscreen then
		love.graphics.translate(fullscreenoffsetX, fullscreenoffsetY)
		
		--scissor
		love.graphics.setScissor(fullscreenoffsetX, fullscreenoffsetY, 160*scale, 144*scale)
	end
	
	if gameno == 1 then
		love.graphics.draw(gamebackgroundcutoff, 0, 0, 0, scale)
		love.graphics.draw(gameovercutoff, 14*scale, 0, 0, scale)
	else
		love.graphics.draw(gamebackground, 0, 0, 0, scale)
		love.graphics.draw(gameover, 16*scale, 0, 0, scale)
	end
	
	--SCORES---------------------------------------
	--"score"--
	offsetX = 0
	
	scorestring = tostring(scorescore)
	for i = 1, scorestring:len() - 1 do
		offsetX = offsetX - 8*scale
	end
	love.graphics.print( scorescore, 144*scale + offsetX, 24*scale, 0, scale)
	
	
	--"level"--
	offsetX = 0
	
	scorestring = tostring(levelscore)
	for i = 1, scorestring:len() - 1 do
		offsetX = offsetX - 8*scale
	end
	love.graphics.print( levelscore, 136*scale + offsetX, 56*scale, 0, scale)
	
	--"tiles"--
	offsetX = 0
	
	scorestring = tostring(linesscore)
	for i = 1, scorestring:len() - 1 do
		offsetX = offsetX - 8*scale
	end
	love.graphics.print( linesscore, 136*scale + offsetX, 80*scale, 0, scale)
	-----------------------------------------------
	
	
	--FULLSCREEN OFFSET
	if fullscreen then
		love.graphics.translate(-fullscreenoffsetX, -fullscreenoffsetY)
		
		--scissor
		love.graphics.setScissor()
	end
end

function failed_update()

end

function failed_checkhighscores()
	highscoreno = 0
	selectblink = true
	oldtime = love.timer.getTime()
	for i = 1, 3 do
		if scorescore > highscore[i] then
			if i == 1 then
				highscore[3] = highscore[2]
				highscore[2] = highscore[1]
				highscorename[3] = highscorename[2]
				highscorename[2] = highscorename[1]
			elseif i == 2 then
				highscore[3] = highscore[2]
				highscorename[3] = highscorename[2]
			end
				
			highscoreno = i
			highscorename[i] = ""
			highscore[i] = scorescore
			cursorblink = true
			love.audio.play(highscoreintro)
			highscoremusicstart = love.timer.getTime()
			musicchanged = false
			gamestate = "highscoreentry"
			break
		end
	end
	if highscoreno == 0 then--no new highscore
		gamestate = "menu"
		if musicno < 4 then
			love.audio.play(music[musicno])
		end
	end
end