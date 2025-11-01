require("./utils");
require("./math");
require("./tile_map");
require("./spikes");
require("./bouncer");
require("./snail");
require("./vine");
require("./input");
local Object = require("./classic")

Editor = Object.extend(Object)

-- TODO/NOTE: Use diferent type and same state maybe
EditingState = {
    SETTING_TILES = 0,
    ADDING_DOOR = 1,
    ADDING_SPIKES = 2,
    ADDING_BOUNCER = 3,
    ADDING_SNAIL = 4,
    ADDING_VINES = 5,
};

local input_actions_pressed = {
    ["a"] = false,
    ["d"] = false,
    ["primary_mouse_button"] = false
}

function Editor.new(self)
    self.saving = false
    self.state = EditingState.SETTING_TILES

    self.new_entity_direction = 1
end

function Editor:handle_input(game_state)
    local st = self.selected_tile(game_state.tile_map)
    local s_half_t = self.selected_half_tile()

    -- TODO: Use input system
    if(love.keyboard.isDown("a") and not input_actions_pressed.a) then
        input_actions_pressed.a = true
        local target_index = (self.state - 1) % table_length(EditingState)
        self.state = target_index
    end
    if(not love.keyboard.isDown("a") and input_actions_pressed.a) then
        input_actions_pressed.a = false
    end

    if(love.keyboard.isDown("d") and not input_actions_pressed.d) then input_actions_pressed.d = true
        local target_index = (self.state + 1) % table_length(EditingState)
        self.state = target_index
    end
    if(not love.keyboard.isDown("d") and input_actions_pressed.d) then
        input_actions_pressed.d = false
    end

    if(input.move_right.is_pressed) then
        local new_index = game_state.map_index + 1
        if new_index > #level_names then new_index = 1 end
        local new_level = level_names[new_index]
        
        game_state:load_map(new_level)
        game_state.map_index = new_index
    end

    if(input.move_left.is_pressed) then
        local new_index = game_state.map_index - 1
        if new_index == 0 then new_index = #level_names end
        local new_level = level_names[new_index]
        
        game_state:load_map(new_level)
        game_state.map_index = new_index
    end

    if(self.state == EditingState.SETTING_TILES) then
        if love.mouse.isDown(1) then
            game_state.tile_map:add_tile(Tile(TileType.GROUND), st.x, st.y)
        end
        if love.mouse.isDown(2) then
            game_state.tile_map:add_tile(Tile(TileType.AIR), st.x, st.y)
        end

        if input.editor_save.is_pressed then
            -- TODO: add notification
            game_state.tile_map:save()
        end

    elseif(self.state == EditingState.ADDING_DOOR) then
        if love.mouse.isDown(1) then
            game_state.tile_map:add_door(
                "DOOR_NAME_CHANGEME", st,
                "DOOR_TARGET_CHANGEME", "LEVEL_TARGET_CHANGEME"
            )
        end
        if love.mouse.isDown(2) then
            -- TODO IMPLEMENT
            --game_state.tile_map:remove_door(st)
        end
    elseif(self.state == EditingState.ADDING_SPIKES) then
            -- TODO: move to input system
        if(love.mouse.isDown(1) and not input_actions_pressed.primary_mouse_button) then
            input_actions_pressed.primary_mouse_button = true
            local spikes_pos = V2(
                s_half_t.x*TILE_SIZE/2,
                s_half_t.y*TILE_SIZE/2
            )
            local spikes = Spikes(spikes_pos, 0)
            game_state.tile_map:add_spikes(spikes)
        end
        if(not love.mouse.isDown(1) and input_actions_pressed.primary_mouse_button) then
            input_actions_pressed.primary_mouse_button = false
        end
        if love.mouse.isDown(2) then
            -- TODO IMPLEMENT
            -- TODO maybe check collision??
            local spikes_pos = V2(
                s_half_t.x*TILE_SIZE/2,
                s_half_t.y*TILE_SIZE/2
            )
            game_state.tile_map:remove_spikes(spikes_pos)
        end
    elseif(self.state == EditingState.ADDING_BOUNCER) then
        if(love.mouse.isDown(1) and not input_actions_pressed.primary_mouse_button) then
            input_actions_pressed.primary_mouse_button = true
            local bouncer_pos = V2(
                st.x*TILE_SIZE,
                st.y*TILE_SIZE
            )
            local bouncer = Bouncer(bouncer_pos, 0)
            game_state.tile_map:add_bouncer(bouncer)
        end
        if(not love.mouse.isDown(1) and input_actions_pressed.primary_mouse_button) then
            input_actions_pressed.primary_mouse_button = false
        end
        if love.mouse.isDown(2) then
            -- TODO IMPLEMENT
            -- TODO maybe check collision??
            local bouncer_pos = V2(
                st.x*TILE_SIZE,
                st.y*TILE_SIZE
            )
            game_state.tile_map:remove_bouncer(bouncer_pos)
        end

    elseif(self.state == EditingState.ADDING_SNAIL) then
        if input.editor_toggle.is_pressed then
            self.new_entity_direction = -self.new_entity_direction
        end
        if(love.mouse.isDown(1) and not input_actions_pressed.primary_mouse_button) then
            input_actions_pressed.primary_mouse_button = true
            local snail_pos = V2(
                st.x*TILE_SIZE,
                st.y*TILE_SIZE
            )
            local snail = Snail(snail_pos, self.new_entity_direction)
            game_state.tile_map:add_snail(snail)
        end
        if(not love.mouse.isDown(1) and input_actions_pressed.primary_mouse_button) then
            input_actions_pressed.primary_mouse_button = false
        end
        if love.mouse.isDown(2) then
            local snail_pos = V2(
                st.x*TILE_SIZE,
                st.y*TILE_SIZE
            )
            -- TODO: select entity of mouse and delete by that
            game_state.tile_map:remove_snail(snail_pos)
        end
    elseif(self.state == EditingState.ADDING_VINES) then
        if(love.mouse.isDown(1) and not input_actions_pressed.primary_mouse_button) then
            input_actions_pressed.primary_mouse_button = true
            local vine_pos = V2(
                st.x*TILE_SIZE,
                st.y*TILE_SIZE
            )
            local vine = Vine(vine_pos)
            game_state.tile_map:add_vine(vine)
        end
        if(not love.mouse.isDown(1) and input_actions_pressed.primary_mouse_button) then
            input_actions_pressed.primary_mouse_button = false
        end
        if love.mouse.isDown(2) then
            local vine_pos = V2(
                st.x*TILE_SIZE,
                st.y*TILE_SIZE
            )
            -- TODO: select entity of mouse and delete by that
            game_state.tile_map:remove_vine(vine_pos)
        end
    end
end

function Editor:handle_draw(game_state)

    -- draw mouse
    local draw_pos = V2(
        self:selected_tile().x*TILE_SIZE*scale,
        self:selected_tile().y*TILE_SIZE*scale
    )
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle("fill", draw_pos.x, draw_pos.y, TILE_SIZE*scale, TILE_SIZE*scale)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", draw_pos.x, draw_pos.y, TILE_SIZE*scale, TILE_SIZE*scale)
    if(self.new_entity_direction == 1) then
        love.graphics.polygon(
            "line",
            draw_pos.x + TILE_SIZE*scale/2, draw_pos.y,
            draw_pos.x + TILE_SIZE*scale, draw_pos.y + TILE_SIZE*scale/2,
            draw_pos.x + TILE_SIZE*scale/2, draw_pos.y + TILE_SIZE*scale
        )
    else
        love.graphics.polygon(
            "line",
            draw_pos.x + TILE_SIZE*scale/2, draw_pos.y,
            draw_pos.x, draw_pos.y + TILE_SIZE*scale/2,
            draw_pos.x + TILE_SIZE*scale/2, draw_pos.y + TILE_SIZE*scale
        )
    end

    love.graphics.setColor(0.1, 0.1, 0.1)
    local editing_state_width  = 100
    local editing_state_height = 30
    love.graphics.rectangle("fill", 20, 20, editing_state_width, editing_state_height)
    love.graphics.setColor(0.9, 0.9, 0.9)

    local editing_mode = "TILE"
    if self.state == EditingState.ADDING_DOOR then editing_mode = "ADDING_DOOR" end
    if self.state == EditingState.ADDING_SPIKES then editing_mode = "ADDING_SPIKES" end
    if self.state == EditingState.ADDING_BOUNCER then editing_mode = "ADDING_BOUNCER" end
    if self.state == EditingState.ADDING_SNAIL then editing_mode = "ADDING_SNAIL" end
    if self.state == EditingState.ADDING_VINES then editing_mode = "ADDING_VINES" end
    love.graphics.print(editing_mode, 20, 30)

    -- debug info
    local debug_box_width = 150
    local debug_box_height = 400
    local debug_box_x = 800 - debug_box_width
    local debug_box_y = 20
    love.graphics.setColor(0.1, 0.1, 0.1, 0.5)
    love.graphics.rectangle("fill", debug_box_x, debug_box_y, debug_box_width, debug_box_height)

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("line", debug_box_x-2, debug_box_y-2, debug_box_width+4, debug_box_height+4)

    local text_draw_x = debug_box_x + 4
    local text_draw_y = debug_box_y + 4
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print("width: "..game_state.tile_map:width(), text_draw_x, text_draw_y)

    text_draw_y = text_draw_y + 16
    love.graphics.print("height: "..game_state.tile_map:height(), text_draw_x, text_draw_y)
end

function Editor:selected_tile(tile_map)
    local mx, my = love.mouse.getPosition()
    local selected_tile = V2(
        math.floor( mx / (TILE_SIZE*scale) ),
        math.floor( my / (TILE_SIZE*scale) )
    )

    return selected_tile
end

function Editor:selected_half_tile()
    local mx, my = love.mouse.getPosition()
    local selected_half_tile = V2(
        math.floor( mx / (scale*TILE_SIZE/2) ),
        math.floor( my / (scale*TILE_SIZE/2) )
    )

    return selected_half_tile
end
