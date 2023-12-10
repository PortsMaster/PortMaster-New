local editor = {}

--local functions
local getmousetile
--other variables
local edittilemode = 1 --tile, background tile (not implemented as of writing this), entity, text
local edittilei = 1
local edittilei2 = 1
local edittilebrush = {1, 1}
local edittilescrolltime = 0.4 --time scroll wheel last
local edittilescrolltimer = false --time since scrolled
local tilesscroll = 0

local ignoreclick = false
local textprompt, textinput = false, ""

function editor.load()
	camera:freeze(true)
end

function editor.update(dt)
	--CAMERA MOVEMENT
	if (not love.keyboard.isDown("a")) and (not love.keyboard.isDown("-")) and (not love.keyboard.isDown("lshift")) then --don't move while resizing map
		local cameraspeed = 200
		if love.keyboard.isDown("lctrl") then
			cameraspeed = 600
		end
		if love.keyboard.isDown("left") then
			camera:pan(-cameraspeed*dt, 0)
		elseif love.keyboard.isDown("right") then
			camera:pan(cameraspeed*dt, 0)
		end
		if love.keyboard.isDown("up") then
			camera:pan(0, -cameraspeed*dt)
		elseif love.keyboard.isDown("down") then
			camera:pan(0, cameraspeed*dt)
		end
	end

	--TILE PLACEMENT
	if not ignoreclick then
		local x, y = getmousetile()
		if x and y then
			if love.mouse.isDown(1) then --place
				if edittilemode == 3 then
					for bx = 1, edittilebrush[1] do
						for by = 1, edittilebrush[2] do
							map:set(x+(bx-1), y+(by-1), edittilei2, edittilemode)
						end
					end
				else
					for bx = 1, edittilebrush[1] do
						for by = 1, edittilebrush[2] do
							map:set(x+(bx-1), y+(by-1), edittilei, edittilemode)
						end
					end
				end
			elseif love.mouse.isDown(2) then --erase?
				--map:set(x, y, 0, edittilemode)
				--2 is for changing tilemode
			elseif love.mouse.isDown(3) then --copy tile
				if edittilemode == 3 then
					edittilei2 = map:get(x, y, edittilemode)
				else
					edittilei = map:get(x, y, edittilemode)
				end
			end
		end
	end

	--MOUSE WHEEL
	if edittilescrolltimer then
		edittilescrolltimer = edittilescrolltimer - dt
		if edittilescrolltimer < 0 then
			edittilescrolltimer = false
		end
	end
end

function editor.draw()
	--GAMEPLAY
	love.graphics.push()
	love.graphics.translate(-camera.x, -camera.y)

	--Cursor
	local x, y = getmousetile()
	if x and y and (not love.keyboard.isDown("q")) then
		if edittilemode == 3 then
			if edittilei2 > 0 then
				--Show Tile
				love.graphics.setColor(1,1,1,.4)
				love.graphics.draw(objtilesimg, objtileq[edittilei2], (x-1)*TILE, (y-1)*TILE)
			else
				--Show Eraser
				love.graphics.setColor(1,1,1,.4)
				love.graphics.rectangle("fill", (x-1)*TILE, (y-1)*TILE, TILE, TILE)
			end
		else
			if edittilei > 0 then
				--Show Tile
				love.graphics.setColor(1,1,1,.4)
				love.graphics.draw(tilesimg[timeperiod], tileq[timeperiod][edittilei][1], (x-1)*TILE, (y-1)*TILE)
			else
				--Show Eraser
				love.graphics.setColor(1,1,1,.4)
				love.graphics.rectangle("fill", (x-1)*TILE, (y-1)*TILE, TILE, TILE)
			end
		end

		--show wheel of tiles
		if edittilescrolltimer then
			for i = -2, 2 do
				if edittilemode == 3 then
					if i ~= 0 and edittilei2+i > 0 and edittilei2+i < #objtileq then
						love.graphics.setColor(1,1,1, (100-(30*math.abs(i)))/255)
						love.graphics.draw(objtilesimg, objtileq[edittilei2+i], (x-1)*TILE, (y-1+i)*TILE)
					end
				else
					if i ~= 0 and edittilei+i > 0 and edittilei+i < #tileq[timeperiod] then
						love.graphics.setColor(1,1,1, (100-(30*math.abs(i)))/255)
						love.graphics.draw(tilesimg[timeperiod], tileq[timeperiod][edittilei+i][1], (x-1)*TILE, (y-1+i)*TILE)
					end
				end
			end
		end

		if edittilemode == 1 then
			love.graphics.setColor(0, 0.2, 0.8, 1)
		elseif edittilemode == 2 then
			love.graphics.setColor(0.1, 0.9, 0.3, 1)
		else
			love.graphics.setColor(0.8, 0.4, 0, 1)
		end
		love.graphics.rectangle("line", (x-1)*TILE, (y-1)*TILE, TILE*edittilebrush[1], TILE*edittilebrush[2])
	end

	love.graphics.pop()

	if textprompt then
		love.graphics.setColor(1, 0, 0, .3)
		love.graphics.rectangle("fill", 0, 0, 640, 24)
		love.graphics.setColor(1, 0, 0)
		local s = "|"
		if math.floor(os.time()/2) == math.ceil(os.time()/2) then
			s = ""
		end
		love.graphics.setFont(font)
		love.graphics.print(textprompt .. " : " .. textinput .. s, 5, 5)
	elseif love.keyboard.isDown("q") then --tiles
		love.graphics.setColor(1,1,1,0.9)
		if edittilemode == 3 then
			love.graphics.draw(objtilesimg, 0, tilesscroll)
		else
			love.graphics.draw(tilesimg[1], 0, tilesscroll)
		end
		local x, y = love.mouse.getPosition()
		if love.mouse.isDown(1) then
			love.graphics.setColor(1,0.9,0.5,0.5)
		else
			love.graphics.setColor(1,1,1,0.5)
		end
		love.graphics.rectangle("fill", math.floor(x/TILE)*TILE, math.floor((y-tilesscroll)/(TILE+1))*(TILE+1)+tilesscroll, TILE, TILE)
	end
end

function editor.keypressed(k)
	if textprompt then
		if k == "return" then
			if textprompt == "save" then
				map:save(tonumber(textinput))
			elseif textprompt == "load" then
				map:load(tonumber(textinput))
				LEVEL = tonumber(textinput)
			elseif textprompt == "load-game" then
				leveledit = false
				leveleditreturn = true
				game.load(tonumber(textinput))
			elseif textprompt == "load-game-fast" then
				local x, y = obj["player"][1].x, obj["player"][1].y
				leveledit = false
				leveleditreturn = "fast"
				game.load(tonumber(textinput))
				obj["player"][1].x = x
				obj["player"][1].y = y
				obj["player"][1].checkpointx = math.floor(x/TILE)
				obj["player"][1].checkpointy = math.floor(y/TILE)
			elseif textprompt == "text" then
				local tx, ty = getmousetile()
				if tx and ty then
					map:set(tx, ty, textinput, 4)
				end
			elseif textprompt == "background" then
				map.background = textinput
			end
			textprompt = false
		elseif k == "escape" then
			textprompt = false
			return
		elseif k == "space" then
			textinput = textinput .. " "
		elseif k == "backspace" then
			textinput = textinput:sub(1, -2)
		elseif #k == 1 then
			textinput = textinput .. k
		end
	else
		if k == "1" then --save level
			textprompt = "save"
			textinput = tostring(LEVEL) or "1"
		elseif k == "2" then --load level
			textprompt = "load"
			textinput = tostring(LEVEL) or "1"
		elseif k == "3" then
			local tx, ty = getmousetile()
			if tx and ty then
				textprompt = "text"
				textinput = tostring(map:get(tx, ty, 4) or "")
			end
		elseif k == "4" then
			textprompt = "load-game"
			textinput = tostring(LEVEL) or "1"
		elseif k == "5" then
			textprompt = "load-game-fast"
			textinput = tostring(LEVEL) or "1"
		elseif k == "6" then
			textprompt = "background"
			textinput = tostring(map.background) or ""
		elseif love.keyboard.isDown("a") and k == "right" then
			map:expand("right")
			camera:setBounds(0, 0, map.w*TILE, map.h*TILE)
			return
		elseif love.keyboard.isDown("a") and k == "left" then
			map:expand("left")
			camera:setBounds(0, 0, map.w*TILE, map.h*TILE)
			return
		elseif love.keyboard.isDown("a") and k == "up" then
			map:expand("up")
			camera:setBounds(0, 0, map.w*TILE, map.h*TILE)
			return
		elseif love.keyboard.isDown("a") and k == "down" then
			map:expand("down")
			camera:setBounds(0, 0, map.w*TILE, map.h*TILE)
			return
		elseif love.keyboard.isDown("-") and k == "right" then
			map:reduce("left")
			camera:setBounds(0, 0, map.w*TILE, map.h*TILE)
			return
		elseif love.keyboard.isDown("-") and k == "left" then
			map:reduce("right")
			camera:setBounds(0, 0, map.w*TILE, map.h*TILE)
			return
		elseif love.keyboard.isDown("-") and k == "up" then
			map:reduce("down")
			camera:setBounds(0, 0, map.w*TILE, map.h*TILE)
			return
		elseif love.keyboard.isDown("-") and k == "down" then
			map:reduce("up")
			camera:setBounds(0, 0, map.w*TILE, map.h*TILE)
			return
		elseif love.keyboard.isDown("lshift") and k == "right" then
			edittilebrush[1] = edittilebrush[1] + 1
			return
		elseif love.keyboard.isDown("lshift") and k == "left" then
			edittilebrush[1] = math.max(1, edittilebrush[1] - 1)
			return
		elseif love.keyboard.isDown("lshift") and k == "up" then
			edittilebrush[2] = math.max(1, edittilebrush[2] - 1)
			return
		elseif love.keyboard.isDown("lshift") and k == "down" then
			edittilebrush[2] = edittilebrush[2] + 1
			return
		elseif love.keyboard.isDown("lshift") and k == "space" then
			edittilebrush = {1, 1}
			return
		end
	end
end

function editor.keyreleased(k)
	if k == "e"  then
		--teleport
		obj["player"][1].x = love.mouse.getX()+camera:getX()-obj["player"][1].w/2
		obj["player"][1].y = love.mouse.getY()+camera:getY()-obj["player"][1].h
	end
end

function editor.mousepressed(x, y, b)
	if b == 1 then
		if love.keyboard.isDown("q") then
			if edittilemode == 1 or edittilemode == 2 then
				local tilesperrow = math.floor(tilesimg[timeperiod]:getWidth()/TILE)
				edittilei = math.min(#tileq[timeperiod], math.max(0, math.ceil(x/TILE)+tilesperrow*math.floor((y-tilesscroll)/(TILE+1))))
				ignoreclick = true
			elseif edittilemode == 3 then
				local tilesperrow = math.floor(objtilesimg:getWidth()/TILE)
				edittilei2 = math.min(#objtileq, math.max(0, math.ceil(x/TILE)+tilesperrow*math.floor((y-tilesscroll)/(TILE+1))))
				ignoreclick = true
			end
		end
	elseif b == 2 then
		edittilemode = (edittilemode%3)+1
	end
end

function editor.mousereleased(x, y, b)
	ignoreclick = false
end

function editor.wheelmoved(dx, dy)
	if love.keyboard.isDown("q") then
		tilesscroll = math.min(0, tilesscroll + dy*21)
		return
	end
	if dy < 0 then
		if edittilemode == 3 then
			edittilei2 = math.min(#tileq[timeperiod], edittilei2 + 1)
		else
			edittilei = math.min(#tileq[timeperiod], edittilei + 1)
		end
		edittilescrolltimer = edittilescrolltime
	elseif dy > 0 then
		if edittilemode == 3 then
			edittilei2 = math.max(0, edittilei2 - 1)
		else
			edittilei = math.max(0, edittilei - 1)
		end
		edittilescrolltimer = edittilescrolltime
	end
end

function getmousetile(mx, my)
	local mx, my = mx or love.mouse.getX(), my or love.mouse.getY()
	local tx, ty = math.ceil((mx+camera.x)/TILE), math.ceil((my+camera.y)/TILE)
	if map:inside(tx, ty) then
		return tx, ty
	end
	return false, false
end

return editor
