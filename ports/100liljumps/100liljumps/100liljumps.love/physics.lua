require("./math")
require("./tile_map")

function check_for_crushing(game_state)
    local player_hitbox = game_state.player:hitbox()
    local player_size = TILE_SIZE
    -- player tiles
    local left_x   = math.floor( game_state.player.pos.x / TILE_SIZE )
    local right_x  = math.floor( ( game_state.player.pos.x + player_size ) / TILE_SIZE )
    local bottom_y = math.floor( ( game_state.player.pos.y + player_size ) / TILE_SIZE )

    local out_of_map_by_left = left_x <= 0
    local out_of_map_by_right = right_x > (#game_state.tile_map.tiles[1] - 1)
    local out_of_map_by_bottom = bottom_y > (#game_state.tile_map.tiles - 1)

    -- left/right tiles
    local left_tile = nil
    local right_tile = nil
    if not out_of_map_by_bottom then
        if not out_of_map_by_left then
            left_tile = game_state.tile_map.tiles[bottom_y + 1][left_x + 1]
        end
        if not out_of_map_by_right then
            right_tile = game_state.tile_map.tiles[bottom_y + 1][right_x + 1]
        end
    end

    local left_tile_top_left      = V2(left_x*TILE_SIZE, bottom_y*TILE_SIZE)
    local left_tile_bottom_right  = V2(right_x*TILE_SIZE - 1, (bottom_y + 1)*TILE_SIZE - 1)
    local right_tile_top_left     = V2(right_x*TILE_SIZE, bottom_y*TILE_SIZE)
    local right_tile_bottom_right = V2((right_x + 1)*TILE_SIZE, (bottom_y + 1)*TILE_SIZE - 1)

    local left_tile_hitbox = Rectangle(left_tile_top_left, left_tile_bottom_right)
    local right_tile_hitbox = Rectangle(right_tile_top_left, right_tile_bottom_right)

    if( left_tile and Tile.is_solid_tile(left_tile) and check_rect_rect_collision(game_state.player:hitbox(), left_tile_hitbox)) then
        return true
    end
    if( right_tile and Tile.is_solid_tile(right_tile) and check_rect_rect_collision(game_state.player:hitbox(), right_tile_hitbox)) then
        return true
    end

    -- check collisions with solid entities
    if(game_state.tile_map.falling_platforms) then
        for _, fp in pairs(game_state.tile_map.falling_platforms) do
            if(fp:is_solid()) then
                if(check_rect_rect_collision(game_state.player:hitbox(), fp:hitbox())) then
                    return true
                end
            end
        end
    end
    if(game_state.tile_map.falling_columns) then
        for _, c in pairs(tile_map.falling_columns) do
            if(check_rect_rect_collision(c:hitbox(), game_state.player:hitbox())) then
                return true
            end
        end
    end
end

function check_collisions(tile_map, player, game_state)
    local player_hitbox = player:hitbox()
    local player_fall_check_hitbox = player:fall_check_hitbox()

    player.has_ground_below = false
    if(tile_map.snails) then
        for _, snail in ipairs(tile_map.snails) do
            snail.has_ground_below = false
        end
    end
    for y, row in ipairs(tile_map.tiles) do
        for x, tile in ipairs(tile_map.tiles[y]) do
            local tile_pos     = V2(x-1, y-1)
            local top_left     = V2(tile_pos.x*TILE_SIZE, tile_pos.y*TILE_SIZE)
            local bottom_right = V2(tile_pos.x*TILE_SIZE + TILE_SIZE, tile_pos.y*TILE_SIZE + TILE_SIZE)

            local tile_hitbox = Rectangle(top_left, bottom_right)

            if(tile.type == TileType.AIR) then
                if(check_rect_rect_collision(tile_hitbox, player:hitbox())) then
                    if(player.state ~= PlayerState.DEAD) then
                        player:collided_with_tile(tile_pos.x, tile_pos.y, tile);
                    end
                end
            elseif Tile.is_solid_tile(tile) then
                if(check_rect_rect_collision(tile_hitbox, player_fall_check_hitbox)) then
                    player.has_ground_below = true
                    player.should_fall = false
                end
                if(check_rect_rect_collision(tile_hitbox, player:hitbox())) then
                    if(player.state ~= PlayerState.DEAD and not player:is_flying()) then
                        player:collided_with_tile(tile_pos.x, tile_pos.y, tile);
                    end
                end

                if(tile_map.snails) then
                    for _, snail in ipairs(tile_map.snails) do
                        if check_rect_rect_collision(snail:hitbox(), tile_hitbox) then
                            snail:collided_with_tile(tile_pos.x, tile_pos.y, tile);
                        end
                        if(check_rect_rect_collision(snail:fall_check_hitbox(), tile_hitbox)) then
                            snail.has_ground_below = true
                        end
                    end
                end

                if(tile_map.falling_spikes) then
                    for _, fs in ipairs(tile_map.falling_spikes) do
                        if check_rect_rect_collision(fs:hitbox(), tile_hitbox) then
                            fs:collided_with_tile(tile_pos.x, tile_pos.y, tile);
                            game_state.tile_map:remove_falling_spike(fs)
                        end
                    end
                end

                if(tile_map.falling_columns) then
                    for _, c in ipairs(tile_map.falling_columns) do
                        if check_rect_rect_collision(c:hitbox(), tile_hitbox) then
                            c:collided_with_tile(tile_pos.x, tile_pos.y, tile);
                        end
                    end
                end

                local broom = game_state.player.broom
                if(broom) then
                    if(player:is_flying()) then
                        -- Check combined hitbox
                        local player_collided = check_rect_rect_collision(player:hitbox(), tile_hitbox)
                        local broom_collided = check_rect_rect_collision(broom:hitbox(), tile_hitbox)

                        if(player_collided) then
                            player:add_player_combined_collision(tile_pos.x, tile_pos.y, tile)
                        end
                        if(broom_collided) then
                            player:add_broom_combined_collision(tile_pos.x, tile_pos.y, tile)
                        end

                    elseif(check_rect_rect_collision(broom:hitbox(), tile_hitbox)) then
                        broom:collided_with_tile(tile_pos.x, tile_pos.y, tile)
                    end
                end

            elseif(tile.type == TileType.WATER) then
                if(check_rect_rect_collision(tile_hitbox, player:hitbox())) then
                    player:collided_with_tile(tile_pos.x, tile_pos.y, tile);
                end
            end
        end
    end

    if(tile_map.doors) then
        for _, door in pairs(tile_map.doors) do
            local door_hitbox = door:hitbox()
            if(check_rect_rect_collision(player:hitbox(), door_hitbox)) then
                if(door.locked) then
                    if(door.jumps_to_unlock > 0) then
                        game_state:add_door_required_jumps(door.tile_pos.x, door.tile_pos.y, game_state.lowest_jumps_record, door.jumps_to_unlock)
                    end

                    if(door.is_puzzle_door) then
                        game_state:add_locked_puzzle_door_info(door.tile_pos.x, door.tile_pos.y)
                    end
                else
                    game_state:load_map(door)
                    game_state:set_entering_door(door)
                end
            end
        end
    end

    if(tile_map.bouncers) then
        for _, bouncer in pairs(tile_map.bouncers) do
            if(check_rect_rect_collision(player:hitbox(), bouncer:hitbox())) then
                if(not bouncer.colliding_with_player) then
                    game_state.player:touched_bouncer(bouncer)
                    bouncer:start_bouncing()
                end
            else
                bouncer.colliding_with_player = false
            end
        end
    end

    if(tile_map.spikes) then
        for _, spikes in pairs(tile_map.spikes) do
            if(check_rect_rect_collision(player:hitbox(), spikes.hitbox)) then
                game_state:player_touched_spikes()
            end
        end
    end

    if(tile_map.vines) then
        game_state.player:reset_colliding_vines()
        for _, vine in pairs(tile_map.vines) do
            if(check_rect_rect_collision(player:hitbox(), vine:hitbox())) then
                game_state.player:touched_vine(vine)
            end
        end
    end

    if(tile_map.falling_platforms) then
        for _, fp in pairs(tile_map.falling_platforms) do
            if(fp:is_solid()) then
                if(check_rect_rect_collision(fp:hitbox(), player_fall_check_hitbox)) then
                    player.has_ground_below = true
                    fp:touched_by_player(player)
                end
                if(game_state.player:is_flying()) then
                    if(player.broom) then
                        if(check_rect_rect_collision(player.broom:hitbox(), fp:hitbox())) then
                            game_state.player:broom_touched_falling_platform(fp)
                        end
                    end
                    if(check_rect_rect_collision(player:hitbox(), fp:hitbox())) then
                        local x = fp.pos.x / TILE_SIZE
                        local y = fp.pos.y / TILE_SIZE
                        game_state.player:add_player_combined_collision(x, y, nil)
                    end
                else
                    if(check_rect_rect_collision(player:hitbox(), fp:hitbox())) then
                        game_state.player:touched_falling_platform(fp)
                    end
                end
            end
        end
    end

    if(tile_map.falling_spikes) then
        for _, fp in pairs(tile_map.falling_spikes) do
            if(check_rect_rect_collision(fp:hitbox(), player:hitbox())) then
                game_state:player_touched_spikes()
            end
            if(check_rect_rect_collision(fp.fall_check_collider, player:hitbox())) then
                fp:start_falling()
            end
        end
    end

    if(tile_map.falling_columns) then
        for _, c in pairs(tile_map.falling_columns) do
            if(check_rect_rect_collision(c:hitbox(), player:hitbox())) then
                if(check_rect_rect_collision(c:hitbox(), player_fall_check_hitbox)) then
                    player.has_ground_below = true
                end
                if(check_rect_rect_collision(player:hitbox(), c:hitbox())) then
                    game_state.player:touched_falling_column(c)
                end
            end
            if(check_rect_rect_collision(c.fall_check_collider, player:hitbox())) then
                c:start_falling()
            end
        end
    end

    if(tile_map.triggers) then
        for _, trigger in pairs(tile_map.triggers) do
            if(check_rect_rect_collision(trigger:hitbox(), player:hitbox())) then
                trigger:triggered_by_player()
            end
        end
    end

    if(tile_map.facts) then
        for _, fact in pairs(tile_map.facts) do
            if(check_rect_rect_collision(fact:hitbox(), player:hitbox())) then
                fact:triggered_by_player()
            else
                fact:released_trigger()
            end
        end
    end

    if(tile_map.computahs) then
        for _, c in pairs(tile_map.computahs) do
            if(check_rect_rect_collision(c:hitbox(), player:hitbox())) then
                if(check_rect_rect_collision(c:hitbox(), player_fall_check_hitbox)) then
                    player.has_ground_below = true
                end
                if(check_rect_rect_collision(player:hitbox(), c:hitbox())) then
                    c:touched_by_player(player)
                    player:touched_computah(c)
                end
            end
        end
    end

    if(tile_map.brogs) then
        for _, brog in pairs(tile_map.brogs) do
            if(check_rect_rect_collision(player:hitbox(), brog:hitbox())) then
                brog:touched_by_player()
            end
        end
    end

    if(tile_map.medals) then
        for _, medal in pairs(tile_map.medals) do
            if(check_rect_rect_collision(player:hitbox(), medal:hitbox())) then
                medal:touched_by_player()
            end
        end
    end

    if(tile_map.image_triggers) then
        for _, image_trigger in pairs(tile_map.image_triggers) do
            if(check_rect_rect_collision(image_trigger:hitbox(), player:hitbox())) then
                image_trigger:triggered_by_player()
            end
        end
    end

    local broom = game_state.player.broom
    if(broom) then
        if(check_rect_rect_collision(player:hitbox(), broom:hitbox())) then
            game_state.player:touched_broom()
        else
            game_state.player:exited_broom_collision()
        end
    end

    local prev_position_hitbox = player:prev_position_hitbox()
    player_hitbox = player:hitbox()

    local prev_top_left_x     = prev_position_hitbox.top_left.x
    local prev_top_left_y     = prev_position_hitbox.top_left.y
    local prev_bottom_right_x = prev_position_hitbox.bottom_right.x
    local prev_bottom_right_y = prev_position_hitbox.bottom_right.y

    local curr_top_left_x     = player_hitbox.top_left.x
    local curr_top_left_y     = player_hitbox.top_left.y
    local curr_bottom_right_x = player_hitbox.bottom_right.x
    local curr_bottom_right_y = player_hitbox.bottom_right.y

    if(tile_map.snails) then
        for _, snail in pairs(tile_map.snails) do
            -- Lerp between prev pos hitbox and current hitbox
            -- go from back to front in steps
            -- check for the first collision and use that

            local LERP_STEPS = 10
            for t = 0, 1, 1/LERP_STEPS do
                local subframe_hitbox = Rectangle(
                    V2(
                        lume.lerp(prev_top_left_x, curr_top_left_x, t),
                        lume.lerp(prev_top_left_y, curr_top_left_y, t)
                    ),
                    V2(
                        lume.lerp(prev_bottom_right_x, curr_bottom_right_x, t),
                        lume.lerp(prev_bottom_right_y, curr_bottom_right_y, t)
                    )
                )
                if(check_rect_rect_collision(subframe_hitbox, snail:hitbox())) then
                    game_state.player:touched_snail(snail, subframe_hitbox)
                    break
                end
            end
        end
    end
end

function snap_to(entity, direction, x, y, width, height, kill_momentum)
    local tile_left_x   = x*TILE_SIZE
    local tile_right_x  = (x+1)*TILE_SIZE
    local tile_top_y    = y*TILE_SIZE
    local tile_bottom_y = (y+1)*TILE_SIZE

    if(direction == "right") then
        entity.pos.x = tile_right_x
        entity.vel.x = entity.vel.x * 0.9

    elseif(direction == "left") then
        entity.pos.x = tile_left_x - width
        entity.vel.x = entity.vel.x * 0.9

    elseif(direction == "up") then
        entity.prev_pos.y = entity.pos.y
        entity.pos.y = tile_top_y - height
        entity.vel.y = entity.vel.y * 0.9

    elseif(direction == "down") then
        entity.prev_pos.y = entity.pos.y + 1
        entity.pos.y = tile_bottom_y
        entity.vel.y = entity.vel.y * 0.9

    end
end

function check_collisions_for_particle(tile_map, particle)
    if not tile_map then return false end

    local particle_top_left     = particle.pos
    local particle_bottom_right = V2(particle.pos.x + particle.size, particle.pos.y + (particle.size_y or particle.size))
    local particle_hitbox = Rectangle(particle_top_left, particle_bottom_right)

    if game_state.player then
        local player_hitbox = game_state.player:hitbox()

        if check_rect_rect_collision(player_hitbox, particle_hitbox) then
            return true
        end
    end

    for y, row in ipairs(tile_map.tiles) do
        for x, tile in ipairs(tile_map.tiles[y]) do
            if Tile.is_solid_tile(tile) then
                local tile_pos     = V2(x-1, y-1)
                local top_left     = V2(tile_pos.x*TILE_SIZE, tile_pos.y*TILE_SIZE)
                local bottom_right = V2(tile_pos.x*TILE_SIZE + TILE_SIZE, tile_pos.y*TILE_SIZE + TILE_SIZE)
                local tile_hitbox     = Rectangle(top_left, bottom_right)

                if check_rect_rect_collision(tile_hitbox, particle_hitbox) then
                    return true
                end
            end
        end
    end

    return false
end
