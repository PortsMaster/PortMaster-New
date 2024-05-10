local render = {}

local constants = require("constants")
local game_state = require("game_state")
local serpent = require('extern.serpent')

render._load_tex = function(path)
  local tex = love.graphics.newImage(path)
  tex:setFilter("nearest")
  return tex
end

render._load_anim = function(path, frames)
  local anim = {}
  for i=1,frames do
    table.insert(anim, render._load_tex(path .. i .. ".png"))
  end
  return anim
end

render.setup = function()
  render.tileset = render._load_anim("gfx/tileset", 3)
  render.instructions = render._load_tex("gfx/instructions.png")
  render.dead = render._load_tex("gfx/dead.png")
  render.next_level = render._load_tex("gfx/next_level.png")
  render.player_idle = render._load_anim("gfx/player_idle", 2)
  render.player_hang_beside = render._load_anim("gfx/player_hang_beside", 2)
  render.player_hang_above = render._load_anim("gfx/player_hang_above", 2)
  render.player_stand_and_hang = render._load_anim("gfx/player_stand_and_hang", 2)
  render.player_hang_in_pipe = render._load_anim("gfx/player_hang_in_pipe", 2)
  render.player_hang_over_pipe = render._load_anim("gfx/player_hang_over_pipe", 2)

  render.tileset_quads = {}

  local w
  local h
  w, h = render.tileset[1]:getDimensions()

  local idx = 0

  for y = 0, (h/constants.tile_size)-1 do
    for x = 0, (w/constants.tile_size)-1 do
      local quad = love.graphics.newQuad(x * constants.tile_size, y * constants.tile_size,
        constants.tile_size, constants.tile_size,
        render.tileset[1]:getDimensions()
      )

      render.tileset_quads[idx] = quad
      idx = idx + 1
    end
  end

  if love.system.getOS() == "Windows" then
    local ffi = require("ffi")
    ffi.cdef[[
    int SetProcessDPIAware();
    ]]

    ffi.C.SetProcessDPIAware()
  end

  local _, _, flags = love.window.getMode()
  local width, height = love.window.getDesktopDimensions(flags.display)

  local usable_width = width * 0.8
  local usable_height = height * 0.8

  local target_tile_size = constants.screen_size

  local size = {target_tile_size[1] * constants.tile_size, target_tile_size[2] * constants.tile_size}
  render.scale = 1

  while true do
    local next_size = {size[1] * (render.scale+1), size[2] * (render.scale+1)}

    if next_size[1] > usable_width or next_size[2] > usable_height then
      break
    end

    render.scale = render.scale + 1
  end

  love.window.setMode(size[1] * render.scale, size[2] * render.scale)
end

render._draw_tile = function(x, y, tile_index, render_tick)
  assert(render.tileset_quads[tile_index], ''..tile_index)

  local frame_time = math.floor(60 * 0.25)
  local total_anim_time = #render.tileset * frame_time
  local frame_index = math.floor((render_tick % total_anim_time) / frame_time) + 1

  love.graphics.draw(render.tileset[frame_index],
                     render.tileset_quads[tile_index],
                     x * constants.tile_size * render.scale,
                     y * constants.tile_size * render.scale,
                     0, render.scale, render.scale)
end

render._draw_on_tile = function(x, y, image, rotation_deg, flip)
  if rotation_deg == nil then rotation_deg = 0 end
  if flip == nil then flip = false end

  local scaleX = render.scale
  if flip then
    scaleX = scaleX * -1
  end

  love.graphics.draw(image,
                     (x + 0.5) * constants.tile_size * render.scale,
                     (y + 0.5) * constants.tile_size * render.scale,
                     rotation_deg * 0.01745329, scaleX, render.scale,
                     constants.tile_size/2, constants.tile_size/2)
end

render._draw_anim_on_tile = function(x, y, anim, flip, render_tick)
  local frame_time = math.floor(60 * 0.5)
  local total_anim_time = #anim * frame_time
  local frame_index = math.floor((render_tick % total_anim_time) / frame_time) + 1

  render._draw_on_tile(x, y, anim[frame_index], 0, flip)
end

render._draw_rect_on_tile = function(x, y)

  love.graphics.rectangle('fill',
                          x * constants.tile_size * render.scale,
                          y * constants.tile_size * render.scale,
                          constants.tile_size/4 * render.scale, constants.tile_size/4 * render.scale)
end

render._draw_debug_segments = function(state)
  local segments = game_state.calculate_segments(state)

  for index, segment in pairs(segments) do
    math.randomseed(index)
    love.graphics.setColor(math.random(), math.random(), math.random())

    for _, pos in pairs(segment) do
      render._draw_rect_on_tile(pos[1], pos[2]+1)
    end
  end

 love.graphics.setColor(1, 1, 1)
end

render._render_level = function(state, render_tick)
  local with_transitions = game_state.generate_transitions(state)

  for y = 0, state.height-1 do
    for x = 0, state.width-1 do
      render._draw_tile(x, y+1, game_state.index(state, x, y, with_transitions), render_tick)
    end
  end

  if state.dead then
    if render_tick % 60 < 30 then
      render._draw_on_tile(state.player_pos[1], state.player_pos[2], render.player_idle[1], 90)
    end
  else
    local animation = render.player_idle
    local flip = false

    local grip = game_state.has_grip(state)

    if grip.left and grip.right then
      animation = render.player_hang_in_pipe
    else
      if grip.on_solid_ground then
        if grip.beside then
          if grip.left then
            flip = true
          end
          animation = render.player_stand_and_hang
        end
      else
        if grip.beside then
          if grip.left then
            flip = true
          end
          animation = render.player_hang_beside
        elseif grip.below then
          if grip.below_left and grip.below_right then
            animation = render.player_hang_over_pipe
          else
            if grip.below_left then
              flip = true
            end
            animation = render.player_hang_above
          end
        end
      end
    end

    local draw_pos = {unpack(state.player_pos)}

    -- player sprite is 3 tiles wide, with the player in the middle, so we need to offset
    if flip then
      draw_pos[1] = draw_pos[1] + 1
    else
      draw_pos[1] = draw_pos[1] - 1
    end

    draw_pos[2] = draw_pos[2] + 1 -- offset for gui

    render._draw_anim_on_tile(draw_pos[1], draw_pos[2], animation, flip, render_tick)

    --love.graphics.setColor(1, 0, 0)
    --render._draw_rect_on_tile(state.player_pos[1], state.player_pos[2]+1)
    --love.graphics.setColor(1, 1, 1)
  end
end

render._render_gui = function(state, render_tick)
  local gui_row = 0
  for x=1,constants.screen_size[1]-2 do
    render._draw_tile(x, gui_row, constants.gui_middle_tile, render_tick)
  end
  render._draw_tile(0, gui_row, constants.gui_left_tile, render_tick)
  render._draw_tile(constants.screen_size[1]-1, gui_row, constants.gui_right_tile, render_tick)

  if state.level_index > 1 then
    render._draw_on_tile(0, gui_row, render.instructions)

    if state.dead and render_tick % 60 < 30 then
      render._draw_on_tile(16, gui_row, render.dead)
    end

    if state.win and render_tick % 60 < 30 then
      render._draw_on_tile(14, gui_row, render.next_level)
    end

    local score_start = 30
    if state.original_loot < 10 then
      render._draw_tile(score_start, gui_row+4/16, constants.number_tiles[state.original_loot - state.loot+1], render_tick)
      render._draw_tile(score_start+5/16, gui_row+4/16, constants.slash_tile, render_tick)
      render._draw_tile(score_start+11/16, gui_row+4/16, constants.number_tiles[state.original_loot+1], render_tick)
    else
      render._draw_tile(score_start+8/16, gui_row+4/16, constants.exclamations, render_tick)
    end
    render._draw_tile(score_start+1, gui_row+4/16, constants.coin_gui, render_tick)
  end
end

render.render_game = function(state, render_tick)
  local evaluated_state = game_state.evaluate(state)
  if evaluated_state.dead then
    love.graphics.setColor(1, 0, 0)
  else
    love.graphics.setColor(1, 1, 1)
  end

  love.graphics.clear(16/255, 25/255, 28/255)
  render._render_level(evaluated_state, render_tick)
  render._render_gui(evaluated_state, render_tick)

  --render._draw_debug_segments(evaluated_state)
end

return render