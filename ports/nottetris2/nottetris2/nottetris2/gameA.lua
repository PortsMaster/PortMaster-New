function gameA_load()
	gamestate = "gameA"
	
	pause = false
	skipupdate = true
	
	difficulty_speed = 100

	cuttingtimer = lineclearduration
	
	scorescore = 0
	levelscore = 0
	linesscore = 0
	
	linescleared = 0
	lastscoreadd = 0
	scoreaddtimer = scoreaddtime
	densityupdatetimer = 0
	nextpiecerot = 0
	newlevelbeep = false
	
	--PHYSICS--
	meter = 30
	world = love.physics.newWorld(0, -720, 960, 1200, 0, 500, true )
	
	tetrikind = {}
	wallshapes = {}
	tetrishapes = {}
	tetribodies = {}
	offsetshapes = {}
	tetrishapescopy = {}
	data = {}
	
	wallbodies = love.physics.newBody(world, 32, -64, 0, 0) --WALLS
	wallshapes[0] = love.physics.newPolygonShape( wallbodies,-8, -64, -8,672, 24,672, 24,-64)
	wallshapes[0]:setData({"left"})
	wallshapes[0]:setFriction(0.00001)
	wallshapes[1] = love.physics.newPolygonShape( wallbodies,352,-64, 352,672, 384,672, 384,-64)
	wallshapes[1]:setData({"right"})
	wallshapes[1]:setFriction(0.00001)
	wallshapes[2] = love.physics.newPolygonShape( wallbodies,24,640, 24,672, 352,672, 352,640)
	wallshapes[2]:setData({"ground"})
	wallshapes[3] = love.physics.newPolygonShape( wallbodies,-8,-96, 384,-96, 384,-64, -8,-64)
	wallshapes[3]:setData({"ceiling"})
	
	world:setCallbacks(collideA)
	-----------
	
	--FIRST "nextpiece"-
	nextpiece = math.random(7)
	
	checklinedensity(false)
	game_addTetriA()
	nextpiece = math.random(7)
	----------------
end

function game_addTetriA() --creates new block (using createtetriA) at 1 and sets its velocity
	--NEW BLOCK--
	randomblock = nextpiece
	createtetriA(randomblock, 1, 224, blockstartY)
	tetribodies[1]:setLinearVelocity(0, difficulty_speed)
end	

function createtetriA(i, uniqueid, x, y) --creates block, including body, shapes, image, imagedata and whatnot.

	tetriimagedata[uniqueid] = newImageData( "graphics/pieces/"..i..".png", scale)
	tetriimages[uniqueid] = padImagedata( tetriimagedata[uniqueid] )
	tetrikind[uniqueid] = i
	tetrishapes[uniqueid] = {}
	
	if i == 1 then --I
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, 0, blockrot)
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape( tetribodies[uniqueid], -48,0, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape( tetribodies[uniqueid], -16,0, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape( tetribodies[uniqueid], 16,0, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape( tetribodies[uniqueid], 48,0, 32, 32)
		
	elseif i == 2 then --J
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, 0, blockrot)
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape( tetribodies[uniqueid], -32,-16, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape( tetribodies[uniqueid], 0,-16, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape( tetribodies[uniqueid], 32,-16, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape( tetribodies[uniqueid], 32,16, 32, 32)
		
	elseif i == 3 then --L
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, 0, blockrot)
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape( tetribodies[uniqueid], -32,-16, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape( tetribodies[uniqueid], 0,-16, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape( tetribodies[uniqueid], 32,-16, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape( tetribodies[uniqueid], -32,16, 32, 32)
		
	elseif i == 4 then --O
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, 0, blockrot)
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape( tetribodies[uniqueid], -16,-16, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape( tetribodies[uniqueid], -16,16, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape( tetribodies[uniqueid], 16,16, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape( tetribodies[uniqueid], 16,-16, 32, 32)
		
	elseif i == 5 then --S
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, 0, blockrot)
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape( tetribodies[uniqueid], -32,16, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape( tetribodies[uniqueid], 0,-16, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape( tetribodies[uniqueid], 32,-16, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape( tetribodies[uniqueid], 0,16, 32, 32)
		
	elseif i == 6 then --T
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, 0, blockrot)
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape( tetribodies[uniqueid], -32,-16, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape( tetribodies[uniqueid], 0,-16, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape( tetribodies[uniqueid], 32,-16, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape( tetribodies[uniqueid], 0,16, 32, 32)
		
	elseif i == 7 then --Z
		tetribodies[uniqueid] = love.physics.newBody(world, x, y, 0, blockrot)
		tetrishapes[uniqueid][1] = love.physics.newRectangleShape( tetribodies[uniqueid], 0,16, 32, 32)
		tetrishapes[uniqueid][2] = love.physics.newRectangleShape( tetribodies[uniqueid], 0,-16, 32, 32)
		tetrishapes[uniqueid][3] = love.physics.newRectangleShape( tetribodies[uniqueid], 32,16, 32, 32)
		tetrishapes[uniqueid][4] = love.physics.newRectangleShape( tetribodies[uniqueid], -32,-16, 32, 32)

	end
	
	tetribodies[uniqueid]:setLinearDamping(0.5)
	tetribodies[uniqueid]:setMassFromShapes()
	tetribodies[uniqueid]:setBullet(true)
	
	for i, v in pairs(tetrishapes[uniqueid]) do
		v:setData({1})
	end
end

function gameA_draw()
	--FULLSCREEN OFFSET
	if fullscreen then
		love.graphics.translate(fullscreenoffsetX, fullscreenoffsetY)
		
		--scissor
		love.graphics.setScissor(fullscreenoffsetX, fullscreenoffsetY, 160*scale, 144*scale)
	end
	
	--background--
	love.graphics.draw(gamebackgroundcutoff, 0, 0, 0, scale, scale)
	---------------
	--tetrishapes--
	if cuttingtimer == lineclearduration then
		for i,v in pairs(tetribodies) do
			if pause == false then
				love.graphics.draw( tetriimages[i], v:getX()*physicsscale, v:getY()*physicsscale, v:getAngle(), 1, 1, piececenter[tetrikind[i]][1]*scale, piececenter[tetrikind[i]][2]*scale)
			end
		end
	else
		for i = 1, #tetricutimg do
			if pause == false then
				love.graphics.draw( tetricutimg[i], tetricutpos[i*2-1]*physicsscale, tetricutpos[i*2]*physicsscale, tetricutang[i], 1, 1, piececenter[tetricutkind[i]][1]*scale, piececenter[tetricutkind[i]][2]*scale)
			end
		end
		
		--blinky lines
		
		local section = math.ceil(cuttingtimer/(lineclearduration/lineclearblinks))
		if math.mod(section, 2) == 1 or cuttingtimer == 0 then
		
			local rr, rg, rb = unpack(getrainbowcolor(hue))
			local r = 145 + rr*64
			local g = 145 + rg*64
			local b = 145 + rb*64
			
			for i = 1, 18 do
				if linesremoved[i] == true then
					love.graphics.setColor(r, g, b)
					
					love.graphics.rectangle("fill", 14*scale, (i-1)*8*scale, 82*scale, 8*scale)
				end
			end
		end
	end
	
	love.graphics.setColor(255, 255, 255)
	--Next piece
	if pause == false then
		love.graphics.draw(nextpieceimg[nextpiece], 136*scale, 120*scale, nextpiecerot, 1, 1, piececenterpreview[nextpiece][1]*scale, piececenterpreview[nextpiece][2]*scale)
	end
	
	----------------
	--Last score
	if scoreaddtimer < scoreaddtime then
		if fullscreen then
			love.graphics.setScissor(105*scale+fullscreenoffsetX, 35*scale+fullscreenoffsetY, 55*scale, 9*scale)
		else
			love.graphics.setScissor(105*scale, 35*scale, 55*scale, 9*scale)
		end
		
		love.graphics.setFont(whitefont)
		
		local offsetX = 0
		for i = 1, tostring(lastscoreadd):len() - 1 do
			offsetX = offsetX -	8*scale
		end
		
		love.graphics.print("+" .. lastscoreadd, 136*scale+offsetX, 36*scale-scoreaddtimer/scoreaddtime*8*scale, 0, scale)
		
		love.graphics.setFont(tetrisfont)	
		
		if fullscreen then
			love.graphics.setScissor(fullscreenoffsetX, fullscreenoffsetY, 160*scale, 144*scale)
		else
			love.graphics.setScissor()
		end
	end
	
	
	--line density counter
	for i = 1, 18 do
		local fullness = linearea[i]/1024/linecleartreshold
		if fullness > 1 then
			fullness = 1
		end
		
		local color
		if fullness == 1 then
			color = 0
		else
			color = 235-(fullness/1)*180
		end
		
		love.graphics.setColor(color, color, color)
		love.graphics.rectangle("fill", 0, (i-1)*8*scale, math.floor(6*scale*fullness), 8*scale)
	end
	
	love.graphics.setColor(255, 255, 255)
	
	---------
	--start--
	if pause == true then
		love.graphics.draw(pausegraphiccutoff, 14*scale, 0, 0, scale, scale)
	end
	---------
	
	--SCORES---------------------------------------
	--"score"--
	offsetX = 0
	
	scorestring = tostring(scorescore)
	for i = 1, scorestring:len() - 1 do
		offsetX = offsetX - 8*scale
	end
	love.graphics.print( scorescore, 144*scale + offsetX, 24*scale, 0, scale, scale)
	
	
	--"level"--
	offsetX = 0
	
	scorestring = tostring(levelscore)
	for i = 1, scorestring:len() - 1 do
		offsetX = offsetX - 8*scale
	end
	love.graphics.print( levelscore, 136*scale + offsetX, 56*scale, 0, scale, scale)
	
	--"tiles"--
	offsetX = 0
	
	scorestring = tostring(linesscore)
	for i = 1, scorestring:len() - 1 do
		offsetX = offsetX - 8*scale
	end
	love.graphics.print( linesscore, 136*scale + offsetX, 80*scale, 0, scale, scale)
	-----------------------------------------------
	
	
	--FULLSCREEN OFFSET
	if fullscreen then
		love.graphics.translate(-fullscreenoffsetX, -fullscreenoffsetY)
		
		--scissor
		love.graphics.setScissor()
	end
end

function gameA_update(dt)
	--NEXTPIECE ROTATION (rotating allday erryday)
	if cuttingtimer == lineclearduration then
		nextpiecerot = nextpiecerot + nextpiecerotspeed*dt
		while nextpiecerot > math.pi*2 do
			nextpiecerot = nextpiecerot - math.pi*2
		end
	end
	
	--CUTTING TIMER
	if cuttingtimer < lineclearduration then
		cuttingtimer = cuttingtimer + dt
		if cuttingtimer >= lineclearduration then
			--RANDOMIZE NEXT PIECE
			nextpiece = math.random(7)
			
			cuttingtimer = lineclearduration
			skipupdate = true
			scoreaddtimer = 0
		
			if newlevelbeep then
				love.audio.stop(newlevel)
				love.audio.play(newlevel)
				newlevelbeep = false
			end
		end
		return
	end
	
	--SCOREADD TIMER
	if cuttingtimer == lineclearduration then
		if scoreaddtimer < scoreaddtime then
			scoreaddtimer = scoreaddtimer + dt
			if scoreaddtimer > scoreaddtime then
				scoreaddtimer = scoreaddtime
			end
		end
	end
		
	if gamestate == "gameA" then
		if controls.isDown("rotateright") then
			if tetribodies[1]:getAngularVelocity() < 3 then
				tetribodies[1]:applyTorque( 70 )
			end
		end
		if controls.isDown("rotateleft") then
			if tetribodies[1]:getAngularVelocity() > -3 then
				tetribodies[1]:applyTorque( -70 )
			end
		end
	
		if controls.isDown( "left" ) then
			local x, y = tetribodies[1]:getWorldCenter()
			tetribodies[1]:applyForce( -70, 0, x, y )
		end
		if controls.isDown( "right" ) then
			local x, y = tetribodies[1]:getWorldCenter()
			tetribodies[1]:applyForce( 70, 0, x, y )
		end
		
		local x, y = tetribodies[1]:getLinearVelocity( )
		if controls.isDown( "down" ) then
			--commented part limits the blackfallspeed
			if y > 500 then
				tetribodies[1]:setLinearVelocity(x, 500)
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
	
	endblock = false

	world:update(dt)

	if endblock then
		endblockA()
	end

	
	--DENSITY UPDATE TIMER
	if densityupdatetimer >= densityupdateinterval then
		while densityupdatetimer >= densityupdateinterval and cuttingtimer == lineclearduration do
			checklinedensity(false)
			densityupdatetimer = densityupdatetimer - densityupdateinterval
		end
	end
	densityupdatetimer = densityupdatetimer + dt
	
	if gamestate == "failingA" then
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

function getintersectX(shape, y) --returns left and right collision points to a certain shape on a Y coordinate (or -1, -0.9 if no collision)
	local lefttime = shape:testSegment( 55, y, 385, y)
	local righttime = shape:testSegment( 385, y, 55, y)
	if lefttime ~= nil and righttime ~= nil then
		local leftx = 330 * lefttime + 55
		local rightx = 385 - 330 * righttime
		return leftx, rightx
	else
		return -1, -0.9
	end
end

function removeline(lineno) --Does all necessary things to clear a line. Refineshape and cutimage included.
	upperline = (lineno - 1) * 32
	lowerline = lineno * 32
	globaline = lineno
	coordinateproperties = {}
	numberofbodies = highestbody()
	local ioffset = 0
	tetribodies[1] = "dummy :D"
	for i = 2, numberofbodies do --every body
		v = tetribodies[i-ioffset]
		if i-ioffset > numberofbodies then
			print("oh yeah")
			break
		end
		if i-ioffset > 1 then
			refined = false
			coordinateproperties[i-ioffset] = {}
			tetrishapescopy = {}
			
			upperleftx = 640
			lowerleftx = 640
			
			upperrightx = 0
			lowerrightx = 0
			for j, w in pairs(tetrishapes[i-ioffset]) do
				x1, x2 = getintersectX(tetrishapes[i-ioffset][j], upperline)
				
				if x1 < upperleftx and x1 ~= -1 then
					upperleftx = x1
				end
				if x2 > upperrightx then
					upperrightx = x2
				end
				
				x1, x2 = getintersectX(tetrishapes[i-ioffset][j], lowerline)
				
				if x1 < lowerleftx and x1 ~= -1 then
					lowerleftx = x1
				end
				if x2 > lowerrightx then
					lowerrightx = x2
				end
			end
			
			for j, w in pairs(tetrishapes[i-ioffset]) do --Every shape
				above = false
				inside = false
				below = false
				coordinateproperties[i-ioffset][j] = {}
				coordinates = getPoints2table(w)
				
				for y = 1, #coordinates, 2 do --Every Point
					if coordinates[y+1] < upperline then --POINT ABOVE CUTRECT
						coordinateproperties[i-ioffset][j][math.ceil(y/2)] = 1
						above = true
					elseif coordinates[y+1] >= upperline and coordinates[y+1] <= lowerline then --POINT INSIDE CUTRECT!
						coordinateproperties[i-ioffset][j][math.ceil(y/2)] = 2
						inside = true
					elseif coordinates[y+1] > lowerline then --POINT BELOW CUTRECT
						coordinateproperties[i-ioffset][j][math.ceil(y/2)] = 3
						below = true
					end
				end
				if above == true and inside == true and below == false then
					tetrishapescopy[#tetrishapescopy+1]=refineshape(upperline, 1, i-ioffset, v, j, w)
					refined = true
				elseif above == true and inside == true and below == true then
					tetrishapescopy[#tetrishapescopy+1]=refineshape(upperline, 1, i-ioffset, v, j, w)
					tetrishapescopy[#tetrishapescopy+1]=refineshape(lowerline, -1, i-ioffset, v, j, w)
					refined = true
				elseif above == false and inside == true and below == false then
					--nothing because it'll get removed (don't delete the elseif though cause it'll go though the "else")
					refined = true
				elseif above == false and inside == true and below == true then
					tetrishapescopy[#tetrishapescopy+1]=refineshape(lowerline, -1, i-ioffset, v, j, w)
					refined = true
				elseif above == true and inside == false and below == true then
					tetrishapescopy[#tetrishapescopy+1]=refineshape(upperline, 1, i-ioffset, v, j, w)
					tetrishapescopy[#tetrishapescopy+1]=refineshape(lowerline, -1, i-ioffset, v, j, w)
					refined = true
				else
					cotable = getPoints2table(tetrishapes[i-ioffset][j])
					for var = 1, #cotable, 2 do
						cotable[var], cotable[var+1] = tetribodies[i-ioffset]:getLocalPoint(cotable[var], cotable[var+1])
					end
					tetrishapescopy[#tetrishapescopy+1] = love.physics.newPolygonShape(tetribodies[i-ioffset], unpack(cotable))
				end
			end
			if refined == true then
			
			--create for either above our below; or both if body is cut in center.
			--gotta set the bodyids here and reuse them in the "check for disconnect shapes" further down
			for a, b in pairs(tetrishapes[i-ioffset]) do --remove all shapes
				if tetrishapes[i-ioffset][a] then
					tetrishapes[i-ioffset][a]:destroy()
					tetrishapes[i-ioffset][a] = nil
				end
			end
			
			tetrishapes[i-ioffset] = {}
			
			if #tetrishapescopy == 0 then --body empty
				if tetribodies[i-ioffset] then
					tetribodies[i-ioffset]:destroy()
					table.remove(tetribodies, i-ioffset)
					table.remove(tetrishapes, i-ioffset)
					table.remove(tetrikind, i-ioffset)
					table.remove(tetriimages, i-ioffset)
					table.remove(tetriimagedata, i-ioffset)
					numberofbodies = numberofbodies - 1
					ioffset = ioffset + 1
				end
			else
				
				----check for disconnected shapes
				--apply group numbers to shapes then loop through each existing value, creating a new body for everything > 1 (max should be 3 I think).
				shapegroups = {}
				numberofgroups = 0
				for a, b in pairs(tetrishapescopy) do --through all shapes
					shapegroups[a] = 0
					currentcoords = getPoints2table(b)
					for shapecounter = 1, a - 1 do --Through all previously set groups
						coords = getPoints2table(tetrishapescopy[shapecounter])
						for currentcoordsvar = 1, #currentcoords/2 do --through all coords in the current shape
							for coordsvar = 1, #coords/2 do --through all coords in all previously set groups (Holy shit 6 stacked "for" loops; I code like an asshole!)
								if math.abs(currentcoords[currentcoordsvar*2-1] - coords[coordsvar*2-1]) < 2 and math.abs(currentcoords[currentcoordsvar*2] - coords[coordsvar*2]) < 2 then
									shapegroups[a] = shapegroups[shapecounter]
								end
							end
						end
					end
					
					if shapegroups[a] == 0 then --create new group
						numberofgroups = numberofgroups + 1
						shapegroups[a] = numberofgroups
					end
				end
				
				--All shapes have now an assigned group number in "shapegroups[shape] = groupnumber" :) yay.
				
				for a = 1, numberofgroups do
					if a == 1 then --reassign the old bodyid
						rotation = tetribodies[i-ioffset]:getAngle()
						tetribodies[i-ioffset]:destroy()
						tetribodies[i-ioffset] = love.physics.newBody(world, tetribodies[i-ioffset]:getX(), tetribodies[i-ioffset]:getY(), tetribodies[i-ioffset]:getMass(), blockrot)
						tetribodies[i-ioffset]:setAngle(rotation)
						tetrishapes[i-ioffset] = {}
						for b, c in pairs(tetrishapescopy) do
							if shapegroups[b] == a then
								cotable = getPoints2table(tetrishapescopy[b])
								for var = 1, #cotable, 2 do
									cotable[var], cotable[var+1] = tetribodies[i-ioffset]:getLocalPoint(cotable[var], cotable[var+1])
								end
								tetrishapes[i-ioffset][#tetrishapes[i-ioffset]+1] = love.physics.newPolygonShape(tetribodies[i-ioffset], unpack(cotable))
								tetrishapes[i-ioffset][#tetrishapes[i-ioffset]]:setData({i-ioffset}) --set the shape name for collision
							end
						end
						
						--save old imagedata to local var first in case we create a new bodyid..
						backupimagedata = love.image.newImageData( tetriimagedata[i-ioffset]:getWidth(), tetriimagedata[i-ioffset]:getHeight())
						backupimagedata:paste(tetriimagedata[i-ioffset], 0, 0, 0, 0, tetriimagedata[i-ioffset]:getWidth(), tetriimagedata[i-ioffset]:getHeight() )
						
						--cut the image.
						cutimage(i-ioffset, numberofgroups)
						
						--mass confusion
						tetribodies[i-ioffset]:setMassFromShapes()
						
						local mass = tetribodies[i-ioffset]:getMass()
						if mass < minmass then
							for i, v in pairs(tetrishapes[i-ioffset]) do
								v:setDensity( minmass/mass )
							end
							
							tetribodies[i-ioffset]:setMassFromShapes()
							
							for i, v in pairs(tetrishapes[i-ioffset]) do
								v:setDensity( 1 )
							end
						end
						
					else --create new bodyid
						tetribodies[highestbody()+1] = love.physics.newBody(world, tetribodies[i-ioffset]:getX(), tetribodies[i-ioffset]:getY(), tetribodies[i-ioffset]:getMass(), blockrot)
						tetribodies[highestbody()]:setAngle(tetribodies[i-ioffset]:getAngle())
						tetrishapes[highestbody()] = {}
						
						for b, c in pairs(tetrishapescopy) do
							if shapegroups[b] == a then
								cotable = getPoints2table(tetrishapescopy[b])
								for var = 1, #cotable, 2 do
									cotable[var], cotable[var+1] = tetribodies[i-ioffset]:getLocalPoint(cotable[var], cotable[var+1])
								end
								tetrishapes[highestbody()][#tetrishapes[highestbody()]+1] = love.physics.newPolygonShape(tetribodies[highestbody()], unpack(cotable))
								tetrishapes[highestbody()][#tetrishapes[highestbody()]]:setData({highestbody()}) --set the shape name for collision
							end
						end
						
						linearspeedX, linearspeedY = tetribodies[i-ioffset]:getLinearVelocity()
						tetribodies[highestbody()]:setLinearVelocity(linearspeedX, linearspeedY)
						tetribodies[highestbody()]:setLinearDamping(0.5)
						tetribodies[highestbody()]:setBullet(true)
						tetribodies[highestbody()]:setAngularVelocity(tetribodies[i-ioffset]:getAngularVelocity())
						
						tetriimagedata[highestbody()] = love.image.newImageData( backupimagedata:getWidth(), backupimagedata:getHeight())
						tetriimagedata[highestbody()]:paste( backupimagedata, 0, 0, 0, 0, backupimagedata:getWidth(), backupimagedata:getHeight() )
						tetriimages[highestbody()] = padImagedata( tetriimagedata[highestbody()] )
						tetrikind[highestbody()] = tetrikind[i-ioffset]
						
						debugimagedata = love.image.newImageData( backupimagedata:getWidth(), backupimagedata:getHeight())
						debugimagedata:paste(backupimagedata, 0, 0, 0, 0, backupimagedata:getWidth(), backupimagedata:getHeight() )
						debugimage = padImagedata( debugimagedata )
						
						--cut the image
						cutimage(highestbody(), numberofgroups)
						
						--mass confusion
						tetribodies[highestbody()]:setMassFromShapes()
						
						local mass = tetribodies[highestbody()]:getMass()
						if mass < minmass then
							for i, v in pairs(tetrishapes[highestbody()]) do
								v:setDensity( minmass/mass )
							end
							
							tetribodies[highestbody()]:setMassFromShapes()
							
							for i, v in pairs(tetrishapes[highestbody()]) do
								v:setDensity( 1 )
							end
						end
					end
				end		
			end --if body empty
			end --if refined
			
			--clean up the tables..
			for a, b in pairs(tetrishapescopy) do
				if tetrishapescopy[a] then
					tetrishapescopy[a]:destroy()
					tetrishapescopy[a] = nil
				end
			end
			
			tetrishapescopy = {}
		end --if i-ioffset > 1
	end
end

function cutimage(bodyid, numberofgroups) --cuts the image of a body based on its shapes (2nd argument might be obsolete)
	
	local width = tetriimagedata[bodyid]:getWidth()
	local height = tetriimagedata[bodyid]:getHeight()
	
	--[[ This old method used the angle between the two cutting points and all the other points to determine if the point should be removed. 
		 But it sometimes bugged out for reasons I couldn't figure out so I'm going for the less good looking easy approach. Boo :(
	
	local bodyang = tetribodies[bodyid]:getAngle()
	bodyang = math.mod(bodyang, math.pi)
	
	local highestx = -1
	local lowestx = 160*scale
	for i, v in pairs(tetrishapes[bodyid]) do
		x1, x2 = getintersectX(v, upperline-0.01)
		if x1 < lowestx and x1 ~= -1 then
			lowestx = x1
		end
		if x2 > highestx thena
			highestx = x2
		end
	end
	
	--get if to chose lower or upper line
	local posy = getPoints2table(tetrishapes[bodyid][1])
	posy = posy[2]
	
	if posy > (upperline + lowerline) / 2 then
		line = lowerline
	else
		line = upperline
	end
	
	--convert points to local coordinates
	local dummy1, dummy2 = tetribodies[bodyid]:getLocalPoint( lowestx, line )
	dummy1, dummy2 = dummy1 + width/2, dummy2 + height/2
	local point1 = {dummy1, dummy2}
	
	local dummy1, dummy2 = tetribodies[bodyid]:getLocalPoint( highestx, line )
	dummy1, dummy2 = dummy1 + width/2, dummy2 + height/2
	local point2 = {dummy1, dummy2}	
	
	local leftlimit = 160*scale
	local rightlimit = -1
	
	--find out the limits of there's more than 1 body being created
	if numberofgroups > 1 then
		for s = 1, #tetrishapes[bodyid] do
			local cotable = getPoints2table(tetrishapes[bodyid][s])
			for i = 1, #cotable, 2 do
				local x, y = tetribodies[bodyid]:getLocalPoint(cotable[i], cotable[i+1])
				x = x+width/2
				if x < leftlimit then
					leftlimit = x
				elseif x > rightlimit then
					rightlimit = x
				end
			end
		end
	else 
		leftlimit = -1
		rightlimit = 160*scale
	end
	
	local ang = math.atan2(point2[1] - point1[1], point2[2] - point1[2])
	ang = -ang + math.pi]]--
	
	for y = 0, height-1 do
		for x = 0, width-1 do
		--[[local ang2 = math.atan2(x - point1[1], y - point1[2]) --PART OF OLD METHOD
			ang2 = -ang2 + math.pi
			
			if (ang2 > ang and ang2 < ang + math.pi) or ang2 < ang - math.pi or (x < leftlimit or x > rightlimit) then
				tetriimagedata[bodyid]:setPixel(x, y, 255, 255, 255, 0)
			end]]
			
			local dummy1, dummy2 = tetribodies[bodyid]:getWorldPoint((x-width/2+.5)*(4/scale), (y-height/2+.5)*(4/scale))
			local deletepixel = true
			
			for i, v in pairs(tetrishapes[bodyid]) do
				if v:testPoint( dummy1, dummy2 ) then
					deletepixel = false
					break
				end
			end
			
			if deletepixel then
				tetriimagedata[bodyid]:setPixel(x, y, 255, 255, 255, 0)
			end
		end
	end
	
	tetriimages[bodyid] = padImagedata( tetriimagedata[bodyid] )
end

function refineshape(line, mult, bodyid, body, shapeid, shape) --refines a shape using the old coordinates and the cutting line
	local leftx, rightx = getintersectX(tetrishapes[bodyid][shapeid], line)
	if leftx ~= -1 then --Not sure what to do if not
		local coords = getPoints2table(tetrishapes[bodyid][shapeid])
		
		--remove all points inside the cutting zone
		local lastcutoff
		local i=2
		while i <= #coords do
			if coords[i]*mult > line*mult then
				table.remove(coords, i)
				table.remove(coords, i-1)
				lastcutoff = i
				i=0
			end
			i=i+2
		end
		
		--add new points (Only if they aren't identical to existing points)
		if lastcutoff then
			if mult == 1 then
				if samepos(coords, line, leftx) == false then
					table.insert(coords, lastcutoff-1,leftx)
					table.insert(coords, lastcutoff,line)
				end
				
				if samepos(coords, line, rightx) == false then
					table.insert(coords, lastcutoff-1,rightx)
					table.insert(coords, lastcutoff,line)
				end
			else
				if samepos(coords, line, rightx) == false then
					table.insert(coords, lastcutoff-1,rightx)
					table.insert(coords, lastcutoff,line)
				end
				
				if samepos(coords, line, leftx) == false then
					table.insert(coords, lastcutoff-1,leftx)
					table.insert(coords, lastcutoff,line)
				end
			end
		end
		
		--create the new shape
		if #coords/2 >= 3 and #coords/2 <= 8 then --shape still has 3 or more points, and not over 8.
			if largeenough(coords) then
				local newcoords={}
				for i=1,#coords,2 do
					newcoords[i],newcoords[i+1] = body:getLocalPoint(coords[i], coords[i+1])
				end
				return love.physics.newPolygonShape(body, unpack(newcoords))
			end
		else
			print("#coords")
		end
	else
		local coords = getPoints2table(tetrishapes[bodyid][shapeid])
		local newcoords={}
		for i=1,#coords,2 do
			newcoords[i],newcoords[i+1] = body:getLocalPoint(coords[i], coords[i+1])
		end
		return love.physics.newPolygonShape(body, unpack(newcoords))
	end
end

function checklinedensity(active) --checks all 18 lines and, if active == true, calls removeline. Also does scoring, sounds and stuff.
	--loop through every shape and add each area to a nax
	
	linearea = {}
	
	for i = 1, 18 do
		linearea[i] = 0
	end
	
	for i = 2, #tetribodies do
		for j, k in pairs(tetrishapes[i]) do
			local coords = getPoints2table(k)
			--Get first and last involved line
			local firstline = 19
			local lastline =  0
			
			for point = 2, #coords, 2 do
				if math.ceil(round(coords[point]) / 32) < firstline then
					firstline = math.ceil(round(coords[point]) / 32)
				elseif math.ceil(round(coords[point]) / 32) > lastline then
					lastline = math.ceil(round(coords[point]) / 32)
				end
			end
			
			for line = firstline, lastline do
				if line >= 1 and line <= 18 then
					coords = getPoints2table(k)
					
					if line > firstline then
						local offset = 0
					
						repeat
							leftx, rightx = getintersectX(tetrishapes[i][j], (line-1)*32+offset)
							offset = offset + 1
						until leftx ~= -1 or offset >= 32
						
						--remove all points above the line
						local coi=2
						local lastcutoff = nil
						while coi <= #coords do
							if coords[coi] <= (line-1)*32 then
								table.remove(coords, coi)
								table.remove(coords, coi-1)
								lastcutoff = coi
								coi=0
							end
							coi=coi+2
						end
						
						--add points of top line (if points were cut off)
						if lastcutoff then
							table.insert(coords, lastcutoff-1,rightx)
							table.insert(coords, lastcutoff,(line-1)*32)
							
							table.insert(coords, lastcutoff-1,leftx)
							table.insert(coords, lastcutoff,(line-1)*32)
						end
					end
					
					if line < lastline then
						local offset = 0
						repeat
							leftx, rightx = getintersectX(tetrishapes[i][j], (line)*32 - offset)
							offset = offset + 1
						until leftx ~= -1 or offset >= 32
						
						--remove all points below the line
						local coi=2
						local lastcutoff = nil
						while coi <= #coords do
							if coords[coi] >= (line)*32 then
								table.remove(coords, coi)
								table.remove(coords, coi-1)
								lastcutoff = coi
								coi=0
							end
							coi=coi+2
						end
						
						--add points of bottom line (if points were cut off)
						if lastcutoff then
							table.insert(coords, lastcutoff-1,leftx)
							table.insert(coords, lastcutoff,(line)*32)
							
							table.insert(coords, lastcutoff-1,rightx)
							table.insert(coords, lastcutoff,(line)*32)
						end
					end
					
					linearea[line] = linearea[line] + polygonarea(coords)
				end
			end
		end
	end
	
	if active then
		local removedlines = false
		local numberoflines = 0
		linesremoved = {}
		
		for i = 1, 18 do
			if linearea[i] > 1024*linecleartreshold then
				if removedlines == false then
					cuttingtimer = 0
					removedlines = true
					
					--Save position, image, kind and image of each kind so I can draw them even after changing the actual parts.
					
					tetricutpos = {}
					tetricutang = {}
					tetricutkind = {}
					tetricutimg = {}
					
					for i, v in pairs(tetribodies) do -- = 2, #tetribodies do
						if tetribodies[i].getX then
							table.insert(tetricutpos, tetribodies[i]:getX())
							table.insert(tetricutpos, tetribodies[i]:getY())
							table.insert(tetricutang, tetribodies[i]:getAngle())
							table.insert(tetricutkind, tetrikind[i])
							table.insert(tetricutimg, padImagedata(tetriimagedata[i]))
						end
					end
					
					--[[for j, k in pairs(tetribodies) do --CANCEL ALL BLOCK MOVEMENT
						if k.setLinearVelocity then
							k:setLinearVelocity(0, 0)
							k:setAngularVelocity(0, 0)
						end
					end]]
				end
				
				linesremoved[i] = true
				numberoflines = numberoflines + 1
				linesscore = linesscore + 1
			end
		end
	
		if removedlines then
			if numberoflines >= 4 then
				love.audio.stop(fourlineclear)
				love.audio.play(fourlineclear)
			else
				love.audio.stop(lineclear)
				love.audio.play(lineclear)
			end
			
			--Possible scoring functions:
			-- (numberoflines^2*40)+(numberoflines*50)* averagearea^8 (mine)
			-- (NUMOFLINES*3)^(AREA^10)*20+NUMOFLINES^2*40 (murks)
			--old scoring
			--[[
			if numberoflines == 1 then
				scorescore = scorescore + 40
			elseif numberoflines == 2 then
				scorescore = scorescore + 100
			elseif numberoflines == 3 then
				scorescore = scorescore + 300
			elseif numberoflines == 4 then
				scorescore = scorescore + 800
			else
				scorescore = scorescore + numberoflines*300
			end
			]]
			
			--calculate average area
			local averagearea = 0
			for i = 1, 18 do
				if linesremoved[i] then
					averagearea = averagearea + linearea[i]
				end
			end
			averagearea = averagearea / numberoflines / 10240
			
			local scoreadd = math.ceil((numberoflines*3)^(averagearea^10)*20+numberoflines^2*40)
			scorescore = scorescore + scoreadd
			
			lastscoreadd = scoreadd
			scoreaddtimer = 0
			
			--Level
			linescleared = linescleared + numberoflines
			
			if math.floor(linescleared/10) > levelscore then
				levelscore = levelscore + 1
				difficulty_speed = 100 + levelscore*7
				newlevelbeep = true
			end
			
			--Draw the screen before removing lines.
			love.graphics.clear()
			gameA_draw()
			love.graphics.present( )
			
			for i = 1, 18 do
				if linesremoved[i] then
					removeline(i)
				end
			end
		else
			love.audio.stop(blockfall)
			love.audio.play(blockfall)
		end
		
		return removedlines
	end
end

function polygonarea(coords) --calculates the area of a polygon
	--Also written by Adam (see below)
	local anchorX = coords[1]
	local anchorY = coords[2]

	local firstX = coords[3]
	local firstY = coords[4]

	local area = 0

	for i = 5, #coords - 1, 2 do
		local x = coords[i]
		local y = coords[i + 1]

		area = area + (math.abs(anchorX * firstY + firstX * y + x * anchorY
				- anchorX * y - firstX * anchorY - x * firstY) / 2)

		firstX = x
		firstY = y

	end
	return area
end

function largeenough(coords) --checks if a polygon is good enough for box2d's snobby standards.
	--Written by Adam/earthHunter

	-- Calculation of centroids of each triangle

	local centroids = {}

	local anchorX = coords[1]
	local anchorY = coords[2]

	local firstX = coords[3]
	local firstY = coords[4]

	for i = 5, #coords - 1, 2 do

		local x = coords[i]
		local y = coords[i + 1]

		local centroidX = (anchorX + firstX + x) / 3
		local centroidY = (anchorY + firstY + y) / 3

		local area = math.abs(anchorX * firstY + firstX * y + x * anchorY
				- anchorX * y - firstX * anchorY - x * firstY) / 2

		local index = 3 * (i - 3) / 2 - 2

		centroids[index] = area
		centroids[index + 1] = centroidX * area
		centroids[index + 2] = centroidY * area

		firstX = x
		firstY = y

	end

	-- Calculation of polygon's centroid

	local totalArea = 0
	local centroidX = 0
	local centroidY = 0

	for i = 1, #centroids - 2, 3 do

		totalArea = totalArea + centroids[i]
		centroidX = centroidX + centroids[i + 1]
		centroidY = centroidY + centroids[i + 2]

	end

	centroidX = centroidX / totalArea
	centroidY = centroidY / totalArea

	-- Calculation of normals

	local normals = {}

	for i = 1, #coords - 1, 2 do

		local i2 = i + 2

		if (i2 > #coords) then

			i2 = 1

		end

		local tangentX = coords[i2] - coords[i]
		local tangentY = coords[i2 + 1] - coords[i + 1]
		local tangentLen = math.sqrt(tangentX * tangentX + tangentY * tangentY)

		tangentX = tangentX / tangentLen
		tangentY = tangentY / tangentLen

		normals[i] = tangentY
		normals[i + 1] = -tangentX

	end

	-- Projection of vertices in the normal directions
	-- in order to obtain the distance from the centroid
	-- to each side

	-- If a side is too close, the polygon will crash the game

	for i = 1, #coords - 1, 2 do

		local projection = (coords[i] - centroidX) * normals[i]
				+ (coords[i + 1] - centroidY) * normals[i + 1]

		if (projection < 0.04*meter) then

			return false

		end

	end

	return true

end

function highestbody() --returns the highest body in tetribodies. Because without the 1 body, #tetribodies sometimes fails or something
	i = 2
	while tetribodies[i] ~= nil do
		i = i + 1
	end
	return i-1
end

function samepos(coords, y, x) --checks if any point in a table is identical to another point (THIS SEEMS FISHY, CHECK THIS OUT)
	for j = 1, #coords, 2 do
		if math.abs(coords[j+1]-y) + math.abs(coords[j]-x) == 0 then
			return true
		end
	end
	return false
end

function collideA(a, b, coll) --box2d callback. calls endblock.
	--Sometimes a is nil or something I have no idea why.
	if a == nil or b == nil then
		return
	end
	
	if a[1] == 1 or b[1] == 1 then
		if a[1] ~= "left" and a[1] ~= "right" and b[1] ~= "left" and b[1] ~= "right" then 
			if gamestate == "gameA" then
				if tetribodies[1]:getY() < losingY then
					gamestate = "failingA"
					if musicno < 4 then
						love.audio.stop(music[musicno])
					end
					love.audio.stop(gameover1)
					love.audio.play(gameover1)
				
					if wallshapes[2] then
						wallshapes[2]:destroy()
						wallshapes[2] = nil
					end
				else
					tetrikind[highestbody()+1] = tetrikind[1]
					
					tetriimagedata[highestbody()+1] = tetriimagedata[1]
					tetriimages[highestbody()+1] = padImagedata( tetriimagedata[highestbody()+1] )
					
					tetribodies[highestbody()+1] = tetribodies[1]
					tetribodies[highestbody()]:setLinearDamping(0.5)
					
					tetrishapes[highestbody()] = {}
					for i, v in pairs(tetrishapes[1]) do
						tetrishapes[highestbody()][i] = tetrishapes[1][i]
						tetrishapes[highestbody()][i]:setData({highestbody()})
						tetrishapes[1][i] = nil
					end
					
					tetribodies[1] = nil
				
					endblock = true
				end
			end
		end
	end
end

function endblockA() --handles failing, moving the current block to the end of the tables and calls checklinedensity in active mode
	if checklinedensity(true) then
		game_addTetriA()
	else
		game_addTetriA()
		--RANDOMIZE NEXT PIECE
		nextpiece = math.random(7)
	end
end