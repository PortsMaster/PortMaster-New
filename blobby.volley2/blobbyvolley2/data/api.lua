-- this file provides an intermediary layer between the very simplistic c++ lua api and the 
-- lua api used by bots and rules.

-- derived constants that can be useful 
CONST_FIELD_MIDDLE		= CONST_FIELD_WIDTH / 2 						-- centre position

CONST_BLOBBY_GROUND_HEIGHT = CONST_GROUND_HEIGHT + CONST_BLOBBY_HEIGHT / 2

CONST_BALL_LEFT_BORDER	= CONST_BALL_RADIUS								-- minimum position of ball
CONST_BALL_RIGHT_BORDER	= CONST_FIELD_WIDTH - CONST_BALL_RADIUS			-- maximum position of ball

CONST_BALL_LEFT_NET		= CONST_FIELD_MIDDLE - CONST_BALL_RADIUS - CONST_NET_RADIUS
CONST_BALL_RIGHT_NET	= CONST_FIELD_MIDDLE + CONST_BALL_RADIUS + CONST_NET_RADIUS
CONST_BALL_TOP_NET		= CONST_NET_HEIGHT + CONST_BALL_RADIUS + CONST_NET_RADIUS

CONST_BALL_BLOBBY_HEAD = CONST_GROUND_HEIGHT + CONST_BLOBBY_HEIGHT + CONST_BALL_RADIUS
CONST_BLOBBY_MAX_JUMP  = CONST_BLOBBY_GROUND_HEIGHT + math.abs(CONST_BLOBBY_JUMP^2/CONST_BLOBBY_GRAVITY)

-- legacy functions
-- these function definitions make lua functions for the old api functions, which are sometimes more conveniente to use 
-- than their c api equivalent.

-- gets x coordinate of current ball position
function ballx()
	local x, y = get_ball_pos()
	return x
end

-- gets y coordinate of current ball position
function bally()
	local x, y = get_ball_pos()
	return y
end

-- gets x component of current ball velocity
function bspeedx()
	local x, y = get_ball_vel()
	return x
end

-- gets y component of current ball velocity
function bspeedy()
	local x, y = get_ball_vel()
	return y
end

-- gets x component of blobby speed
function speedx( player )
	local x, y = get_blob_vel( player )
	return x
end

-- gets y component of blobby speed
function speedy( player )
	local x, y = get_blob_vel( player )
	return y
end

-- returns whether blobby is in the air
function launched( player )
	local x, y = get_blob_pos( player )
	return y > CONST_BLOBBY_GROUND_HEIGHT
end

-- gets the opponent of the player identification, i.e. LEFT_PLAYER <-> RIGHT_PLAYER
function opponent( player ) 
	if player == LEFT_PLAYER then return RIGHT_PLAYER end
	if player == RIGHT_PLAYER then return LEFT_PLAYER end
	return -1
end

-- all combined
function balldata()
	-- need x,y vars to expand to two results
	local x, y = get_ball_pos()
	return x, y, get_ball_vel()
end

-- this function mirrors pos around mirror
function mirror(pos, mirror)
	return 2*mirror - pos
end

-------------------------------------------------------------------------------------
--   utilities

-- emulate ?: operator
function select(cond, a, b)
	if cond then
		return a
	end
	return b
end

function make_unsigned(num)
	if num >= 0 then
		return num
	else
		return math.huge
	end
end
