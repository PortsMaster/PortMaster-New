-- UNION - Version 3
-- re - implemented the action selection system in a clearer way
--UNION
--27.3.2007 - version 2
--Enormator
-- 11.01.12 - insert game-provided physic constants where possible - by ngc92
-- 11.04.15 - updated math helper functions


ActiveFunction = nil
ActiveMode = nil
FunctionTable = {}
ModeInit = false

-- success tracking
LastDecision = {}
OldDecisions = {}
--  TODO automatic setup of these variables
OldDecisions[1] = {}
OldDecisions[2] = {}

--define world constants
netheight = CONST_NET_HEIGHT + CONST_NET_RADIUS -- height is just the rod. for total height, we have to add the net-sphere-radius too

-- called when opponent server
function OnOpponentServe()
	if ActiveMode ~= "oppserve" then 
		ActiveMode = "oppserve"
		-- print last decision
		print("Lost Round. Last Decision: ")
		for i, v in pairs(LastDecision) do
			print(i, v)
		end
		print("Old Decision: ")
		for j, d in ipairs(OldDecisions) do
			print("#", j)
			for i, v in pairs(d) do
				print(i, v)
			end
		end
		
		print("Decisions: ")
		for i, v in pairs(FunctionTable) do
			print(i, v['frq'])
		end
		decide()
	end
		
	ActiveFunction()
end

-- called when bot has to server
function OnServe( ballready )
	
	-- move to center until ball ready
	if ballready then
		if ActiveMode ~= "serve" then 
			ActiveMode = "serve"
			decide() 
		end
		ActiveFunction()
	else
		moveto(200)
	end
end

-- called every time step
function OnGame()
	-- end of serve detection:
	if ActiveMode == "serve" and ballx() > CONST_BALL_LEFT_NET + CONST_BALL_RADIUS then ActiveMode = "game" end
	if ActiveMode == "oppserve" then ActiveMode = "game" end
	
	ActiveFunction()
end

-- called whenever the ball bounces somewhere: this is when we decide which strategy to use
function OnBounce()
	decide()
end

-- function for selecting a new strategy
function decide()
	local best_score = -1
	local best_fun   = nil
	
	-- decide which function to use
	for index, value in pairs(FunctionTable) do
		-- is the function eligible for the current mode
		if value[ActiveMode] == true then
			local score = value['decide']()
			-- and has a better score
			if score > best_score then
				best_score = score
				best_fun = value
			end
		end
	end
	
	-- update active function
	ActiveFunction = best_fun['act']
	best_fun['frq'] = best_fun['frq'] + 1
	
	print("decide", best_fun['name'], best_score, ballx(), bally(), bspeedx(), bspeedy())
	
	-- track decsions to debug bot
	OldDecisions[3] = OldDecisions[2]
	OldDecisions[2] = OldDecisions[1]
	OldDecisions[1] = LastDecision
	--for i,v in pairs(LastDecision) do
	--	OldDecision[i] = v
	--end
	
	LastDecision = capture_situation_data()
	LastDecision['score'] = best_score
	LastDecision['estim_head'] = estimate_x_at_y( CONST_BALL_BLOBBY_HEAD )
	LastDecision['action'] = best_fun['name']
end

-- registers a new function to be used by the bot
function register(name, decision, action, modes)
	-- save function name, decision function, action function and call frequency
	local rec = {name=name, decide=decision, act=action, frq = 0}
	for i, v in ipairs(modes) do
		if v == "serve" or v == "oppserve" or v == "game" then
			rec[v] = true
		end
	end
	
	FunctionTable[name] = rec
end

---------------------------------------------------------------------------------
--  			 now come the function implementations
---------------------------------------------------------------------------------

function std45deg_d(funcno)		  	--plays ball in the air at height maxjump with 45° angle
	local maxjump  = CONST_BLOBBY_MAX_JUMP
	local distance = CONST_BALL_RADIUS
	local targetx, velx, balltime  = estimate_x_at_y (maxjump)
	targetx = targetx - distance
	local blobtime = math.max(blobtimetoy(maxjump), blob_time_to_x(targetx))
	
	--print("45", targetx, velx, balltime, blobtime)
	if targetx ~= math.huge and velx <= 3 and balltime >= blobtime and not launched() then
		return math.min(10^(-math.abs(velx)),1)*(70 + math.random() * 30)
	else
		return -1
	end
end

function std45deg_a (funcno, action) --spielt Ball aus der Luft bei maxjump im 45° Winkel an
                                   --plays ball in the air at height maxjump with 45° angle
                                   --funcno(s)=2,3
	local maxjump  = CONST_BLOBBY_MAX_JUMP
	local distance = CONST_BALL_RADIUS
	local targetx, velx, balltime  = estimate_x_at_y (maxjump)
	targetx = targetx - distance
	moveto (targetx)
	
	-- time the jump
	local blobtime = math.max(blobtimetoy(maxjump), blob_time_to_x(targetx))
	if balltime <= blobtime or launched() then
		jump()
	end
end

register("std45deg", std45deg_d, std45deg_a, {"game"})

--
function twohitserve_d() 	--Aufschlag: Stellen (bspeedx()=0), rueber
                                       --serve: up (bspeedx()=0), play
                                       --funcno(s)=2
  return math.random(10, 100)
end

function twohitserve_a()
	if (touches()==0) then
		if(moveto (200)) then
			jump()
		end
	elseif (touches()==1) then
		moveto(estimate_x_at_y(CONST_BLOBBY_MAX_JUMP)-45)
		if (bally()<580) and (bspeedy()<0) then
			jump()
		end
	end
end

register("twohitserve", twohitserve_d, twohitserve_a, {"serve"})


function takelow_d() --Ballannahme ohne Sprung zum Stellen (bspeedx()=0) selten exakt
                                  --take ball without jump to create a ball with bspeedx()=0 (sellen exactly)
                                  --funcno(s)=3
	-- check that we still can do two more touches
	if (touches() > 1) then
		return -1
	end
	
	-- check that ball is reachable
	local estimpos = estimate_x_at_y( CONST_BALL_BLOBBY_HEAD )
	if ( estimpos > CONST_BALL_RIGHT_NET ) then
		return -1
	end
	
	-- check that I have enough time to get the ball, in the worst case even barely
	local blobtime = blob_time_to_x( estimpos )
	local balltime = ball_time_to_y(CONST_BALL_BLOBBY_HEAD)
	if balltime < blobtime - 2 then
		print("UNREACHABLE", balltime, blobtime, posx(), ballx(), bspeedx(), estimpos)
		return -1
	end
	
	-- if we have some time buffer, it is better
	if balltime > blobtime + 5 then
		return 2 + math.random()
	else
		return 1
	end
end

function takelow_a() --Ballannahme ohne Sprung zum Stellen (bspeedx()=0) selten exakt
                                  --take ball without jump to create a ball with bspeedx()=0 (sellen exactly)
                                  --funcno(s)=3
	local target = estimate_x_at_y( CONST_BALL_BLOBBY_HEAD )
	if target ~= math.huge then
		moveto ( target )
	else
		-- we are screwed anyways ... just one last attempt
		print("Fuck :(")
		moveto( ballx() )
	end
end

register("takelow", takelow_d, takelow_a, {"game"})

-- -------------------------------------------------------------------------------------------------------------
--		low play: plays the ball to the other side 

function lowplay_d() 
	-- check that ball is reachable
	local estimpos = estimate_x_at_y( CONST_BALL_BLOBBY_HEAD )
	-- since we want to play the ball directly over the net, we need some space
	if ( estimpos > CONST_BALL_LEFT_NET - 2 * CONST_BALL_RADIUS) then
		return -1
	end
	
	-- check that I have enough time to get the ball, in the worst case even barely
	local blobtime = blob_time_to_x( estimpos )
	local balltime = ball_time_to_y( CONST_BALL_BLOBBY_HEAD )
	if balltime < blobtime + 5 then
		return -1
	end
	
	-- if we have some time buffer, it is better
	return 1 + (50 + math.random() * 30)*(1 - estimpos / CONST_FIELD_MIDDLE)
end

function lowplay_a()
	local target, v, t, py, vy = estimate_x_at_y( CONST_BALL_BLOBBY_HEAD )
	if target == math.huge then
		target, py, v, vy = estimate(1)
		t = 1
	end
	moveto ( target )
	-- if we are almost there, think about careful aiming
	if t < 10 and math.abs(posx() - target) < 5 * CONST_BLOBBY_SPEED then
		local tf = function(bx, by, vx, vy)
			if vx < 0 then return -1 end
			local aim = estimate_x_at_y(CONST_BALL_BLOBBY_HEAD, bx, by, vx, vy)
			--print(aim, bx, by, vx, vy)
			if aim < CONST_BALL_RIGHT_NET then
				return -1
			end
			
			-- estimate whether the ball will cross the net safely
			local ttn = (CONST_FIELD_MIDDLE - bx) / vx
			local yan = by + 0.5 * ttn^2 * CONST_BALL_GRAVITY + ttn * vy
			if yan < CONST_BALL_TOP_NET + CONST_BALL_RADIUS then
				return -1
			end
			
			-- number of steps the enemy needs to get to the ball
			local getsteps = math.abs(aim - oppx())/CONST_BLOBBY_SPEED
			local bsteps = math.abs(vy / CONST_BALL_GRAVITY)
			return 2 * bsteps / getsteps + math.max(0, getsteps - bsteps)
		end
		-- correctly round time to get full step ball coordinates
		print(py, vy)
		local ac, score = aim(posx(), posy(), target, py, tf, math.ceil(t))
		if ac then
			moveto(posx() + CONST_BLOBBY_SPEED * ac)
		end
	end
end

register("lowplay", lowplay_d, lowplay_a, {"game"})

-- block function
function block_d()
	if bspeedx() > 0 then
		return -1
	end
	
	-- check when ball crosses net
	local time, bx, by, velx, vely = simulate_until( ballx(), bally(), bspeedx(), bspeedy(), "x", CONST_FIELD_MIDDLE )
	
	if time < 0 or by < CONST_BALL_TOP_NET then
		return -1
	end
	
	-- allow for an additional five frames after net passage to catch the ball
	if not can_blob_reach(time+5, posx(), bx, by) then
		return -1
	end
	
	local owntime = blob_time_to_x( CONST_FIELD_MIDDLE - CONST_BLOBBY_BODY_RADIUS )
	local posscore = math.max(0, 5 - (by - CONST_BALL_TOP_NET) / CONST_BALL_RADIUS) * 5
	local velscore = 125 / (math.abs(vely) + 5)
	local ecatchbonus = 0
	if not can_blob_reach(time, oppx(), bx, by) then
		ecatchbonus = 10
	end
	
	-- todo incorporate estimates about enemy blocking etc.
	
	return 1 + (posscore + velscore) * (1 + math.random()) + ecatchbonus
end

function block_a()
	local time, bx, by, velx, vely = simulate_until( ballx(), bally(), bspeedx(), bspeedy(), "x", CONST_FIELD_MIDDLE )
	moveto ( CONST_FIELD_MIDDLE )
	if blob_time_to_y(by) <= time + 1 or launched() then
		jump()
	end
end

register("block", block_d, block_a, {"game"})

-- wait function
function wait_d() -- decides whether wait is a viable option: only whenn ball will hit ground in opponents
				  -- field
	local estimpos = estimate_x_at_y( CONST_BALL_BLOBBY_HEAD )
	if ( estimpos < CONST_BALL_RIGHT_NET ) then
		return -1
	else
		return 0
	end
end

function wait_a()
	-- make sure that we are not waiting if the ball, by some fluke, now actually does land on our side
	local estimpos = estimate_x_at_y( CONST_BALL_BLOBBY_HEAD )
	if ( estimpos < CONST_BALL_RIGHT_NET ) then
		print("STOP_WAIT")
		decide()
	end
	moveto(200)
end

register("wait", wait_d, wait_a, {"serve", "oppserve", "game"})

-- emergency safe functiom
function emergency_d() -- cannot be better than zero, but is a last try if everything else fails
	local estimpos = estimate_x_at_y( CONST_BALL_BLOBBY_HEAD )
	if ( estimpos > CONST_BALL_RIGHT_NET or not is_ball_valid() ) then
		return -1
	end
	return 0
end

function emergency_a() -- try to catch the ball by any means necessary
	-- need some desperate try to get it over the net?
	local back = 0
	if touches() == 2 then
		back = -10
	end
	
	-- first option: the ball is slower than my movement
	if math.abs(bspeedx()) < CONST_BLOBBY_SPEED then
		moveto( ballx() + back )
		return
	end
	
	
	-- this is the last position where we might still get the ball
	local time1 = ball_time_to_y(CONST_BALL_BLOBBY_HEAD)
	local time2 = ball_time_to_y(CONST_BALL_BLOBBY_HEAD - CONST_BALL_RADIUS)
	local resultX, estimbspeedx = estimx(time1)
	
	-- can we get there before the ball. 
	local time_to_impact = blob_time_to_x( resultX )
	if time_to_impact < time1 then
		-- do 
		moveto( resultX + back )
		return
	else
		local pos_em, v = estimx(time2)
		time_to_impact = blob_time_to_x(pos_em)
		if time_to_impact < time2 then
			moveto(pos_em)
			return
		end
	end
	
	print("PANIC!")
	
	-- ok, we need to catch the ball somewhere in flight!
	-- first, we can estimate the time the ball we need
	-- at least to reach the ball
	local time_x_dist = math.abs((posx() - ballx())/(math.abs(bspeedx()) + CONST_BLOBBY_SPEED))
	local bx, by, vx, vy = estimate(time_x_dist)
	-- starting from here, we can find out if the ball is within our reach
	for i = 0,50,2 do
		if can_blob_reach(time_x_dist + i, posx(), bx, by) then
			moveto(bx)
			print("Rescue possible")
			return
		end
		 bx, bx, vx, vy = estimate(time_x_dist, bx, by, vx, vy)
	end
	
	
	-- this does not work if the ball goes to x using an indirect route!
	-- we need to account for that!
	local time_to_blob_direct = ball_time_to_x(posx())
	
	-- if there is an impact along the way, and the ball does not reach the blobby directly
	if time_to_blob == math.huge and estimbspeedx ~= bspeedx() then
		time_to_blob = time1 - math.abs( (posx() - resultX)/ estimbspeedx )
	end
	
	-- will the ball pass over the blobby?
	if time_to_blob == math.huge then
		moveto(resultX + back)
		-- FUUUUUU :(
	else
		-- find out at which height the ball passes, and how long a jump to that height takes
		--print("ttb", time_to_blob)
		local by = estimy( time_to_blob )
		-- the ball passes the ground before getting to the blob. This should only happen with a wallhit
		if by < CONST_BALL_BLOBBY_HEAD - CONST_BALL_RADIUS / 2 then
			moveto(hit)
			return
		end
		local jumptime = blobtimetoy( by - CONST_BLOBBY_HEIGHT/2 )
		local timeframe = CONST_BALL_RADIUS / 2 / math.abs(bspeedx())	-- gets the timeframe we have for planning our ball collision
		
		print(by, jumptime, time_to_blob)
		
		-- we can just stand here and wait for the ball to pass over us. we only need to react when jumptime > time_to_blob
		if jumptime > time_to_blob then
			-- if the ball moves very slowly horizontally, we have to act differently: the time till it hits our exavt position might be low, 
			-- but we might have a lot of time until it leaves our sphere of influence
		
		
			jump()
			-- how much time to we miss; correct aim
			local td = jumptime - time_to_blob
			moveto( posx() + estimbspeedx * td + back )
		end
	end
end

register("emergency", emergency_d, emergency_a, {"game"})

--mathematische Hilfsfunktionen

function blobtimetoy (y) --Zeit, die ein Blob braucht, um eine Y Position zu erreichen
                         --time needed by a blob to reach a given y coordinate
 if (y>383) then
  y=383
 end
 local grav = CONST_BLOBBY_GRAVITY / 2    -- half, because we use jump buffer
 local time1 = CONST_BLOBBY_JUMP/grav + math.sqrt(2*grav*(y-posy()) + CONST_BLOBBY_JUMP*CONST_BLOBBY_JUMP) / grav
 local time2 = CONST_BLOBBY_JUMP/grav - math.sqrt(2*grav*(y-posy()) + CONST_BLOBBY_JUMP*CONST_BLOBBY_JUMP) / grav
 local timemin=math.min(time1,time2)
 if timemin <0 then
	return math.max(time1,time2)
 end
 return timemin
end

-- aiming submodule --
function simulateBallBlobbyContact(blobx, bloby, ballx, bally)
	local dx = ballx - blobx
	local dy1 = bally - bloby + CONST_BLOBBY_BODY_OFFSET
	local dy2 = bally - bloby + CONST_BLOBBY_HEAD_OFFSET
	
	if dx^2 + dy1^2 < (CONST_BALL_RADIUS + CONST_BLOBBY_BODY_RADIUS)^2 then
		local l = math.sqrt(dx^2 + dy1^2)
		return true, CONST_BALL_HITSPEED * dx / l, CONST_BALL_HITSPEED * dy1 / l
	end
	
	if dx^2 + dy2^2 < (CONST_BALL_RADIUS + CONST_BLOBBY_HEAD_RADIUS)^2 then
		local l = math.sqrt(dx^2 + dy2^2)
		return true, CONST_BALL_HITSPEED * dx / l, CONST_BALL_HITSPEED * dy2 / l
	end
	
	return false
end

-- this function finds out how the blobby has to move to hit the ball such that it fulfills the target condition best
-- note that target has to be a function of (ballx, bally, bspeedx, bspeedy), that returns a score. bloby and ballyalready in a position 
-- have to be chosen such that we are where an impact can happen.
function aim( blobx, bloby, ballx, bally, target, maxt )
	assert( bally ~= nil )
	maxt = maxt or 5
	-- limit calculation
	if maxt > 10 then
		maxt = 10
	end
	
	local best = -1
	local optimal = nil
	for dx = -maxt, maxt do
		local hit, vx, vy = simulateBallBlobbyContact(blobx + dx * CONST_BLOBBY_SPEED, bloby, ballx, bally)
		if hit then
			local score = target(ballx, bally, vx, vy)
			if score > best then
				best = score
				optimal = dx
			end
		end
	end
	
	return optimal, best
end