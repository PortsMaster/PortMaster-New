local Class = require "class"
local Game = require "game"
require "util"

game = nil

function love.load(arg)
	frame = 0

	game = Game:new()
end

t = 0
fdt = 1/60 -- fixed frame delta time
frm = 0
local function fixed_update()
	--update that happens at the fixed fdt interval
	frm = frm + 1
	game:update(fdt)
	-- if frm % 2 == 0 and CAPTURING_GIF then
	-- 	love.graphics.captureScreenshot("gif"..tostring(gif_n).."_"..tostring(floor(frm/2))..".png")
	-- end
end

function love.update(dt)
	t = t + dt
	local cap = 1 --If theres lag spike, repeat up to how many frames?
	local i = 0
	while t > fdt and cap > 0 do
		t = t - fdt
		fixed_update()
		cap = cap - 1
		i=i+1
	end

	-- if t > 0 then    t = 0    end
	if game then   game.frame_repeat = i end
	frame = frame + 1
end

function love.draw()
	game:draw()
end

CAPTURING_GIF = false
gif_n = 0
function love.keypressed(key, scancode, isrepeat)
	if key == "f5" then
		if love.keyboard.isDown("lshift") then
			love.event.quit("restart")
		end

	elseif key == "f4" then
		if love.keyboard.isDown("lshift") then
			love.event.quit()
		end
	-- elseif key == "f7" then
	-- 	love.graphics.captureScreenshot(os.time() .. ".png")
	-- elseif key == "f8" then
	-- 	CAPTURING_GIF = not CAPTURING_GIF
	-- 	gif_n = gif_n + 1

	elseif key == "f11" then
		if options then   options:toggle_fullscreen()    end

	-- elseif key == "m" then
	-- 	options:toggle_sound()
		
	-- elseif key == "g" then
	-- 	game.players[1]:kill()

	-- elseif key == "e" then
	-- 	if not game then return end
	-- 	for i,e in pairs(game.actors) do
	-- 		if e.is_enemy then
	-- 			e:kill()
	-- 		end
	-- 	end
	-- 	game.floor = 998
		-- game:on_red_button_pressed()

	-- elseif key == "b" then
	-- 	if not game then return end
	-- 	local Enemies = require "data.enemies"
	-- 	local nx = CANVAS_WIDTH/2
	-- 	local ny = game.world_generator.box_by * BLOCK_WIDTH
	-- 	local l = create_actor_centered(Enemies.ButtonGlass, nx, ny)
	-- 	game:new_actor(l)

	-- elseif key == "k" then
	-- 	if not game then return end
	-- 	for i,e in pairs(game.actors) do
	-- 		if e.is_enemy then
	-- 			e:kill()
	-- 		end
	-- 	end

	end

	if game.keypressed then  game:keypressed(key, scancode, isrepeat)  end
end

function love.keyreleased(key, scancode)
	if game.keyreleased then  game:keyreleased(key, scancode)  end
end

function love.mousepressed(x, y, button, istouch, presses)
	if game.mousepressed then   game:mousepressed(x, y, button)   end
end

--function love.quit()
--	game:quit()
--end

function love.resize(w, h)
	if not game then     return     end
	if game.resize then   game:resize(w,h)   end
	game:update_screen()
end

function love.textinput(text)
	if game.textinput then  game:textinput(text)  end
end

function love.focus(f)
	if f then
	else
		if options:get("pause_on_unfocus") and game.menu then
			game.menu:pause()
		end
	end
end

-- function love.textinput( text )
-- 	if not game then return end

-- 	game:textinput(text)
-- end

print_log_file = love.filesystem.newFile("consolelog.txt")
print_log_file:open("w")
print_log_file:write("")
print_log_file:close()

max_msg_log = 20
old_print = print
msg_log = {}
function print(...)
	print_log_file:open("a")

	old_print(...)
	
	local text = concatsep({...}, " ")
	table.insert(msg_log, text)
	print_log_file:write(concat(os.date("%c", os.time())," | ",text,"\n"))
	
	if #msg_log > max_msg_log then
		table.remove(msg_log, 1)
	end

	print_log_file:close()
end

function quit_game()
	print("Quitting game")
	if options then   options:on_quit()   end
	love.event.quit()
end
