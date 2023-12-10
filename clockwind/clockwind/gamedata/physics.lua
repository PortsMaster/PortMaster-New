--Yet another Physics engine
--V.2.0: Featuring innaccurate diagonal collisions!
--Collision callback is object:collide(side, name, object)

local inrange --, aabb --temporarily global

local passivecollisions = true --may hurt performance a tad!

--masks

--1: TILE
--2: PLAYER
--3: SEED
--4: TREE
--5: BRANCH
--6: ENEMY
--7: BUSH
--8: GOAL
--9: GEAR

function physics_update(dt)
	for a, obj_table1 in pairs(obj) do
		if a ~= "tile" and a ~= "border" then
			for i1, b in pairs(obj_table1) do
				if b.active and (not b.static) and not (b.delete) then
					--gravity
					if not b.static then
						b.sy = math.min(MAXYSPEED, b.sy + (b.gravity or GRAVITY)*dt)
					end

					local fx, fy = b.x + b.sx*dt, b.y + b.sy*dt --future x, future y
					local ox, oy = b.x, b.y --original position, used to check if object was teleported in collision callback
					local minx, miny = -math.huge, -math.huge
					local maxx, maxy = math.huge, math.huge

					local sx, sy = b.sx, b.sy
					local setsxl, setsxr, setsyu, setsyd = false --change speed after collision (left, right, up, down)

					--collide
					for c, obj_table2 in pairs(obj) do
						if c ~= "tile" then
							for i2, d in pairs(obj_table2) do
								if d.active and b.mask[d.category] and not (a == c and i1 == i2) and not (b.delete) then
									minx, miny, maxx, maxy, setsxl, setsxr, setsyu, setsyd = physics_checkcollision(a, b, c, d, sx, sy, fx, fy, minx, miny, maxx, maxy, setsxl, setsxr, setsyu, setsyd)
								end
							end
						end
					end
					--collide with tiles
					if b.mask[1] then --does it collide with tiles?
						local left, right = b.x, fx
						if fx < b.x then
							left, right = fx, b.x
						end
						local top, bottom = b.y, fy
						if fy < b.y then
							top, bottom = fy, b.y
						end
						local tilecount = 0
						for x = math.floor((left-0.001)/TILE), math.floor((right+b.w+0.001)/TILE) do
							for y = math.floor((top-0.001)/TILE), math.floor((bottom+b.h+0.001)/TILE) do
								tilecount = tilecount + 1
								if obj["tile"][x+1 .. "|" .. y+1] then
									local c, d = "tile", obj["tile"][x+1 .. "|" .. y+1]
									minx, miny, maxx, maxy, setsxl, setsxr, setsyu, setsyd = physics_checkcollision(a, b, c, d, sx, sy, fx, fy, minx, miny, maxx, maxy, setsxl, setsxr, setsyu, setsyd)
								end
							end
						end
					end

					--move
					if b.x ~= ox then
						--same as below, with out this objects may phase through if teleported in collision callback
						sx = 0
					end
					b.x = math.max(minx, math.min(maxx, b.x + sx*dt))
					if b.y ~= oy then
						--lazy fix, after passive colliding speedy would not get set to 0
						sy = 0
					end
					b.y = math.max(miny, math.min(maxy, b.y + sy*dt))
					if setsxr then --right
						b.sx = math.min(b.sx, setsxr)
					end
					if setsxl then --left
						b.sx = math.max(b.sx, setsxl)
					end
					if setsyd then --down
						b.sy = math.min(b.sy, setsyd)
					end
					if setsyu then --up
						b.sy = math.max(b.sy, setsyu)
					end
				end
			end
		end
	end
end

function physics_checkcollision(a, b, c, d, sx, sy, fx, fy, minx, miny, maxx, maxy, setsxl, setsxr, setsyu, setsyd)
	local collided
	--horizontal collision
	local rangex
	if math.abs(sx) > math.abs(sy) then
		local top, bottom = b.y, fy
		if fy < b.y then
			top, bottom = fy, b.y
		end
		rangex = inrange(top, (bottom-top)+b.h, d.y, d.h) --diagonal collision bitch
	else
		rangex = inrange(b.y, b.h, d.y, d.h)
	end
	if rangex and b.y+b.h ~= d.y and b.y ~= d.y+d.h then --In range! Also don't do horizontal collisions on adjacent tiles, stoopid~
		local docollide = false
		if d.r then --circle!
			--[[local bx, by = b.x+b.w/2, b.y+b.h/2
			local bfy = fy+b.h/2
			local circle = math.sqrt((d.r*d.r)+(bfy-d.ry)*(bfy-d.ry))*2-d.r*2
			local dw = d.r*2-circle*2
			local dx = d.x+circle]]
		else
			if b.x+b.w <= d.x and fx+b.w >= d.x then --right
				if d.x-b.w <= maxx then
					--callbacks
					if b.collide then if b:collide("right", c, d) then docollide = true end end
					if d.collide then d:collide("left", a, b) end
					if docollide then
						maxx = d.x-b.w
						setsxr = 0
						collided = true
					end
				end
			elseif b.x >= d.x+d.w and fx <= d.x+d.w then --left
				if d.x+d.w >= minx then
					--callbacks
					if b.collide then if b:collide("left", c, d) then docollide = true end end
					if d.collide then d:collide("right", a, b) end
					if docollide then
						minx = d.x+d.w
						setsxl = 0
						collided = true
					end
				end
			end
		end
	end
	--vertical collision
	local rangey
	if math.abs(sx) <= math.abs(sy) then
		local left, right = b.x, fx
		if fx < b.x then
			left, right = fx, b.x
		end
		rangey = inrange(left, (right-left)+b.w, d.x, d.w) --diagonal collision bitch
	else
		rangey = inrange(b.x, b.w, d.x, d.w)
	end
	if rangey and b.x+b.w ~= d.x and b.x ~= d.x+d.w then --same thing, don't stand on walls!
		local docollide = false
		if d.r then --circle!
			--[[local bx, by = b.x+b.w/2, b.y+b.h/2
			local bfx = fx+b.w/2
			local circle = math.sqrt((d.r*d.r)+(bfx-d.rx)*(bfx-d.rx))*2-d.r*2
			local dh = d.r*2-circle*2
			local dy = d.y+circle]]
		else
			if b.y+b.h <= d.y and fy+b.h >= d.y then --down
				if d.y-b.h <= maxy then
					--callbacks
					if b.collide then if b:collide("down", c, d) then docollide = true end end
					if d.collide then d:collide("up", a, b) end
					if docollide then
						maxy = d.y-b.h
						setsyd = 0
						collided = true
					end
				end
			elseif b.y >= d.y+d.h and fy <= d.y+d.h then --up
				if d.y+d.h >= miny then
					--callbacks
					if b.collide then if b:collide("up", c, d) then docollide = true end end
					if d.collide then d:collide("down", a, b) end
					if docollide then
						miny = d.y+d.h
						setsyu = 0
						collided = true
					end
				end
			end
		end
	end
	--passive
	if passivecollisions then
		if d.r then --circle
			local bx, by = b.x+b.w/2, b.y+b.h/2
			if (not collided) and (bx-d.rx)*(bx-d.rx)+(by-d.ry)*(by-d.ry) < d.r*d.r then
				if b.collide then b:collide("passive", c, d) end
				if d.collide then d:collide("passive", a, b) end
			end
		else
			if (not collided) and aabb(b.x, b.y, b.w, b.h, d.x, d.y, d.w, d.h) then
				if b.collide then b:collide("passive", c, d) end
				if d.collide then d:collide("passive", a, b) end
			end
		end
	end
	return minx, miny, maxx, maxy, setsxl, setsxr, setsyu, setsyd
end

function insidewall(map, x1, y1, w1, h1, checkbreakable, exclude)
	for a, b in pairs(obj["border"]) do
		if aabb(x1, y1, w1, h1, b.x, b.y, b.w, b.h) then
			return b.x, b.x+b.w
		end
	end
	for a, b in pairs(obj["bush"]) do
		if aabb(x1, y1, w1, h1, b.x, b.y, b.w, b.h) and not (exclude and b.x == exclude.x and b.y == exclude.y) then
			return  b.x, b.x+b.w
		end
	end
	
	for x = math.floor((x1+0.00001)/TILE), math.floor((x1+w1-0.00001)/TILE) do
		for y = math.floor((y1-0.001)/TILE), math.floor((y1+h1+0.001)/TILE) do
			local col = map:getCollision(x+1, y+1)
			if col and (not (checkbreakable and map:getProp(x+1, y+1, "breakable")) and (not map:getProp(x+1, y+1, "platform"))) then
				return x*TILE, x*TILE+TILE, (map:getProp(x+1, y+1, "spikeleft") or map:getProp(x+1, y+1, "spikeright") or map:getProp(x+1, y+1, "spikedown") or map:getProp(x+1, y+1, "spikeup"))
			end
		end
	end
	--[[for x = 1, map.w do
		for y = 1, map.h do
			if obj["tile"][x .. "|" .. y] then
				local b = obj["tile"][x .. "|" .. y]
				if aabb(x1, y1, w1, h1, b.x, b.y, b.w, b.h) then
					return true
				end
				if obj["tile"][x+1 .. "|" .. y+1] and not (checkbreakable and map:getProp(x+1, y+1)) then
					return true
				end
			end
		end
	end]]
end

function inrange(x1, w1, x2, w2)
	return (x1 < x2+w2 and x1+w1 > x2)
end

function aabb(x1, y1, w1, h1, x2, y2, w2, h2)
	return (inrange(x1, w1, x2, w2) and inrange(y1, h1, y2, h2))
end
