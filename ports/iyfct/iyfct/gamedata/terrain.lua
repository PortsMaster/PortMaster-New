front_x = 0
back_x = 0

back_terrain = love.graphics.newQuad(0,112,300,94,512,512)
front_terrain = love.graphics.newQuad(0,224,300,94,512,512)
track_quad = love.graphics.newQuad(0,48,121,5,128,128)

function updateTerrain(dt)
	front_x = (front_x + 65*dt) % WIDTH
	back_x = (back_x + 40*dt) % WIDTH
end

function drawTerrain()
	love.graphics.draw(imgTerrain,back_terrain,0-back_x,0)
	love.graphics.draw(imgTerrain,back_terrain,WIDTH-back_x,0)
	love.graphics.draw(imgTerrain,front_terrain,0-front_x,0)
	love.graphics.draw(imgTerrain,front_terrain,WIDTH-front_x,0)
end

function updateTracks(dt)
	track_frame = track_frame + global_speed * dt * TRACK_SPEED
	if track_frame >= 11 then
		track_frame = track_frame % 11
	end
end

function drawTracks()
	for i=0,2 do
		love.graphics.draw(imgSprites,track_quad,i*121 - track_frame,92)
	end
end
