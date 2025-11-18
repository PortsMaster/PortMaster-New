local Game = require "classes/game"
local Input = require "classes/input"
local Console = require "classes/console/console"

require "libraries/util"
require "libraries/pico8funcs"
require "libraries/shaders"

function love.load()
	lg.setDefaultFilter("nearest")
	lg.setLineStyle("rough")

	-- init canvas
	CANVAS_WIDTH = 144
	CANVAS_HEIGHT = 192
	RENDER_SCALE = 4
	canvas = lg.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
	full_canvas = lg.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	-- Apparently web exports are a bit broken, refer back to clever leo for this one
	if OPERATING_SYSTEM == "Web" then
		-- ignore for now
	else
		-- Init window
		love.window.setMode(CANVAS_WIDTH * RENDER_SCALE, CANVAS_HEIGHT * RENDER_SCALE, {
			resizable = true,
			minwidth  = CANVAS_WIDTH,
			minheight = CANVAS_HEIGHT,
		})
		SCREEN_WIDTH, SCREEN_HEIGHT = lg.getDimensions()
		love.window.setTitle("Bullet Hell Jam 5")
	end

	FONT_MAIN = lg.newFont("graphics/fonts/ChevyRay-Express.ttf", 9)
	FONT_MAIN:setFilter("nearest", "nearest")
	FONT_CONSOLE = lg.newFont("graphics/fonts/ChevyRay-Express.ttf", 9)
	FONT_CONSOLE:setFilter("nearest", "nearest")
	FONT_PICO = lg.newFont("graphics/fonts/PICO-8_mono.ttf", 4)
	FONT_PICO:setFilter("nearest", "nearest")

	PALLETE = generate_palette("graphics/palette/pico-8-palette.png")

	CONSOLE = Console:new()
	INPUT = Input:new()
	GAME = Game:new()

	DO_CRT_FILTER = false

	-- shader_simple_crt = lg.newShader(simple_crt_v2)
	-- shader_simple_scan = lg.newShader(simple_scanlines)
end

t = 0			-- time
frm = 0			-- current frame
function love.update(dt)
	t = t + dt
	frm = frm + 1
	delta_time = dt * CONSOLE:get("gm_speed")

	INPUT:update()
	GAME:update()
end

function love.draw()
	--classic_draw()
	custom_draw()
end

function classic_draw()
	lg.setCanvas({ canvas, stencil = true })
	lg.clear(BLACK)
	lg.translate(0, 0)

	GAME:draw()
	lg.setColour(WHITE)

	if DO_CRT_FILTER then
		-- create new canvas and draw game canvas onto it so that scanline effects work
		-- local scanline_canvas = lg.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
		-- lg.setCanvas(scanline_canvas)
		-- lg.setShader(shader_simple_scan)
		-- lg.draw(canvas, 0, 0, 0, 1, 1)
		-- lg.setShader()
		--
		-- lg.origin()
		-- lg.scale(1, 1)
		--
		-- lg.setCanvas()
		-- lg.setShader(shader_simple_crt)
		-- shader_simple_crt:send("curvature", CONSOLE:get("sh_curvature"))
		-- lg.draw(scanline_canvas, 0, 0, 0, RENDER_SCALE, RENDER_SCALE)
		-- lg.setShader()
	else
		lg.setCanvas()
		lg.draw(canvas, 0, 0, 0, RENDER_SCALE, RENDER_SCALE)
	end

	lg.setColour(WHITE)
	lg.setFont(FONT_MAIN)

	local debug_text = flr(1 / delta_time)
	lg.print(debug_text, 5, 5)

	lg.setFont(FONT_PICO)
	CONSOLE:draw()
end

------------------------------------------------OVERHAULED SCALING CODE

function custom_draw()
	-- 1) draw game to internal canvas
	lg.setCanvas(canvas)
	lg.clear(BLACK)
	GAME:draw()
	lg.setColour(WHITE)
	lg.setCanvas() -- back to screen

	-- 2) get current window size (this changes when you resize!)
	local screenW, screenH = lg.getDimensions()
	local canvasW, canvasH = CANVAS_WIDTH, CANVAS_HEIGHT

	-- always: scale-to-height
	local scale = screenH / canvasH
	local drawW = canvasW * scale
	local x = (screenW - drawW) / 2

	if tate then
		-- rotated 90°: height/width swapped
		local rot_scale = screenH / canvasW
		local rot_drawW = canvasH * rot_scale
		local rot_x = (screenW - rot_drawW) / 2

		lg.draw(
			canvas,
			math.floor(rot_x),
			0,
			math.pi / 2,
			rot_scale,
			rot_scale
		)
	else
		-- normal
		lg.draw(
			canvas,
			math.floor(x),
			0,
			0,
			scale,
			scale
		)
	end
end

