local game_state = require('game_state')
local render = require('render')

local state
local render_tick = 0

local music
local music_modded

mod_music = function()
  music_modded = true
  music:setVolume(0.4)
  music:setPitch(0.9)
end

music_normal = function()
  music_modded = false
  music:setVolume(0.7)
  music:setPitch(1)
end


function love.load()
  render.setup()
  state = game_state.new()

  music = love.audio.newSource("/sfx/Spy.mp3", "stream")
  music:setLooping(true)
  music:play()
  music_normal()
end

--[[
function love.draw()
  if state then
    render.render_game(state, render_tick)
  end
end
]]

-- vertically center content patch (letter box top and bottom)
local constants = {
    screen_size = {16, 9}, -- For example
    tile_size = 32, -- For example
}
function love.draw()
  if state then
    local vertical_offset = (love.graphics.getHeight() - (constants.screen_size[2] * constants.tile_size * render.scale)) / 2
    love.graphics.push()
    love.graphics.translate(0, vertical_offset)
    render.render_game(state, render_tick)
    love.graphics.pop()
  end
end

function love.resize()

end

local function key_action(key)
  if key == "right" or key == "left" or key == "up" or key == "down" then
    game_state.move(state, key)
  elseif key == "z" then
    game_state.undo(state)
  elseif key == "r" then
    game_state.restart(state)
  elseif key == "return" or key == "7" then
    game_state.try_next(state, key == "7")
  end
end

local current_key = nil

function love.keypressed(key)
  if key == "right" or key == "left" or key == "up" or key == "down" or key == "z" or key == "r" or key == "return" or key == "7" then
    current_key = {key=key, ticks = 1}
    key_action(key)
  end
end

function love.keyreleased(key)
  if current_key and key == current_key.key then
    current_key = nil
  end
end


function love.mousemoved(x,y)

end

function love.wheelmoved(x,y)

end

function love.mousepressed(x,y,button)

end

function love.quit()

end

local fixed_update = function()
  render_tick = render_tick + 1

  if current_key then
    if current_key.ticks % 8 == 0 then
      key_action(current_key.key)
    end
    current_key.ticks = current_key.ticks + 1
  end

  local music_should_mod = false
  if state then
    local evaluated_state = game_state.evaluate(state)
    music_should_mod = evaluated_state.dead
  end

  if music_should_mod ~= music_modded then
    if music_should_mod then
      mod_music()
    else
      music_normal()
    end
  end
end

local accumulatedDeltaTime = 0
function love.update(deltaTime)
  accumulatedDeltaTime = accumulatedDeltaTime + deltaTime

  local tickTime = 1/60

  while accumulatedDeltaTime > tickTime do
    fixed_update()
    accumulatedDeltaTime = accumulatedDeltaTime - tickTime
  end
end
