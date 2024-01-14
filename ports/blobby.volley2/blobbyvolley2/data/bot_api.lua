-- this file provides an intermediary layer between the very simplistic c++ lua api and the 
-- lua bot api that can be used to program blobby volley 2 bots.

-- in these global variables, we save the ball info for each step
__bx = 0
__by = 0
__bvx = 0
__bvy = 0
-- these save the artificial errors used to reduce the bot strength
__ebx = 0
__eby = 0
__ebvx = 0
__ebvy = 0

-- debug data
__LastBounces = {}
__OppServe = false

__OPPSIDE = opponent(__SIDE)

-- legacy functions
-- these function definitions make lua functions for the old api functions, which are sometimes more conveniente to use 
-- than their c api equivalent.

function posx()
	local x, y = get_blob_pos( __SIDE )
	if __SIDE == RIGHT_PLAYER then
		return CONST_FIELD_WIDTH - x
	else
		return x
	end
end

function posy()
	local x, y = get_blob_pos( __SIDE )
	return y
end

function touches()
	return get_touches( __SIDE )
end

-- redefine the ball coordinate functions to use the cached values
function ballx()
	return __bx
end

function bally()
	return __by
end

function bspeedx()
	return __bvx
end

function bspeedy()
	return __bvy
end

-- we need to save balldata somewhere to use it in here
__balldata__ = balldata
-- this is the internal function that does the side correction
function __balldata()
	local x, y, vx, vy = __balldata__()
	if __SIDE == RIGHT_PLAYER then
		x = CONST_FIELD_WIDTH - x
		vx = -vx
	end
	return x, y, vx, vy
end

-- this is the function to be used by bots, which includes the difficulty changes
function balldata()
	return __bx, __by, __bvx, __bvy
end

-- redefine launched to refer to the __SIDE player
__launched = launched
function launched()
	return __launched( __SIDE )
end

function left()
	__WANT_LEFT  = __SIDE == LEFT_PLAYER
	__WANT_RIGHT = __SIDE ~= LEFT_PLAYER
end

function right()
	__WANT_LEFT  = __SIDE ~= LEFT_PLAYER
	__WANT_RIGHT = __SIDE == LEFT_PLAYER
end

function jump()
	__WANT_JUMP = true
end

function moveto(target)
	if target == nil then
		error("invalid target for moveto", 2)
	end
	local x = posx()
	if x < target - CONST_BLOBBY_SPEED/2 then
		right()
		return false
	elseif x > target + CONST_BLOBBY_SPEED/2 then
		left()
		return false
	else
		__WANT_LEFT  = false
		__WANT_RIGHT = false
		return true
	end
end

function oppx()
	local x, y = get_blob_pos( __OPPSIDE )
	if __SIDE == RIGHT_PLAYER then
		return CONST_FIELD_WIDTH - x
	else
		return x
	end
end

function oppy()
	local x, y = get_blob_pos( __OPPSIDE )
	return y
end

function getScore()
	return get_score( __SIDE )
end

function getOppScore()
	return get_score( __OPPSIDE )
end

-----------------------------------------------------------------------------------------
-- 						enhances ball prediction functions							   --
-----------------------------------------------------------------------------------------

-- calculates the time the ball needs to reach the specified x position.
-- the parameters posy and vely are currently not used, but are present to
-- ensure that the same group of parameters can be used like for any other 
-- estimate like function
function ball_time_to_x( destination, posx, posy, velx, vely )
	if destination == nil then error("invalid destination specified for ball_time_to_x") end
	
	posx = posx or ballx()
	velx = velx or bspeedx()
	return linear_time_first(posx, velx, destination)
end

-- calculates the time the blobby needs from its current position to destination
function blob_time_to_x (destination) 
	return math.abs(posx() - destination) / CONST_BLOBBY_SPEED
end

function blob_time_to_y (destination) 
	-- TODO allow specifying whether upward or downward!
	-- TODO error handling
	local blobbygroundpos = CONST_GROUND_HEIGHT + CONST_BLOBBY_HEIGHT / 2 
	local y = posy()
	grav = CONST_BLOBBY_GRAVITY / 2    -- half, because we use jump buffer
	time1 = CONST_BLOBBY_JUMP/grav + math.sqrt(2*grav*(y-blobbygroundpos) + CONST_BLOBBY_JUMP*CONST_BLOBBY_JUMP) / grav
	time2 = CONST_BLOBBY_JUMP/grav - math.sqrt(2*grav*(y-blobbygroundpos) + CONST_BLOBBY_JUMP*CONST_BLOBBY_JUMP) / grav
	timemin = math.min(time1,time2)
	return timemin
end

-- checks whether a certain position can be reached by the blob in a certain time frame
-- currently, this function assumes that the blob is standing on the ground.
function can_blob_reach( time, blobx, posx, posy )
	local minx = blobx - CONST_BLOBBY_SPEED * time
	local maxx = blobx + CONST_BLOBBY_SPEED * time
	local maxy = CONST_BLOBBY_GROUND_HEIGHT + CONST_BLOBBY_JUMP * time + CONST_BLOBBY_GRAVITY/2 * time^2
	local vel = CONST_BLOBBY_JUMP + CONST_BLOBBY_GRAVITY * time
	if vel < 0 then
		maxy = CONST_BLOBBY_MAX_JUMP
	end
	
	return minx < posx and posx < maxx and posy < maxy
end

-- calculates the time the ball needs from pos to destination
function ball_time_to_y( destination, posx, posy, velx, vely )
	posy = posy or bally()
	vely = vely or bspeedy()
	-- TODO this ignores net bounces
	return parabola_time_first( posy, vely, CONST_BALL_GRAVITY, destination )
end

-- generic estimate function that advances the whole ball state
function estimate(time, posx, posy, velx, vely)
	-- read parameters and set correct defaults
	-- TODO actually, it makes only sense to set them all, or none. should we check that somewhere?
	-- TODO re-introduce errors
	posx = posx or ballx()
	velx = velx or bspeedx()
	posy = posy or bally()
	vely = vely or bspeedy()

	__PERF_ESTIMATE_COUNTER = __PERF_ESTIMATE_COUNTER + 1
	return simulate( time, posx, posy, velx, vely )
end

-- old style estimate functions, using the new, advanced function for implementation
function estimx(time, posx, posy, velx, vely)
	posx, posy, velx, vely = estimate(time, posx, posy, velx, vely)
	return posx, velx
end

function estimy(time, posx, posy, velx, vely)
	posx, posy, velx, vely = estimate(time, posx, posy, velx, vely)
	return posy, vely
end

-- really useful estimate functions
function estimate_x_at_y(height, posx, posy, velx, vely, downward)
	downward = downward or true
	posx = posx or ballx()
	velx = velx or bspeedx()
	posy = posy or bally()
	vely = vely or bspeedy()

	-- we just use this as an early out to prevent needless calculation.
	-- what about the ball hitting the net top on its way down. might 
	-- make it possible to reach the destined hight.
	local time, time2 = ball_time_to_y(height, posx, posy, velx, vely)
	
	-- check that we found a valid solution
	if time == math.huge then
		return math.huge, math.huge, math.huge, math.huge, math.huge
	end
	
	time, posx, posy, velx, vely = simulate_until( posx, posy, velx, vely, "y", height )

	if vely > 0 and downward then
		local ot = time + 1
		posx, posy, velx, vely = simulate(1, posx, posy, velx, vely)
		time, posx, posy, velx, vely = simulate_until( posx, posy, velx, vely, "y", height )
		time = time + ot
	end
	
	return posx, velx, time, posy, vely
end

---------------------------------------------------------------------------------------------

-- this function is called every game step from the C++ api
__lastBallSpeed = nil
function __OnStep()
	ActiveMode = "game"

	__PERF_ESTIMATE_COUNTER = 0 -- count the calls to estimate!
	__bx, __by, __bvx, __bvy = __balldata()
	local original_bvx = __bvx
	-- add some random noise to the ball info, if we have difficulty enabled
	if __DIFFICULTY > 0 then
		__bx  = __bx + __ebx * __DIFFICULTY
		__by  = __by + __eby * __DIFFICULTY
		__bvx = __bvx + __ebvx * __DIFFICULTY
		__bvy = __bvy + __ebvy * __DIFFICULTY
	end
	
	if __lastBallSpeed == nil then __lastBallSpeed = original_bvx end
	
	-- if the x velocity of the ball changed, it bounced and we call the listener function
	if __lastBallSpeed ~= original_bvx and is_ball_valid() then
		__lastBallSpeed = original_bvx
		-- update the error variables
		local er = (math.random() + math.random()) * CONST_BALL_RADIUS
		local phi = 2*math.pi * math.random()
		__ebx = math.sin(phi) * er
		__eby = math.cos(phi) * er
		er = math.random() * 1.5 -- this would be about 10% error
		phi = 2*math.pi * math.random()
		__ebvx = math.sin(phi) * er
		__ebvy = math.cos(phi) * er
		
		-- debug data.
		if __DEBUG and is_game_running() and ballx() > CONST_FIELD_MIDDLE - CONST_BALL_RADIUS then
			local bounce = capture_situation_data()
			for i = 5, 2, -1 do
				__LastBounces[i] = __LastBounces[i-1]
			end
			__LastBounces[1] = bounce
		end
		
		if OnBounce then
			OnBounce()
		end
	end
	
	
	-- call the action functions
	if not is_game_running() then
		
		-- get the serving player. if NO_PLAYER, the ball is on the left.
		local server = get_serving_player()
		if server == NO_PLAYER then 
			server = LEFT_PLAYER
		end
		
		if __SIDE == server then
			OnServe( is_ball_valid() )
		else
			-- print last ball information when the opponent serves
			if __DEBUG then
				if not __OppServe then
					for k=1, #__LastBounces do
						print("step ", k)
						for i, v in pairs(__LastBounces[k]) do
							print(i, v)
						end
					end
					__OppServe = true
				end
			end
			
			--set_ball_data(587.4,415,-12.62, 3.58)
			--set_blob_data(0, 360, 360, 0, 0)
			--print( estimx( ) )
			
			if OnOpponentServe then
				OnOpponentServe()
			end
		end
	else
		__OppServe = false
		OnGame()
	end
	
	--print(__PERF_ESTIMATE_COUNTER)
end

-----------------------------------------------------------------------------------------------
-- helper functions

-- this function returns the first positive time that pos + vel*t + grav/2 * t² == destination. 
function parabola_time_first(pos, vel, grav, destination)
	local sq = vel^2 + 2*grav*(destination - pos);

	-- if unreachable, return inf
	if ( sq < 0 ) then
		return math.huge, math.huge
	end
	
	sq = math.sqrt(sq);
	
	local tmin = (-vel - sq) / grav;
	local tmax = (-vel + sq) / grav;
	
	if ( grav < 0 ) then
		tmin, tmax = tmax, tmin
	end

	if ( tmin > 0 ) then
		return tmin, tmax
	elseif ( tmax > 0 ) then
		return tmax, tmin
	else
		return math.huge, math.huge
	end
end

-- this function returns the first positive time that pos + vel*t  == destination. 
function linear_time_first(pos, vel, destination)
	assert(pos, "linear time first called with nil as position")
	if vel == 0 then
		return math.huge
	end
	local result = (destination - pos) / vel
	if result < 0 then
		return math.huge
	else 
		return result
	end
end

-- debug function: capture situational information
function capture_situation_data()
	local x, y, vx, vy = __balldata()
	local data = {}
	data['ballx'] = x
	data['bally'] = y
	data['bspeedx'] = vx
	data['bspeedy'] = vy
	data['posx'] = posx()
	data['posy'] = posy()
	data['touches'] = touches()
	return data
end
