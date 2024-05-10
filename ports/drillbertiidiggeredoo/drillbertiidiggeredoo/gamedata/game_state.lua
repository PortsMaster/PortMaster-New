local game_state = {}

local constants = require("constants")
local serpent = require("extern.serpent")


local move_sfx = love.audio.newSource("/sfx/SFX_Jump_09.wav", "static")
local drill_sfx = love.audio.newSource("/sfx/drill.wav", "static")
local level_complete_sfx = love.audio.newSource("/sfx/level_complete.wav", "static")
local error_sfx = love.audio.newSource("/sfx/error_006.wav", "static")
local die_sfx = love.audio.newSource("/sfx/15_hit.wav", "static")
local restart_sfx = love.audio.newSource("/sfx/13_item1.wav", "static")
local coin_sfx = love.audio.newSource("/sfx/coin1.wav", "static")


local levels = {
  --require('levels.test').layers[1],

  require('levels.title').layers[1],
  require('levels.teach_move_basic').layers[1],
  require('levels.teach_need_coins').layers[1],
  require('levels.teach_dig').layers[1],
  require('levels.teach_climb_gap').layers[1],
  require('levels.drop_block_path').layers[1],
  require('levels.teach_dig2').layers[1],
  require('levels.drop_stalactite').layers[1],
  require('levels.extra2').layers[1],
  require('levels.winner').layers[1],
  require('levels.challenge2').layers[1],
  require('levels.challenge').layers[1],
  require('levels.real_winner').layers[1],
}


game_state.slice = function(tbl, count)
  local sliced = {}

  for _, val in pairs(tbl) do
    if count > 0 then
      table.insert(sliced, val)
    end
    count = count - 1
  end

  return sliced
end

game_state.deepcopy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[game_state.deepcopy(orig_key)] = game_state.deepcopy(orig_value)
        end
        setmetatable(copy, game_state.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

game_state.new = function()
  local state = {
    width = 0,
    height = 0,
    data = 0,
    player_pos = {0, 0},
    loot = 0,
    moves = {},
    level_index = 0,
  }

  game_state.load_level(state, 1)

  return state
end

game_state.load_level = function(state, level_index)
  local level_data = levels[level_index]

  state.width = level_data.width
  state.height = level_data.height
  state.data = {unpack(level_data.data)}
  state.loot = 0
  state.original_loot = 0
  state.moves = {}
  state.level_index = level_index

  for y = 0, level_data.height-1 do
    for x = 0, level_data.width-1 do
      local tile = game_state.index(state, x, y)
      if tile == constants.spawn_tile_id then
        state.player_pos = {x, y}
        game_state._set(state, x, y, constants.air_tile_id)
      elseif tile == constants.loot_tile_id then
        state.loot = state.loot + 1
      end
    end
  end

  state.original_loot = state.loot

  game_state._eval_cache = {}
end

game_state.index = function(level_data, x, y, data)
  if data == nil then data = level_data.data end

  assert(x >= 0 and x < level_data.width)
  assert(y >= 0 and y < level_data.height)

  local index = (x + y * level_data.width) + 1
  return data[index] - 1
end

game_state._set = function(level_data, x, y, tile_id, data)
  if data == nil then data = level_data.data end

  assert(tile_id ~= nil)
  assert(x >= 0 and x < level_data.width)
  assert(y >= 0 and y < level_data.height)

  local index = (x + y * level_data.width) + 1
  data[index] = tile_id + 1
end

game_state._eval_cache = {}

game_state.evaluate = function(state)
  local evaluate_recursive
  evaluate_recursive = function(moves)
    local cache_key = table.concat(moves, ',')

    if game_state._eval_cache[cache_key] then
      return game_state.deepcopy(game_state._eval_cache[cache_key])
    end

    if #moves == 0 then
      return
      {
        width = state.width,
        height = state.height,
        data = {unpack(state.data)},
        player_pos = {unpack(state.player_pos)},
        dead = false,
        win = false,
        loot = state.loot,
        original_loot = state.loot,
        level_index = state.level_index,
      }
    end

    local tails = game_state.slice(moves, #moves - 1)
    local evaluated = evaluate_recursive(tails)
    local direction = moves[#moves]

    evaluated.sfx = move_sfx

    if evaluated.dead or evaluated.win then
      return nil
    end

    local move = {0, 0}

    if direction == "right" then
      move[1] = 1
    elseif direction == "left" then
      move[1] = -1
    elseif direction == "down" then
      move[2] = 1
    elseif direction == "up" then
      move[2] = -1
    end

    local grip = game_state.has_grip(evaluated)
    if direction == "up" and not grip.beside then
      return nil
    end

    local on_solid_ground = game_state._coord_valid(evaluated, evaluated.player_pos[1], evaluated.player_pos[2] + 1) and game_state._tile_is_solid(game_state.index(evaluated, evaluated.player_pos[1], evaluated.player_pos[2] + 1))

    -- don't allow jumping off a wall hang
    if (direction == "left" and not grip.below_left and not on_solid_ground) or
       (direction == "right" and not grip.below_right and not on_solid_ground)
    then
      return nil
    end

    evaluated.player_pos[1] = evaluated.player_pos[1] + move[1]
    evaluated.player_pos[2] = evaluated.player_pos[2] + move[2]

    if not game_state._coord_valid(evaluated, evaluated.player_pos[1], evaluated.player_pos[2]) then
      return nil
    end

    local target_tile_id = game_state.index(evaluated, evaluated.player_pos[1], evaluated.player_pos[2])

    -- Digging
    local dug = false
    if game_state._tile_is_solid(target_tile_id) then
      if target_tile_id == constants.dirt_tile_id then
        dug = true
        evaluated.sfx = drill_sfx
        game_state._set(evaluated, evaluated.player_pos[1], evaluated.player_pos[2], constants.deleted_placeholder_tile)
      else
        return nil
      end
    end

    if target_tile_id == constants.loot_tile_id then
      game_state._set(evaluated, evaluated.player_pos[1], evaluated.player_pos[2], constants.air_tile_id)
      evaluated.loot = evaluated.loot - 1
      evaluated.sfx = coin_sfx
    end

    if target_tile_id == constants.level_end_tile_id and evaluated.loot == 0 then
      evaluated.win = true
      evaluated.sfx = level_complete_sfx
    end

    ---- special case for walking down stairs
    --if not dug and (direction == "left" or direction == "right") and
    --   game_state._coord_valid(evaluated, evaluated.player_pos[1], evaluated.player_pos[2] + 1) and not game_state._tile_is_solid(game_state.index(evaluated, evaluated.player_pos[1], evaluated.player_pos[2] + 1)) and
    --   game_state._coord_valid(evaluated, evaluated.player_pos[1], evaluated.player_pos[2] + 2) and game_state._tile_is_solid(game_state.index(evaluated, evaluated.player_pos[1], evaluated.player_pos[2] + 2))
    --then
    --  evaluated.player_pos[2] = evaluated.player_pos[2] + 1
    --end

    game_state._try_drop_rocks(evaluated)

    while true do
      if (evaluated.player_pos[2] + 1) >= evaluated.height then
        evaluated.dead = true
        evaluated.sfx = die_sfx
        break
      end

      if game_state._tile_is_solid(game_state.index(evaluated, evaluated.player_pos[1], evaluated.player_pos[2] + 1)) then break end

      local new_grip = game_state.has_grip(evaluated)
      if new_grip.beside or new_grip.below then
        break
      end

      evaluated.player_pos[2] = evaluated.player_pos[2] + 1
    end


    for y = 0, evaluated.height-1 do
      for x = 0, evaluated.width-1 do
        local tile_id = game_state.index(evaluated, x, y)
        if tile_id == constants.deleted_placeholder_tile then
          game_state._set(evaluated, x, y, constants.air_tile_id)
        end
      end
    end

    if game_state._tile_is_solid(game_state.index(evaluated, evaluated.player_pos[1], evaluated.player_pos[2])) then
      evaluated.dead = true
      evaluated.sfx = die_sfx
    end

    game_state._eval_cache[cache_key] = game_state.deepcopy(evaluated)

    return evaluated
  end

  return evaluate_recursive(state.moves)
end

game_state.calculate_segments = function(state)
  local assignments = {}
  local next_id = 0

  local assigned

  for y = 0, state.height-1 do
    for x = 0, state.width-1 do
      local tile_id = game_state.index(state, x, y)

      assigned = nil
      if x > 0 then
        if tile_id == game_state.index(state, x - 1, y) then
          assigned = assignments[(x-1) .. ',' .. y].id
        end
      end

      if y > 0 then
        if tile_id == game_state.index(state, x, y - 1) then
          local new_assigned = assignments[x .. ',' .. (y-1)].id

          if assigned ~= nil and assigned ~= new_assigned then
            for key, value in pairs(assignments) do
              if value.id == assigned then
                assignments[key].id = new_assigned
              end
            end
          end

          assigned = new_assigned
        end
      end

      if assigned == nil then
        assigned = next_id
        next_id = next_id + 1
      end

      assignments[x .. ',' .. y] = {pos = {x, y}, id = assigned}
    end
  end

  local buckets_by_id = {}
  for key, value in pairs(assignments) do
    if buckets_by_id[value.id] == nil then
      buckets_by_id[value.id] = {}
    end

    buckets_by_id[value.id][key] = value.pos
  end

  local final_buckets = {}
  for _, bucket in pairs(buckets_by_id) do
    table.insert(final_buckets, bucket)
  end

  return final_buckets
end




game_state._try_drop_rocks = function(state)
  local did_move = true

  while did_move do
    did_move = false

    local segments = game_state.calculate_segments(state)

    local segment_tiles = {}
    -- we need to precalculate this because they might change as we move segments
    for seg_index, segment in pairs(segments) do
      for _, point in pairs(segment) do
        segment_tiles[seg_index] = game_state.index(state, point[1], point[2])
        break
      end
    end


    -- CALC CANT FALL
    -----------------

    local cant_fall = {}

    local tile_id_can_fall = function(tile_id)
      return (game_state._tile_is_solid(tile_id) or tile_id == constants.loot_tile_id or tile_id == constants.level_end_tile_id) and
             tile_id ~= constants.deleted_placeholder_tile
    end

    local cant_fall_changed = true
    while cant_fall_changed do
      cant_fall_changed = false

      for segment_index, _ in pairs(segments) do
        if cant_fall[segment_index] ~= nil then
          goto continue
        end

        local segment_tile = segment_tiles[segment_index]

        if not tile_id_can_fall(segment_tile) then
          cant_fall[segment_index] = 1
          cant_fall_changed = true
          goto continue
        end

        for _, point in pairs(segments[segment_index]) do
          -- attached to edge can't fall
          if point[1] == 0 or point[1] == (state.width-1) or point[2] == 0 or point[2] == (state.height-1) then
            cant_fall[segment_index] = 1
            cant_fall_changed = true
            goto continue
          end


          -- find the segment of the block underneath us
          local segment_index_under_us = nil
          local block_under_us_key = point[1] .. ',' .. (point[2] + 1)
          for seg2_index, seg2 in pairs(segments) do
            if seg2[block_under_us_key] ~= nil then
              segment_index_under_us = seg2_index
              break
            end
          end
          assert(segment_index_under_us)



          if segment_index_under_us ~= segment_index and
             game_state._tile_is_solid(segment_tiles[segment_index_under_us]) and
             cant_fall[segment_index_under_us] ~= nil
          then
            cant_fall[segment_index] = 1
            cant_fall_changed = true
            goto continue
          end
        end

        ::continue::
      end
    end


    -- DO  FALL
    -----------

     for seg_index, segment in pairs(segments) do
      local segment_tile = segment_tiles[seg_index]
      -- clear out the current shape
      for _, point in pairs(segment) do
        game_state._set(state, point[1], point[2], constants.air_tile_id)
      end
    end

    for seg_index, segment in pairs(segments) do
      local segment_tile = segment_tiles[seg_index]

      if segment_tile ~= constants.air_tile_id then
        local offset = 0
        if cant_fall[seg_index] == nil then
          offset = 1
          did_move = true
        end

        -- and repaint
        for _, point in pairs(segment) do
          --assert(game_state.index(state, point[1], point[2]+offset) == constants.air_tile_id)
          if not game_state._tile_is_solid(game_state.index(state, point[1], point[2]+offset)) then
            game_state._set(state, point[1], point[2]+offset, segment_tile)

            -- push the player down if we are pressing on top of him and there is free space below
            if offset == 1 and
               point[1] == state.player_pos[1] and point[2] + 1 == state.player_pos[2] and
               point[2] + 2 < state.height and not game_state._tile_is_solid(game_state.index(state, point[1], point[2] + 2))
            then
              state.player_pos[2] = state.player_pos[2] + 1
            end
          end
        end
      end
    end

  end
end

game_state._direction_to_vector = function(direction)
  local move = {0, 0}

  if direction == "right" then
    move[1] = 1
  elseif direction == "left" then
    move[1] = -1
  elseif direction == "down" then
    move[2] = 1
  elseif direction == "up" then
    move[2] = -1
  end

  return move
end

game_state._tile_is_solid = function(tile_id)
  return tile_id ~= constants.air_tile_id and tile_id ~= constants.loot_tile_id and tile_id ~= constants.level_end_tile_id
end

game_state._coord_valid = function(state, x, y)
  return x >= 0 and x < state.width and y >= 0 and y < state.height
end

game_state.has_grip = function(state_evaluated)
  local grip_at_offset = function(offX, offY)
    local x = state_evaluated.player_pos[1] + offX
    local y = state_evaluated.player_pos[2] + offY

    return x >= 0 and x < state_evaluated.width and y >= 0 and y < state_evaluated.height and game_state._tile_is_solid(game_state.index(state_evaluated, x, y))
  end

  local result = {
    left = grip_at_offset(-1, 0),
    right = grip_at_offset(1, 0),
    below_left = grip_at_offset(-1, 1),
    below_right = grip_at_offset(1, 1),
    on_solid_ground = grip_at_offset(0, 1),
  }

  result.beside = result.left or result.right
  result.below = result.below_left or result.below_right

  return result
end

game_state.move = function(state, direction)
  if state.level_index == 1 then
    return
  end

  if game_state.evaluate(state).win then
    return
  end

  table.insert(state.moves, direction)

  local new_state = game_state.evaluate(state)
  if not new_state then
    error_sfx:clone():play()
    table.remove(state.moves, #state.moves)
  elseif new_state.sfx then
    new_state.sfx:clone():play()
  end
  --print(serpent.line(state.moves))
end

game_state.undo = function(state)
  if state.level_index == 1 then
    return
  end

  if #state.moves > 0 then
    table.remove(state.moves, #state.moves)
    restart_sfx:clone():play()
    --print(serpent.line(state.moves))
  end
end

game_state.restart = function(state)
  if state.level_index == 1 then
    return
  end

  game_state.load_level(state, state.level_index)
  restart_sfx:clone():play()
end

game_state.try_next = function(state, force)
  if game_state.evaluate(state).win or force or state.level_index == 1 then
    local next_level_id = state.level_index + 1
    if next_level_id <= #levels then
      game_state.load_level(state, next_level_id)
    end
  end
end


game_state.generate_transitions = function(state)
  local tilesets =
  {
    {
      orig_tile = constants.dirt_tile_id,
      transitions = constants.dirt_transitions,
    },
    {
      orig_tile = constants.rock_1_tile_id,
      transitions = constants.bedrock_transitions,
    },
    {
      orig_tile = constants.rock_2_tile_id,
      transitions = constants.bedrock_transitions,
    },
    {
      orig_tile = constants.rock_3_tile_id,
      transitions = constants.bedrock_transitions,
    }
  }

  local with_transitions = { unpack(state.data)}


  for _, tileset in pairs(tilesets) do
    local get = function(x, y)
      if x < 0 or x >= state.width or y < 0 or y >= state.height then
        return "1"
      end

      local tile = game_state.index(state, x, y)
      if tile == tileset.orig_tile then
        return "1"
      end

      return "0"
    end

    for y = 0, state.height-1 do
      for x = 0, state.width-1 do
        local tile = game_state.index(state, x, y)
        if tile == tileset.orig_tile then
          local key = get(x,y-1) .. get(x,y+1) .. get(x-1,y) .. get(x+1,y)
          game_state._set(state, x, y, tileset.transitions[key], with_transitions)
        end
      end
    end
  end

  return with_transitions
end

return game_state