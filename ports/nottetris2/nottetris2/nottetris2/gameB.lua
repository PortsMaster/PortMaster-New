function gameB_load()
	gamestate = "gameB"
	
	pause = false
	
	difficulty_speed = 100

	scorescore = 0
	levelscore = 0
	linesscore = 40
	nextpiecerot = 0
	
	--PHYSICS--
	meter = 30
	world = love.physics.newWorld(0, 500, true )
	
	tetrikind = {}
	
	wallshapes = {}
	
	tetrifixtures = {}
	tetribodies = {}
	tetrishapes = {}
	
	offsetshapes = {}
	
	wallfixtures = {}
	
	wallbodies = love.physics.newBody(world, 32, -64, "static") --WALLS
	wallshapes[0] = love.physics.newPolygonShape( 0, -64, 0,672, 32,672, 32,-64)
	wallshapes[1] = love.physics.newPolygonShape( 352,-64, 352,672, 384,672, 384,-64)
	wallshapes[2] = love.physics.newPolygonShape( 24,640, 24,672, 352,672, 352,640)
	wallshapes[3] = love.physics.newPolygonShape( -8,-96, 384,-96, 384,-64, -8,-64)
	
	wallfixtures[0] = love.physics.newFixture(wallbodies, wallshapes[0])
	wallfixtures[0]:setUserData("left")
	wallfixtures[0]:setFriction(0.00001)
	
	wallfixtures[1] = love.physics.newFixture(wallbodies, wallshapes[1])
	wallfixtures[1]:setUserData("right")
	wallfixtures[1]:setFriction(0.00001)
	
	wallfixtures[2] = love.physics.newFixture(wallbodies, wallshapes[2])
	wallfixtures[2]:setUserData("ground")
	
	wallfixtures[3] = love.physics.newFixture(wallbodies, wallshapes[3])
	wallfixtures[3]:setUserData("ceiling")
	
	world:setCallbacks(collideB)
	-----------
	
	--FIRST "nextpiece"-
	nextpiece = 1--math.random(7)
	
	game_addTetriB()
	----------------
end

function game_addTetriB()
	--NEW BLOCK--
	randomblock = nextpiece
	createtetriB(randomblock, 1, 224, blockstartY)
	tetribodies[1]:setLinearVelocity(0, difficulty_speed)
	
	--RANDOMIZE
	nextpiece = math.random(7)
end

function createtetriB(i, uniqueid, x, y)

	tetriimages[uniqueid] = newPaddedImage( "graphics/pieces/"..i..".png", scale )
	tetrikind[uniqueid] = i
	tetrifixtures[uniqueid] = {}
	tetrishapes[uniqueid] = {}
	
	if i == 1 then --I
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, "dynamic")
		
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape(-48,0, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape(-16,0, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape(16,0, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape(48,0, 32, 32)
		
		tetrifixtures[uniqueid][1] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][1], density)
		tetrifixtures[uniqueid][2] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][2], density)
		tetrifixtures[uniqueid][3] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][3], density)
		tetrifixtures[uniqueid][4] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][4], density)
		
	elseif i == 2 then --J
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, "dynamic")
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape(-32,-16, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape(0,-16, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape(32,-16, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape(32,16, 32, 32)
		
		tetrifixtures[uniqueid][1] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][1], density)
		tetrifixtures[uniqueid][2] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][2], density)
		tetrifixtures[uniqueid][3] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][3], density)
		tetrifixtures[uniqueid][4] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][4], density)
		
	elseif i == 3 then --L
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, "dynamic")
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape(-32,-16, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape(0,-16, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape(32,-16, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape(-32,16, 32, 32)
		
		tetrifixtures[uniqueid][1] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][1], density)
		tetrifixtures[uniqueid][2] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][2], density)
		tetrifixtures[uniqueid][3] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][3], density)
		tetrifixtures[uniqueid][4] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][4], density)
		
	elseif i == 4 then --O
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, "dynamic")
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape(-16,-16, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape(-16,16, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape(16,16, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape(16,-16, 32, 32)
		
		tetrifixtures[uniqueid][1] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][1], density)
		tetrifixtures[uniqueid][2] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][2], density)
		tetrifixtures[uniqueid][3] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][3], density)
		tetrifixtures[uniqueid][4] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][4], density)
		
	elseif i == 5 then --S
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, "dynamic")
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape(-32,16, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape(0,-16, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape(32,-16, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape(0,16, 32, 32)
		
		tetrifixtures[uniqueid][1] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][1], density)
		tetrifixtures[uniqueid][2] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][2], density)
		tetrifixtures[uniqueid][3] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][3], density)
		tetrifixtures[uniqueid][4] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][4], density)
		
	elseif i == 6 then --T
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, "dynamic")
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape(-32,-16, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape(0,-16, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape(32,-16, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape(0,16, 32, 32)
		
		tetrifixtures[uniqueid][1] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][1], density)
		tetrifixtures[uniqueid][2] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][2], density)
		tetrifixtures[uniqueid][3] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][3], density)
		tetrifixtures[uniqueid][4] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][4], density)
		
	elseif i == 7 then --Z
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, "dynamic")
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape(0,16, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape(0,-16, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape(32,16, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape(-32,-16, 32, 32)
		
		tetrifixtures[uniqueid][1] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][1], density)
		tetrifixtures[uniqueid][2] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][2], density)
		tetrifixtures[uniqueid][3] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][3], density)
		tetrifixtures[uniqueid][4] = love.physics.newFixture(tetribodies[uniqueid], tetrishapes[uniqueid][4], density)

	end
	
	tetribodies[uniqueid]:setLinearDamping(0.5)
	tetribodies[uniqueid]:setBullet(true)
	
	for i, v in pairs(tetrifixtures[uniqueid]) do
		v:setUserData(uniqueid)
	end
end

function gameB_draw()
	--FULLSCREEN OFFSET
	if fullscreen then
		love.graphics.translate(fullscreenoffsetX, fullscreenoffsetY)
		
		--scissor
		love.graphics.setScissor(fullscreenoffsetX, fullscreenoffsetY, 160*scale, 144*scale)
	end
	
	--background--
	love.graphics.draw(gamebackground, 0, 0, 0, scale)
	---------------
	--tetrifixtures--
	for i,v in pairs(tetribodies) do
		if pause == false then
			love.graphics.draw( tetriimages[i], v:getX()*physicsscale, v:getY()*physicsscale, v:getAngle(), 1, 1, piececenter[tetrikind[i]][1]*scale, piececenter[tetrikind[i]][2]*scale)
		end
	end
	
	--Next piece
	if pause == false then
		love.graphics.draw(nextpieceimg[nextpiece], 136*scale, 120*scale, nextpiecerot, 1, 1, piececenterpreview[nextpiece][1]*scale, piececenterpreview[nextpiece][2]*scale)
	end
	----------------
	--start--
	if pause == true then
		love.graphics.draw(pausegraphic, 16*scale, 0, 0, scale)
	end
	---------
	
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
	
	love.graphics.setColor(255, 0, 0)

	--DEBUG--
	
		for i,v in pairs(tetribodies) do
			x, y = v:getWorldCenter( )
			love.graphics.point(x, y)
			for k,l in pairs(tetrishapes[i]) do
				points = {l:getPoints()}
				for j = 1, #points, 2 do
					points[j] = points[j] + x
					points[j+1] = points[j+1] + y
				end
				
				love.graphics.polygon("line",unpack(points))
			end
		end
	
	love.graphics.setColor(255, 255, 255)
	
	--FULLSCREEN OFFSET
	if fullscreen then
		love.graphics.translate(-fullscreenoffsetX, -fullscreenoffsetY)
		
		--scissor
		love.graphics.setScissor()
	end
	
end
	
function gameB_update(dt)
	if newblock then
		game_addTetriB()
		newblock = false
	end

	--NEXTPIECE ROTATION (rotating allday erryday)
	nextpiecerot = nextpiecerot + nextpiecerotspeed*dt
	while nextpiecerot > math.pi*2 do
		nextpiecerot = nextpiecerot - math.pi*2
	end

	if gamestate == "gameB" then
		if love.keyboard.isDown( "x" ) then
			if tetribodies[1]:getAngularVelocity() < 3 then
				tetribodies[1]:applyTorque( 70 )
			end
		end
		if love.keyboard.isDown( "y" ) or love.keyboard.isDown( "z" ) or love.keyboard.isDown( "w" ) then
			if tetribodies[1]:getAngularVelocity() > -3 then
				tetribodies[1]:applyTorque( -70 )
			end
		end
	
		if love.keyboard.isDown( "left" ) then
			local x, y = tetribodies[1]:getWorldCenter()
			tetribodies[1]:applyForce( -70, 0, x, y )
		end
		if love.keyboard.isDown( "right" ) then
			local x, y = tetribodies[1]:getWorldCenter()
			tetribodies[1]:applyForce( 70, 0, x, y )
		end
		
		local x, y = tetribodies[1]:getLinearVelocity( )
		if love.keyboard.isDown( "down" ) then
			--commented part limits the blackfallspeed
			if y > difficulty_speed*5 then
				tetribodies[1]:setLinearVelocity(x, difficulty_speed*5)
			else
				local cx, cy = tetribodies[1]:getWorldCenter()
				tetribodies[1]:applyForce( 0, 20, cx, cy )
			end
		else
			if y > difficulty_speed then
				tetribodies[1]:setLinearVelocity(x, y-2000*dt)
			end
		end
	end
	
	world:update(dt)
	
	if gamestate == "failingB" then
		clearcheck = true
		for i,v in pairs(tetribodies) do
			if v:getY() < 648 then
				clearcheck = false
			end
		end
		
		if clearcheck then
			failed_load()
		end
	end
end

function collideB(a, b)
	a, b = a:getUserData(), b:getUserData()
	if a == 1 or b == 1 then
		if a ~= "left" and a ~= "right" and b ~= "left" and b ~= "right" then 
			if gamestate == "gameB" then
				endblockB()
			end
		end
	end
end

function endblockB()
	if tetribodies[1]:getY() < losingY then
		--LOSE--
		gamestate = "failingB"
		if musicno < 4 then
			love.audio.stop(music[musicno])
		end
		love.audio.stop(gameover1)
		love.audio.play(gameover1)
	
		wallshapes[2]:destroy()
		wallshapes[2] = nil
	else
		--Transfer block from 1 to end of tetribodies
		tetrikind[highestbody()+1] = tetrikind[1]
		
		tetriimages[highestbody()+1] = tetriimages[1]
		tetribodies[highestbody()+1] = tetribodies[1]
		
		tetrifixtures[highestbody()] = {}
		tetrishapes[highestbody()] = {}
		
		for i, v in pairs(tetrifixtures[1]) do
			tetrishapes[highestbody()][i] = tetrishapes[1][i]
			tetrishapes[1][i] = nil
			
			tetrifixtures[highestbody()][i] = tetrifixtures[1][i]
			tetrifixtures[highestbody()][i]:setUserData({highestbody()})
			tetrifixtures[1][i] = nil
		end
		
		tetribodies[1] = nil
		---------------------------
		linesscore = linesscore + 1
		scorescore = linesscore * 100
		
		love.audio.stop(blockfall)
		love.audio.play(blockfall)
		
		newblock = true
	end
end