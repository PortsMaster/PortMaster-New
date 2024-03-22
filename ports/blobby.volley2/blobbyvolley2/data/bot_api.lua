-- this file provides an intermediary layer between the very simplistic c++ lua api and the 
-- lua bot api that can be used to program blobby volley 2 bots.

-- legacy functions
-- these function definitions make lua functions for the old api functions, which are sometimes more convenient to use
-- than their c api equivalent.

function posx()
	local x, y = get_blob_pos( LEFT_PLAYER )
	return x
end

function posy()
	local x, y = get_blob_pos( LEFT_PLAYER )
	return y
end

function touches()
	return get_touches( LEFT_PLAYER )
end

-- redefine the ball coordinate functions to use the cached values
function ballx()
	local bx, by, vx, vy = balldata()
	return bx
end

function bally()
	local bx, by, vx, vy = balldata()
    return by
end

function bspeedx()
	local bx, by, vx, vy = balldata()
	return vx
end

function bspeedy()
	local bx, by, vx, vy = balldata()
	return vy
end

-- we need to save balldata somewhere to use it in here
__balldata = balldata
-- this is the internal function that does the side correction
function balldata()
	local x, y, vx, vy = __balldata()
	return x, y, vx, vy
end

-- redefine launched to refer to the own blobby
__launched = launched
function launched()
	return __launched( LEFT_PLAYER )
end

function left()
	__WANT_LEFT  = true
	__WANT_RIGHT = false
end

function right()
	__WANT_LEFT  = false
	__WANT_RIGHT = true
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
	local x, y = get_blob_pos( RIGHT_PLAYER )
	return x
end

function oppy()
	local x, y = get_blob_pos( RIGHT_PLAYER )
	return y
end

function getScore()
	return get_score( LEFT_PLAYER )
end

function getOppScore()
	return get_score( RIGHT_PLAYER )
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

function blob_time_to_y(destination)
	-- TODO allow specifying whether upward or downward!
	-- TODO error handling
	local blobby_pos = posy()
	-- if we are standing on the ground, assume we start jumping right now, otherwise
	-- use current vertical velocity
	local blobby_vel = speedy(LEFT_PLAYER)
	if blobby_pos == CONST_BLOBBY_GROUND_HEIGHT then
		blobby_vel = CONST_BLOBBY_JUMP
	end

	-- solve the quadratic equation
	local grav = CONST_BLOBBY_GRAVITY / 2    -- half, because we use jump buffer
	local t1, _ = parabola_time_first(blobby_pos, blobby_vel, grav, destination)
	return t1
end

-- checks whether a certain position can be reached by the blob in a certain time frame
-- currently, this function assumes that the blob is standing on the ground.
function can_blob_reach( time, blobx, posx, posy )
	local minx = blobx - CONST_BLOBBY_SPEED * time
	local maxx = blobx + CONST_BLOBBY_SPEED * time
	local maxy = -CONST_BLOBBY_GROUND_HEIGHT + CONST_BLOBBY_JUMP * time + CONST_BLOBBY_GRAVITY/2 * time^2
	local vel = -CONST_BLOBBY_JUMP + CONST_BLOBBY_GRAVITY * time
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

	local bx, by, bvx, bvy = balldata()
	local original_bvx = bvx
	
	if __lastBallSpeed == nil then __lastBallSpeed = original_bvx end
	
	-- if the x velocity of the ball changed, it bounced and we call the listener function
	if __lastBallSpeed ~= original_bvx and is_ball_valid() then
		__lastBallSpeed = original_bvx
		
		if OnBounce then
			OnBounce()
		end
	end
	
	
	-- call the action functions
	if not is_game_running() then
		
		-- get the serving player. if NO_PLAYER, the ball is on the left.
		local server = get_serving_player()
		if server == NO_PLAYER then
			if ballx() < CONST_FIELD_MIDDLE then
				server = LEFT_PLAYER
			end
		end
		
		if server == LEFT_PLAYER then
			OnServe( is_ball_valid() )
		elseif OnOpponentServe then
			OnOpponentServe()
		end
	else
		OnGame()
	end
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

------------------------------------------------------------------------------------------------------------------------
-- functions to emulate the old bot api
-----------------------------------------
--- Estimate ball position after `time`, ignoring any collisions
function simple_estimx(time)
	return ballx() + time * bspeedx()
end

--- Estimate ball position after `time`, ignoring any collisions
function simple_estimy(time)
	return bally() + time * bspeedy() + 0.5 * time^2 * CONST_BALL_GRAVITY
end

--- Estimate where the ball will hit the ground, ignoring any collisions.
function simple_estimate()
	local target = CONST_GROUND_HEIGHT + CONST_BALL_RADIUS
	local x, y, vx, vy = balldata()
	local d = vy * vy + 2.0 * CONST_BALL_GRAVITY * (target - y)
	if d < 0 then
		return x
	end
	local steps = (-vy - math.sqrt(d)) / CONST_BALL_GRAVITY
	return vx * steps + x
end

--- Overwrite the `estimx`, `estimy`, and `estimate` functions with their simple counterparts,
--- to restore old bot API behaviour. Also defines the old `debug` function, to just perform
--- printing.
function enable_legacy_functions()
	estimx = simple_estimx
    estimy = simple_estimy
	estimate = simple_estimate

	debug = function(x)
		print(x)
	end
end
