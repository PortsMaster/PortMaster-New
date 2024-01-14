-- this file provides an intermediary layer between the very simplistic c++ lua api and the 
-- lua bot api that can be used to program blobby volley 2 bots.

-- legacy functions
-- these function definitions make lua functions for the old api functions, which are sometimes more conveniente to use 
-- than their c api equivalent.

function posx( player )
	local x, y = get_blob_pos( player )
	return x
end

function posy( player )
	local x, y = get_blob_pos( player )
	return y
end

function touches( player )
	return get_touches( player )
end