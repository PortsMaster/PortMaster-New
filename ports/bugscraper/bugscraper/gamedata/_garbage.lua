-- This file is for functions, classes that are unused but I figure
-- I might have an use for later on. 

--

	-- Elevator swing  >> in Game:update_main_game
	if love.math.random(0,10) == 0 then
		self.elev_vx = random_neighbor(50)
		self.elev_vy = random_range(0, 50)
	end
	self.elev_vx = self.elev_vx * 0.9
	self.elev_vy = self.elev_vy * 0.9
	self.elev_x = self.elev_x + self.elev_vx*dt
	self.elev_y = self.elev_y + self.elev_vy*dt
	self.elev_x = self.elev_x * 0.9
	self.elev_y = self.elev_y * 0.9


-- Player mine and cursor
function Player:update_cursor(dt)
	local old_cu_x = self.cu_x
	local old_cu_y = self.cu_y

	local tx = floor(self.mid_x / BLOCK_WIDTH) 
	local ty = floor(self.mid_y / BLOCK_WIDTH) 
	local dx, dy = 0, 0

	-- Target up and down 
	local btn_up = self:button_down("up")
	local btn_down = self:button_down("down")
	if btn_up or btn_down then
		dx = 0
		if btn_up then    dy = -1    end
		if btn_down then  dy = 1     end
	else
		-- By default, target sideways
		dx = self.dir_x
	end

	-- Update target position
	self.cu_x = tx + dx
	self.cu_y = ty + dy

	-- Update target tile
	local target_tile = game.map:get_tile(self.cu_x, self.cu_y)
	self.cu_target = nil
	if target_tile and target_tile.is_solid then
		self.cu_target = target_tile
	end
	
	-- If changed cursor pos, reset cursor
	if (old_cu_x ~= self.cu_x) or (old_cu_y ~= self.cu_y) then
		self.mine_timer = 0
	end
end

function Player:mine(dt)
	if not self.cu_target then   return    end
	
	if self:button_down("shoot") then
		self.mine_timer = self.mine_timer + dt

		if self.mine_timer > self.cu_target.mine_time then
			local drop = self.cu_target.drop
			game.map:set_tile(self.cu_x, self.cu_y, 0)
			--game.inventory:add_item(drop)
		end
	else
		self.mine_timer = 0
	end
end

------------------------------------

-- Elevator speed depends on number of enemies
-- In Game:progress_elevator
local enemies_killed = max(self.cur_wave_max_enemy - self.enemy_count, 0)
local ratio_killed = clamp(enemies_killed / self.cur_wave_max_enemy, 0, 1)
local speed = self.max_elev_speed * ratio_killed
self.elevator_speed = speed

-- Terraria-like world generation
for ix=0, map_w-1 do
	-- Big hill general shape
	local by1 = noise(seed, ix / 7)
	by1 = by1 * 4

	-- Small bumps and details
	local by2 = noise(seed, ix / 3)
	by2 = by2 * 1

	local by = map_mid_h + by1 + by2
	by = floor(by)
	print(concat("by ", by))

	for iy = by, map_h-1 do
		map:set_tile(ix, iy, 1)
	end
end


function Player:is_pressing_opposite_to_wall()
	-- Returns whether the player is near a wall AND is pressing a button
	-- corresponding to the opposite direction to that wall
	-- FIXME: there's a lot of repetition, find a way to fix this?
	local null_filter = function()
		return "cross"
	end
	collision:move(self.wall_collision_box, self.x, self.y, null_filter)
	
	-- Check for left wall
	local nx = self.x - self.wall_jump_margin 
	local x,y, cols, len = collision:move(self.wall_collision_box, nx, self.y, null_filter)
	for _,col in pairs(cols) do
		if col.other.is_solid and col.normal.x == 1 and self:button_down("right") then
			print("WOW", love.math.random(10,100))
			return true, 1
		end
	end

	-- Check for right wall
	local nx = self.x + self.wall_jump_margin 
	local x,y, cols, len = collision:move(self.wall_collision_box, nx, self.y, null_filter)
	for _,col in pairs(cols) do
		if col.other.is_solid and col.normal.x == -1 and self:button_down("left")then
			return true, -1
		end
	end

	return false, nil
end