require("./utils");
require("./math");
require("./snail");
require("./vine");
require("./falling_platform");
require("./trigger");
require("./fact");
require("./spawner");
require("./falling_spike");
require("./falling_column");
require("./audio");
require("./render");
require("./point_light");
require("./flies");
require("./mirror");
require("./glitch_block");
require("./computah");
require("./medal");
require("./image_trigger");
require("./music_frog");
require("./trophy");
lume = require("./lume");
local Object = require("./classic")

Tile = Object.extend(Object)
TileMap = Object.extend(Object)

TILE_SIZE = 8

Audio.create_sound("sounds/sec.wav", "secret")
Audio.sounds["secret"][1]:setVolume(0.5)

TileType = {
    ["AIR"]     = 0,
    ["GROUND"]  = 1,
    ["WATER"]   = 2,
    ["BARRIER"] = 3,
};

Tile.is_solid_tile = function(tile)
    local SOLID_TILES = {
        TileType.GROUND,
        TileType.BARRIER
    }

    return table_contains(SOLID_TILES, tile.type)
end

Tile.is_shadow_casting_tile = function(tile)
    local SHADOW_CASTING_TILES = {
        TileType.GROUND,
    }

    return table_contains(SHADOW_CASTING_TILES, tile.type)
end

Door = Object.extend(Object)
Door.tile = love.graphics.newImage("door.png")

LAYERS_PER_SPRITE_BATCH = 15

local function is_front_layer(layer_name)
    local FRONT_LAYERS_MATCHES = {
        "deco",
    }

    for _, match in pairs(FRONT_LAYERS_MATCHES) do
        if string.match(layer_name, match) then
            return true
        end
    end

    return false
end

local function is_hidden_layer(layer_name)
    local HIDDEN_LAYERS_MATCHES = {
        "hidden",
    }

    for _, match in pairs(HIDDEN_LAYERS_MATCHES) do
        if string.match(layer_name, match) then
            return true
        end
    end

    return false
end

function Tile.new(self, type, data)
    self.type = type
end

Door.MEDALS_NEEDED_FOR_PUZZLE_DOOR = 3

function Door.new(
    self,
    name, tile_pos,
    target_door_name, target_level_name,
    spawn_pos, direction, tile_map, visible, width, height, jumps_to_unlock,
    is_puzzle_door
)
    self.name = name
    self.tile_pos = tile_pos

    self.jumps_to_unlock = jumps_to_unlock
    self.is_puzzle_door = is_puzzle_door

    self.locked = false
    if(game_state) then
        local obtained_medals_amount = game_state:obtained_medals_amount()

        if(jumps_to_unlock and (jumps_to_unlock > game_state.lowest_jumps_record)) then
            self.locked = true
        end

        if(self.is_puzzle_door and obtained_medals_amount < Door.MEDALS_NEEDED_FOR_PUZZLE_DOOR) then
            self.locked = true
        end
    end

    self.target_door_name = target_door_name
    self.target_level_name = target_level_name

    self.spawn_pos = spawn_pos or V2(self.tile_pos.x + 1, self.tile_pos.y)
    self.pos = V2((self.spawn_pos.x-2)*TILE_SIZE, (self.spawn_pos.y)*TILE_SIZE)

    self.world_pos = v2_scale(self.tile_pos, TILE_SIZE)

    self.direction = direction
    self.visible = visible
    if(self.visible == nil) then
        self.visible = true
    end

    self.width = width or TILE_SIZE
    self.height = height or TILE_SIZE

    self.has_jungle_light = false

    if(direction ~= 1 and direction ~= -1) then
        self.direction = 1
    end

    self.time = 0
    self.light = nil
    if(self.visible) then
        self.light = PointLight(
            V2(tile_pos.x*TILE_SIZE + TILE_SIZE/2, tile_pos.y*TILE_SIZE + TILE_SIZE/2),
            "#aaaaff",
            0.25,
            0.4,
            not self.locked
        )

        tile_map:add_point_light(self.light)

        self.particle_emitter = ParticleEmitter( {
            pos = V2(tile_pos.x*TILE_SIZE, tile_pos.y*TILE_SIZE),
            particle_type = ParticleType.emitter,
            particle_variant = ParticleVariant.portal,
            particles_per_second = 5,
            total_time = -1,
            gravity = -0.01,
            terminal_velocity = 0.01,
            visible = not self.locked
        } )

        tile_map:add_effect(EFFECT_TYPE.particles, -1, {
            particle_emitter = self.particle_emitter,
        })
    end

end

function Door:hitbox()
    return Rectangle(
        V2(self.tile_pos.x*TILE_SIZE + TILE_SIZE/3, self.tile_pos.y*TILE_SIZE),
        V2(self.tile_pos.x*TILE_SIZE + self.width - TILE_SIZE/3, self.tile_pos.y*TILE_SIZE + self.height)
    )
    -- return Rectangle(
    --     V2(self.pos.x, self.pos.y),
    --     V2(self.pos.x + self.width, self.pos.y + self.height)
    -- )
end

function Door:draw()
    if(self.visible) then
        if(self.locked) then
            love.graphics.setColor(1, 1, 1, 0.4)
        else
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.draw(Door.tile, self.tile_pos.x*TILE_SIZE - TILE_SIZE/2, self.tile_pos.y*TILE_SIZE - TILE_SIZE)
    end

    if false then
        draw_hitbox(self)
    end
end

function Door:update(dt)
    self.time = self.time + dt

    if(self.visible and self.light) then
        self.light.radius = self.light.radius + 0.001*math.sin(2*self.time)
    end
end

function TileMap.new(self,
    width, height, name,
    doors, spikes, vines, snails, bouncers,
    tile_layers, tile_sets, tiles_to_tilesets, background, falling_platforms,
    triggers, facts, spawners, falling_spikes, falling_columns, fly_clusters, mirrors,
    allowed_jumps, glitch_blocks, computahs, is_dark, music_frogs
)
    self.name = name
    self.tiles = create_2d_table_with(width, height, Tile(TileType.AIR))
    self.doors = doors or {}
    self.spikes = spikes or {}
    self.bouncers = bouncers or {}
    self.snails = snails or {}
    self.vines = vines or {}
    self.falling_platforms = falling_platforms or {}
    self.triggers = triggers or {}
    self.trigger_counters = {}
    self.facts = facts or {}
    self.spawners = spawners or {}
    self.falling_spikes = falling_spikes or {}
    self.falling_columns = falling_columns or {}
    self.mirrors = mirrors or {}
    self.glitch_blocks = glitch_blocks or {}
    self.computahs = computahs or {}
    self.brogs = {}
    self.medals = {}
    self.image_triggers = {}
    self.music_frogs = music_frogs or {}
    self.trophies = {}

    self.effects = effects or {}
    self.point_lights = point_lights or {}

    self.tile_layers = tile_layers or {}
    self.tile_sets = tile_sets or {}
    self.tiles_to_tilesets = tiles_to_tilesets or {}
    self.background = background

    self.hidden_area_triggered = false

    self.shadow_casting_segments = {}
    self.constraints = {}
    self.fly_clusters = fly_clusters

    self.allowed_jumps = allowed_jumps

    self.playing_sounds = {}
    self.sounds_volume = 0

    self.is_dark = is_dark or false

    love.graphics.setDefaultFilter("nearest", "nearest")
end

function TileMap:add_tile(tile, x, y)
    if( (x + 1) > table_length(self.tiles[1]) ) then
        -- expand in x+
        -- 10
        local padding = (x + 1) - table_length(self.tiles[1])
        right_pad_2d_table_with(self.tiles, Tile(TileType.AIR), padding)
    end
    if( (x + 1) < 1) then
        -- expand in x-
        local padding = 1 - (x + 1)
        left_pad_2d_table_with(self.tiles, Tile(TileType.AIR), padding)
    end
    if( (y + 1) > table_length(self.tiles) ) then
        -- expand in y+
        local padding = (y + 1) - table_length(self.tiles)
        bottom_pad_2d_table_with(self.tiles, Tile(TileType.AIR), padding)
    end
    if( (y + 1) < 1 ) then
        -- expand in y-
        local padding = 1 - (y + 1)
        top_pad_2d_table_with(self.tiles, Tile(TileType.AIR), padding)
    end
    self.tiles[y+1][x+1] = tile
end

function TileMap:add_layer(layer)
    table.insert(self.tile_layers, layer)
end

function load_tile_map(level_name)
    if(level_name == "museum_01") then
        Audio.music_fade_enabled = true
        Audio.fade_out_song("glitch_break")
    end

    if(level_name == "lobby") then
        Audio.music_fade_enabled = true
        Audio.reset_state()
        Audio.fade_out_song("glitch_break")
        Audio.fade_in_song("lobby")
    end

    if(level_name == "final_screen") then
        game_state:end_reached()
    end

    if(level_name == "lobby") then
        game_state:check_for_challenge_level_completion()
        game_state:reset_to_lobby()
    else
        local should_start_counting_jumps_levels = {
            "level_01",
            "challenge_01_01",
            "challenge_01_05",
            "challenge_01_09",
        }
        if(table_contains(should_start_counting_jumps_levels, level_name)) then
            game_state:start_counting_jumps()
        end
    end

    if(level_name == "credits" or level_name == "final_screen") then
        UI.reset_credits_state()
    end

    if(appleCake) then
        appleCake.mark("Start loading level")
    end
    local tile_sets = {}
    local tiles_to_tilesets = {}
    local path = "levels/" .. level_name .. ".lua"
    local name = "levels/" .. level_name
    local saved_tile_map = nil
    saved_tile_map = love.filesystem.load(path)
    if saved_tile_map then
        saved_tile_map = saved_tile_map()
    else
        error("opening file at: " .. path)
        love.event.quit(1)
    end

    if not saved_tile_map then
        error("opening file at: " .. path)
        love.event.quit(1)
    end


    -- TODO maybe static
    -- -- TODO Do some checks maybe
    local width = saved_tile_map.width
    local height = saved_tile_map.height
    local name = saved_tile_map.properties.name
    local allowed_jumps = saved_tile_map.properties.jumps
    local is_dark = saved_tile_map.properties.is_dark

    local tile_set_files = love.filesystem.getDirectoryItems( "tile_sets" )

    -- get tilesets
    if(appleCake) then
        appleCake.mark("Get tilesets")
    end
    for _, tile_set in pairs(saved_tile_map.tilesets) do
        -- initialize tile_set
        local name = "tile_sets/" .. tile_set.name
        local file = "tile_sets/" .. tile_set.name .. ".lua"
        local tile_set_created = false
        for k, v in pairs(tile_set_files) do
            if v == tile_set.name .. ".lua" then
                tile_set_created = true
                break
            end
        end
        if (tile_set_created) then
            local saved_tile_set = love.filesystem.load(file)()
            local img = love.graphics.newImage("tile_sets/" .. tile_set.name .. ".png")
            local sprite_batches = {}
            for i = 1, LAYERS_PER_SPRITE_BATCH do
                local sprite_batch = love.graphics.newSpriteBatch(img, 1000, "static")
                table.insert(sprite_batches, sprite_batch)
            end
            local quads = {}

            local tile_width  = math.floor(saved_tile_set.imagewidth / saved_tile_set.tilewidth)
            local tile_height = math.floor(saved_tile_set.imageheight / saved_tile_set.tileheight)
            for i = tile_set.firstgid, tile_set.firstgid + saved_tile_set.tilecount do
                local tx = (i - tile_set.firstgid) % tile_width
                local ty = math.floor( (i - tile_set.firstgid) / tile_width)
                local new_quad = love.graphics.newQuad(
                    tx*saved_tile_set.tilewidth, ty*saved_tile_set.tileheight,
                    saved_tile_set.tilewidth, saved_tile_set.tileheight,
                    img:getDimensions()
                )
                quads[i] = new_quad
            end

            local new_tile_set = {
                name = tile_set.name,
                firstgid = tile_set.firstgid,
                sprite_batches = sprite_batches,
                quads = quads,
            }
            -- Order matters
            tile_sets[tile_set.name] = new_tile_set

            -- tiles_to_tilesets maps tile ID to tileset to use
            for i, _ in pairs(quads) do
                tiles_to_tilesets[i] = new_tile_set
            end
        else
            print("Tileset file not found: ", file)
        end
    end

    local tile_map_ref = {}

    -- Get images and entities layers
    local doors = {}
    local spikes = {}
    local bouncers = {}
    local vines = {}
    local snails = {}
    local falling_platforms = {}
    local triggers = {}
    local facts = {}
    local spawners = {}
    local falling_spikes = {}
    local falling_columns = {}
    local fly_clusters = {}
    local mirrors = {}
    local glitch_blocks = {}
    local computahs = {}
    local music_frogs = {}

    local background = nil
    local background_file = nil
    
    local vines_positions = {}

    local layers = saved_tile_map.layers
    local has_jungle_light = false
    local has_temple_light = false
    if(appleCake) then
        appleCake.mark("load images and entities")
    end
    for _, l in pairs(layers) do
        if(l.type == "imagelayer") then
            local path = string.gsub(l.image, "../", "")
            background_file = path
            background = love.graphics.newImage(path)
            if path == "jungle-background.png" then
                has_jungle_light = true
            end
            if path == "temple-background.png" then
                has_temple_light = true
            end
        elseif(l.type == "objectgroup") then
            for _, obj in pairs(l.objects) do
                local fixed_y = obj.y - TILE_SIZE
                if(obj.type == "snail") then
                    table.insert(snails, Snail(
                        V2(obj.x, fixed_y),
                        obj.properties.direction
                    ))
                end
                if(obj.type == "spike") then
                    table.insert(spikes, Spikes(
                        V2(obj.x, obj.y - TILE_SIZE/2)
                    ))
                end
                if(obj.type == "vine") then
                    table.insert(vines_positions, V2(obj.x, fixed_y))
                end
                if(obj.type == "falling_platform") then
                    table.insert(falling_platforms, FallingPlatform(
                        V2(obj.x, fixed_y)
                    ))
                end
                if(obj.type == "mirror") then
                    local y = obj.y - obj.height
                    table.insert(mirrors, Mirror(
                        V2(obj.x, y),
                        obj.width, obj.height, obj.properties.direction
                    ))
                end
                if(obj.type == "glitch_block") then
                    local y = obj.y - obj.height
                    table.insert(glitch_blocks, GlitchBlock(
                        V2(obj.x, y), obj.properties.level
                    ))
                end
                if(obj.type == "fly_cluster") then
                    local y = obj.y - obj.height
                    table.insert(fly_clusters, FlyCluster(
                        V2(obj.x, y),
                        obj.properties.amount,
                        obj.properties.luminiscent
                    ))
                end
            end
        end
    end

    -- Vine unification algorithm
    -- Initially the vines were 1 tile
    -- and instead of modifying the levels to unify them in 1 entity
    -- I unify them while loading the level, this way I don't
    -- modify the levels
    local vine_segments = {} 
    for _, vine_pos in pairs(vines_positions) do
        table.insert(vine_segments, {
            x = vine_pos.x,
            top_y = vine_pos.y,
            bottom_y = vine_pos.y,
            valid = true
        } )
    end

    local segments_unified = true
    while(segments_unified) do
        segments_unified = false
        for i = 1, #vine_segments do
            for j = 2, #vine_segments do
                local segment_1 = vine_segments[i]
                local segment_2 = vine_segments[j]
                local matching_x = segment_1.x == segment_2.x
                local segments_valid = segment_1.valid and segment_2.valid

                if(matching_x and segments_valid) then
                    local segment_1_on_top = segment_1.bottom_y == segment_2.top_y - TILE_SIZE 
                    local segment_2_on_top = segment_2.bottom_y == segment_1.top_y - TILE_SIZE 
                    if(segment_1_on_top) then
                        segment_1.bottom_y = segment_2.bottom_y
                        segment_2.valid = false
                        segments_unified = true

                    elseif(segment_2_on_top) then
                        segment_2.bottom_y = segment_1.bottom_y
                        segment_1.valid = false
                        segments_unified = true
                    end
                end
            end
        end
    end

    for _, v_segment in pairs(vine_segments) do
        if(v_segment.valid) then
            local tiles_difference = math.abs(v_segment.bottom_y - v_segment.top_y) / TILE_SIZE
            local height_in_tiles = tiles_difference + 1
            table.insert(vines, Vine(V2(v_segment.x, v_segment.top_y), height_in_tiles))
        end
    end

    if(appleCake) then
        appleCake.mark("creating tilemap")
    end
    tile_map = TileMap(
        width, height, name,
        doors, spikes, vines, snails, bouncers,
        nil, tile_sets, tiles_to_tilesets, background, falling_platforms,
        triggers, facts, spawners, falling_spikes, falling_columns, fly_clusters, mirrors,
        allowed_jumps, glitch_blocks, computahs, is_dark, music_frogs
    )

    tile_map.background_file = background_file
    tile_map.has_jungle_light = has_jungle_light
    tile_map.has_temple_light = has_temple_light

    if(appleCake) then
        appleCake.mark("adding tiles and entities")
    end
    for _, l in pairs(layers) do
        if(l.type == "tilelayer" and l.name == "collision") then
            local loaded_tiles = l.data

            for i, v in pairs(loaded_tiles) do
                local y = math.floor((i-1) / l.width)
                local x = ((i-1) % l.width)
                tile_map:add_tile(Tile(v), x, y)
            end
        elseif(l.type == "tilelayer") then
            tile_map:add_layer(l)
        elseif(l.type == "objectgroup") then
            for _, obj in pairs(l.objects) do
                local fixed_y = obj.y - TILE_SIZE

                if(obj.type == "hidden_trigger") then
                    table.insert(triggers, Trigger(
                        obj.properties.id, V2(obj.x, fixed_y), obj.properties.type, tile_map, obj.width, obj.height
                    ))
                    local trigger_counter = TriggerCounter(obj.properties.id)
                    tile_map:add_trigger_counter(trigger_counter)

                elseif(obj.type == "trigger") then
                    table.insert(triggers, Trigger(
                        obj.properties.id,
                        V2(obj.x, obj.y),
                        Trigger.Type[obj.properties.type],
                        tile_map, obj.width, obj.height,
                        obj.properties.expected_jumps
                    ))

                elseif(obj.type == "fact") then
                    table.insert(facts, Fact(
                        V2(obj.x, fixed_y), obj.properties.key, tile_map
                    ))
                elseif(obj.type == "spawner") then
                    table.insert(spawners, Spawner(
                        V2(obj.x, fixed_y),
                        obj.properties.direction,
                        obj.properties.waiting_time,
                        tile_map,
                        obj.properties.initial_time
                    ))

                elseif(obj.type == "falling_spike") then
                    tile_map:add_falling_spike(V2(obj.x, fixed_y))

                elseif(obj.type == "falling_column") then
                    tile_map:add_falling_column(V2(obj.x, fixed_y))

                elseif(obj.type == "door") then
                    local y = obj.y - obj.height
                    table.insert(tile_map.doors, Door(
                        obj.name,
                        V2(obj.x / TILE_SIZE, y / TILE_SIZE),
                        obj.properties.target_door_name,
                        obj.properties.target_level_name,
                        V2(
                            obj.x/TILE_SIZE + math.floor((obj.width/TILE_SIZE)/2) + obj.properties.spawn_pos_dx,
                            fixed_y/TILE_SIZE + math.floor((obj.height/TILE_SIZE)/2) + (obj.properties.spawn_pos_dy or 0)
                        ),
                        obj.properties.direction,
                        tile_map,
                        obj.properties.visible,
                        obj.width,
                        obj.height,
                        obj.properties.jumps_to_unlock,
                        obj.properties.is_puzzle_door
                    ))
                elseif(obj.type == "bouncer") then
                    local rot_to_orientation = {
                        [0]   = Bouncer.Orientation.UP,
                        [90]  = Bouncer.Orientation.RIGHT,
                        [-90] = Bouncer.Orientation.LEFT,
                        [180] = Bouncer.Orientation.DOWN,
                    }
                    local rot_to_dx = {
                        [0]   = 0,
                        [90]  = 0,
                        [-90] = -TILE_SIZE,
                        [180] = -TILE_SIZE,
                    }
                    local rot_to_dy = {
                        [0]   = 0,
                        [90]  = TILE_SIZE,
                        [-90] = 0,
                        [180] = TILE_SIZE,
                    }
                    table.insert(bouncers, Bouncer(
                        V2(obj.x + rot_to_dx[obj.rotation],
                        fixed_y + rot_to_dy[obj.rotation]),
                        rot_to_orientation[obj.rotation],
                        tile_map
                    ))

                elseif(obj.type == "computah") then
                    local y = obj.y - obj.height
                    table.insert(computahs, Computah(
                        V2(obj.x, y), tile_map
                    ))

                elseif(obj.type == "brog") then
                    local y = obj.y - obj.height
                    tile_map:add_brog(Brog(V2(obj.x, y)))

                elseif(obj.type == "medal") then
                    local y = obj.y - obj.height
                    tile_map:add_medal(Medal(obj.properties.color_name, V2(obj.x, y), obj.properties.interactible))

                elseif(obj.type == "image_trigger") then
                    local y = obj.y - obj.height
                    tile_map:add_image_trigger(
                        ImageTrigger(V2(obj.x, y), obj.properties.id)
                    )

                elseif(obj.type == "music_frog") then
                    local y = obj.y - obj.height
                    tile_map:add_music_frog(
                        MusicFrog(V2(obj.x, y), tile_map)
                    )

                elseif(obj.type == "trophy") then
                    local y = obj.y - obj.height
                    tile_map:add_trophy(
                        Trophy(V2(obj.x, y), obj.properties.key)
                    )

                elseif(obj.type == "point_light") then
                    tile_map:add_point_light(
                        PointLight(
                            V2(obj.x, obj.y),
                            "#"..obj.properties.color:sub(4, #obj.properties.color), -- TODO extract last 6
                            obj.properties.radius,
                            obj.properties.intensity
                        )
                    )

                elseif(obj.type == "particle_emitter") then
                    tile_map:add_effect(EFFECT_TYPE.particles, -1, {
                        particle_emitter = ParticleEmitter( {
                            pos = V2(obj.x, obj.y),
                            particle_type = ParticleType.emitter,
                            particle_variant = ParticleVariant.water_drops,
                            particles_per_second = 1.4,
                            total_time = -1,
                            gravity = 0.1,
                            terminal_velocity = 1.9,
                            visible = true,
                            prepopulate = true,
                        } )
                    } )
                end
            end
        end
    end

    if(tile_map.computahs) then
        for _, computah in pairs(tile_map.computahs) do
            tile_map:add_point_light(computah.light)
            tile_map:add_effect(EFFECT_TYPE.particles, -1, {
                particle_emitter = computah.broken_particle_emmiter
            })
        end
    end

    if(tile_map.fly_clusters) then
        for _, fc in pairs(tile_map.fly_clusters) do
            for _, fly in pairs(fc.flies) do
                if(fly.light) then
                    tile_map:add_point_light(fly.light)
                end
            end
        end
    end

    tile_map:generate_shadow_casting_segments()
    if(appleCake) then
        appleCake.mark("Finished loading level")
    end

    if(tile_map.background_file == "jungle-background.png") then
        local step = 320 / 8
        local x_positions = {
            0*step,
            1*step,
            2*step,
            3*step,
            4*step,
            5*step,
            6*step,
            7*step,
            8*step,
        }
        for _, x in pairs(x_positions) do
            local p_emitter = ParticleEmitter( {
                pos = V2(x, 0),
                particle_type = ParticleType.emitter,
                particle_variant = ParticleVariant.landing_vine,
                particles_per_second = 1,
                total_time = -1,
                gravity = 0.01,
                terminal_velocity = 0.3,
                floaty = true,
                prepopulate = true
            } )
            tile_map:add_effect(EFFECT_TYPE.particles, nil, {
                particle_emitter = p_emitter,
            })
        end
    end

    if(tile_map.background_file == "temple-background.png") then
        local step = 320 / 8
        local x_positions = {
            0*step,
            1*step,
            2*step,
            3*step,
            4*step,
            5*step,
            6*step,
            7*step,
            8*step,
        }
        local y_positions = {
            0*step*math.random(),
            1*step*math.random(),
            2*step*math.random(),
            3*step*math.random(),
            4*step*math.random(),
            5*step*math.random(),
            6*step*math.random(),
            7*step*math.random(),
            8*step*math.random(),
        }
        for i, x in pairs(x_positions) do
            local p_emitter = ParticleEmitter( {
                pos = V2(x, y_positions[i]),
                particle_type = ParticleType.emitter,
                particle_variant = ParticleVariant.dust,
                particles_per_second = 0.2,
                total_time = -1,
                gravity = 0.01,
                terminal_velocity = 0.1,
                floaty = true,
                prepopulate = true
            } )
            tile_map:add_effect(EFFECT_TYPE.particles, nil, {
                particle_emitter = p_emitter,
            })
        end
    end

    if(tile_map.background_file == "puzzle-background.png") then
        local step = 320 / 8
        local x_positions = {
            0*step,
            1*step,
            2*step,
            3*step,
            4*step,
            5*step,
            6*step,
            7*step,
            8*step,
        }
        local y_positions = {
            0*step*math.random(),
            1*step*math.random(),
            2*step*math.random(),
            3*step*math.random(),
            4*step*math.random(),
            5*step*math.random(),
            6*step*math.random(),
            7*step*math.random(),
            8*step*math.random(),
        }
        for i, x in pairs(x_positions) do
            local p_emitter = ParticleEmitter( {
                pos = V2(x, y_positions[i]),
                particle_type = ParticleType.emitter,
                particle_variant = ParticleVariant.puzzle,
                particles_per_second = 0.4,
                total_time = -1,
                gravity = 0.0,
                terminal_velocity = 0.4,
                floaty = false,
                prepopulate = true
            } )
            tile_map:add_effect(EFFECT_TYPE.particles, nil, {
                particle_emitter = p_emitter,
            })
        end
    end

    collectgarbage()

    return tile_map
end

function TileMap:save()
    local file_name = self.name .. ".lua"
    local path = "./levels/" .. file_name

    local tiles_to_serialize = {}
    for y, row in pairs(self.tiles) do
        table.insert(tiles_to_serialize, {})
        for _, tile in pairs(row) do
            table.insert(tiles_to_serialize[y], tile.type)
        end
    end

    local tile_map_to_serialize = {
        width = self:width(),
        height = self:height(),
        name = self.name,
        doors = self.doors,
        tiles = tiles_to_serialize,
        spikes = self.spikes,
        vines = self.vines,
        bouncers = self.bouncers,
        snails = self.snails,
    }
    local content = lume.serialize(tile_map_to_serialize)

    -- TODO use love filesystem?
    local file = io.open(path, "w")
    if not file then
        print("couldnt open file")--error("couldnt open file")
        os.exit(1)
    end
    file:write(content)
    file:close()
end

function TileMap:update(dt)
    local updatable_entities = {
        "snails",
        "falling_platforms",
        "facts",
        "spawners",
        "falling_spikes",
        "falling_columns",
        "doors",
        "fly_clusters",
        "trigger_counters",
        "glitch_blocks",
        "computahs",
        "brogs",
        "medals",
        "image_triggers",
        "vines",
        "music_frogs",
        "trophies",
    }

    for _, entity_group in ipairs(updatable_entities) do
        if(self[entity_group]) then
            for _, entity in pairs(self[entity_group]) do
                entity:update(dt)
            end
        end
    end
end

function TileMap:draw_solid_tiles()
    love.graphics.setColor(1, 1, 1)
    for y, row in pairs(self.tiles) do
        for x, tile in ipairs(row) do
            if Tile.is_solid_tile(tile) then
                love.graphics.rectangle("fill", (x-1)*TILE_SIZE, (y-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
            end
        end
    end
end

function TileMap:draw_water_tiles()
    love.graphics.setColor(1, 1, 1)
    self.top_water_y = nil
    for y, row in pairs(self.tiles) do
        for x, tile in ipairs(row) do
            if(tile.type == TileType.WATER) then
                if (not self.top_water_y ) or ((y-1)*TILE_SIZE < self.top_water_y) then
                    self.top_water_y = (y-1)*TILE_SIZE
                end
                love.graphics.rectangle("fill", (x-1)*TILE_SIZE, (y-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
            end
        end
    end
end

function TileMap:draw_background()
    if(self.background) then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.background, 0, 0)
    end
end

function TileMap:draw_back_layers()
    self:clear_tile_set_sprite_batches()

    for layer_index, layer in pairs(self.tile_layers) do
        if (layer.type == "tilelayer"
            and layer.visible
            and not is_front_layer(layer.name)
            and not is_hidden_layer(layer.name)
        ) then
            self:add_tiles_to_sprite_batches(layer_index, layer)
        end 
    end

    self:draw_sprite_batches()
end

function TileMap:draw_front_layers()
    self:clear_tile_set_sprite_batches()

    for layer_index, layer in pairs(self.tile_layers) do
        if (layer.type == "tilelayer"
            and layer.visible
            and is_front_layer(layer.name)
        ) then
            self:add_tiles_to_sprite_batches(layer_index, layer)
        end 
    end

    self:draw_sprite_batches()
end

function TileMap:draw_hidden_layers()
    self:clear_tile_set_sprite_batches()
    for layer_index, layer in pairs(self.tile_layers) do
        if (layer.type == "tilelayer"
            and layer.visible
            and is_hidden_layer(layer.name)
        ) then
            local trigger_id = layer.properties.trigger_id
            local counter = nil
            if(trigger_id) then
                counter = lume.match(self.trigger_counters, function (c)
                        return c.trigger_id == trigger_id
                    end
                )
            end
            if(trigger_id and (not counter)) then
                error("A hidden layer with an associated trigger id are being used, but the trigger was not created")
            end
            assert(counter or (not trigger_id))

            for i, tile in pairs(layer.data) do
                local width = layer.width
                local height = layer.height
                local x = ((i-1) % width) * TILE_SIZE
                local y = math.floor((i-1) / width) * TILE_SIZE

                if(tile > 0) then
                    local draw_tileset = self.tiles_to_tilesets[tile]
                    local sprite_batch = draw_tileset and draw_tileset.sprite_batches[layer_index] -- Is index from 1 to #layer.data?
                    if(draw_tileset and sprite_batch) then
                        if(trigger_id and counter) then
                            local scale_factor = (1 - counter.count_percentage)
                            sprite_batch:setColor(1, 1, 1, scale_factor)
                            sprite_batch:add(draw_tileset.quads[tile], x, y)
                        else
                            sprite_batch:setColor(1, 1, 1)
                            sprite_batch:add(draw_tileset.quads[tile], x, y)
                        end
                    end
                end
            end
        end 
    end

    self:draw_sprite_batches()
end

function TileMap:add_tiles_to_sprite_batches(layer_index, layer)
    if layer_index >= LAYERS_PER_SPRITE_BATCH  then
        print("[ERROR]: Amount of layers is greater than the allowed, LAYERS_PER_SPRITE_BATCH: ", LAYERS_PER_SPRITE_BATCH)
        return
    end

    for i, tile in pairs(layer.data) do
        local width = layer.width
        local height = layer.height
        local x = ((i-1) % width) * TILE_SIZE
        local y = math.floor((i-1) / width) * TILE_SIZE

        if(tile > 0) then
            local draw_tileset = self.tiles_to_tilesets[tile]
            local sprite_batch = draw_tileset and draw_tileset.sprite_batches[layer_index]
            if(draw_tileset and sprite_batch) then
                sprite_batch:setColor(1, 1, 1)
                sprite_batch:add(draw_tileset.quads[tile], x, y)
            end
        end
    end
end

function TileMap:draw_sprite_batches()
    for i = 1, LAYERS_PER_SPRITE_BATCH do
        for _, tile_set in pairs(self.tile_sets) do
            local sprite_batch = tile_set.sprite_batches[i]
            love.graphics.draw(sprite_batch)
        end
    end
end

function TileMap:draw_entities()
    local drawable_entities = {
        "spikes",
        "bouncers",
        "snails",
        "vines",
        "falling_platforms",
        "triggers",
        "spawners",
        "falling_spikes",
        "falling_columns",
        "fly_clusters",
        "mirrors",
        "computahs",
        "image_triggers"
    }

    if self.doors then
        for _, door in pairs(self.doors) do
            local draw_x = door.tile_pos.x*TILE_SIZE
            local draw_y = door.tile_pos.y*TILE_SIZE

            door:draw()
        end
    end

    for _, entity_group in ipairs(drawable_entities) do
        if(self[entity_group]) then
            for _, entity in pairs(self[entity_group]) do
                entity:draw()
            end
        end
    end
end

function TileMap:draw_front_entities()
    local drawable_entities = {
        "brogs",
        "medals",
        "glitch_blocks",
        "trophies",
        "music_frogs"
    }

    for _, entity_group in ipairs(drawable_entities) do
        if(self[entity_group]) then
            for _, entity in pairs(self[entity_group]) do
                entity:draw()
            end
        end
    end
end

function TileMap:clear_tile_set_sprite_batches()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setDefaultFilter("nearest", "nearest")
    for _, tile_set in pairs(self.tile_sets) do
        for _, sprite_batch in pairs(tile_set.sprite_batches) do
            sprite_batch:clear()
        end
    end

end

function TileMap:draw()
    -- debug tiles
    if false then
        for y, row in pairs(self.tiles) do
            for x, tile in ipairs(row) do
                if(tile.type == TileType.AIR) then
                    love.graphics.setColor(1, 0, 0, 0)
                    love.graphics.rectangle("fill", (x-1)*TILE_SIZE, (y-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
                elseif(tile.type == TileType.WATER) then
                    love.graphics.setColor(36/255, 133/255, 166/255, 60/255)
                    love.graphics.rectangle("fill", (x-1)*TILE_SIZE, (y-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
                else
                    love.graphics.setColor(lume.color("#055976"))
                    love.graphics.rectangle("fill", (x-1)*TILE_SIZE, (y-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
                end
            end
        end
    end

    -- Draw shadow casting segments
    if(dev_mode and love.keyboard.isDown("l")) then
        if self.shadow_casting_segments then
            for _, s in pairs(self.shadow_casting_segments) do
                love.graphics.setColor(0.0, 1.0, 1.0)
                love.graphics.line(s.a.x, s.a.y, s.b.x, s.b.y)

                love.graphics.setColor(1.0, 0.0, 1.0)
                love.graphics.circle("fill", s.a.x, s.a.y, 1)
                love.graphics.circle("fill", s.b.x, s.b.y, 1)

            end
        end

        if false and self.constraints then
            for _, c in pairs(self.constraints) do
                local center = c.first_point_segment.segment[c.first_point]
                love.graphics.setColor(1.0, 0.0, 0.0)
                love.graphics.circle("line", center.x, center.y, 4)
            end
        end
    end
end

function TileMap:add_door(
    name, tile_pos,
    target_door_name, target_level_name
)
    local door = Door(name, tile_pos, target_door_name, target_level_name)
    if not door.name then return end
    if not self.doors then
        self.doors = {}
    end
    self.doors[door.name] = door
end

function TileMap:width()
    return table_length(self.tiles[1])
end

function TileMap:height()
    return table_length(self.tiles)
end

function TileMap:add_spikes(spikes)
    table.insert(self.spikes, spikes)
end

function TileMap:add_bouncer(bouncer)
    table.insert(self.bouncers, bouncer)
end

function TileMap:add_snail(snail)
    table.insert(self.snails, snail)
end

function TileMap:add_vine(vine)
    table.insert(self.vines, vine)
end

function TileMap:remove_spikes(spikes_pos)
    for i, spikes in pairs(self.spikes) do
        if(
            spikes.hitbox.top_left.x == spikes_pos.x and
            spikes.hitbox.top_left.y == spikes_pos.y
        ) then
            table.remove(self.spikes, i)
        end
    end
    --table.insert(self.spikes, spikes)
end

function TileMap:remove_bouncer(bouncer_pos)
    for i, bouncer in pairs(self.bouncers) do
        if(
            bouncer:hitbox().top_left.x == bouncer_pos.x and
            bouncer:hitbox().top_left.y == bouncer_pos.y
        ) then
            table.remove(self.bouncers, i)
        end
    end
    --table.insert(self.spikes, spikes)
end

function TileMap:remove_vine(vine_pos)
    for i, vine in pairs(self.vines) do
        if(
            vine:hitbox().top_left.x == vine_pos.x + Vine.MARGIN and
            vine:hitbox().top_left.y == vine_pos.y
        ) then
            table.remove(self.vines, i)
        end
    end
end

function TileMap:reveal_hidden_area(id)
    for _, tc in pairs(self.trigger_counters) do
        if(tc.trigger_id == id) then
            tc:trigger()
        end
    end
end

function TileMap.create_solid_tile_segment(segment, side)
    return {
        segment = segment,
        side = side,
    }
end

function TileMap:close_horizontal_segment(segment, fixed_y, side)
    local starting_point  = V2(
        (segment.starting_x - 1)*TILE_SIZE,
        fixed_y
    )
    local finishing_point = V2(
        (segment.finishing_x)*TILE_SIZE,
        fixed_y
    )

    local regular_segment = create_segment(starting_point, finishing_point)
    table.insert(self.shadow_casting_segments, TileMap.create_solid_tile_segment(regular_segment, side))

    segment.starting_x  = nil
    segment.finishing_x = nil
end

function TileMap:close_vertical_segment(segment, fixed_x, side)
    local starting_point  = V2(
        fixed_x,
        (segment.starting_y - 1)*TILE_SIZE
    )
    local finishing_point = V2(
        fixed_x,
        (segment.finishing_y)*TILE_SIZE
    )

    local regular_segment = create_segment(starting_point, finishing_point)
    table.insert(self.shadow_casting_segments, TileMap.create_solid_tile_segment(regular_segment, side))

    segment.starting_y  = nil
    segment.finishing_y = nil
end

function TileMap:generate_shadow_casting_segments()
    -- Generate initial segments

    -- horizontal segments
    for y, row in pairs(self.tiles) do
        local top_segment = {
            starting_x  = nil,
            finishing_x = nil
        }
        local bottom_segment = {
            starting_x  = nil,
            finishing_x = nil
        }
        local fixed_top_y    = (y - 1)*TILE_SIZE
        local fixed_bottom_y = y*TILE_SIZE

        for x, tile in pairs(row) do
            if Tile.is_shadow_casting_tile(tile) then
                -- check top tile
                if(y > 1) then
                    if not Tile.is_shadow_casting_tile(self.tiles[y-1][x]) then
                        if not top_segment.starting_x then top_segment.starting_x = x end
                        top_segment.finishing_x = x
                    else
                        if top_segment.starting_x then
                            -- generate top segment
                            self:close_horizontal_segment(top_segment, fixed_top_y, "top")
                        end
                    end
                end
                -- check bottom tile
                if(y < #self.tiles) then
                    if not Tile.is_shadow_casting_tile(self.tiles[y+1][x]) then
                        if not bottom_segment.starting_x then bottom_segment.starting_x = x end
                        bottom_segment.finishing_x = x
                    else
                        if bottom_segment.starting_x then
                            -- generate bottom segment
                            self:close_horizontal_segment(bottom_segment, fixed_bottom_y, "bottom")
                        end
                    end
                end
            else
                -- close existing segments
                if top_segment.starting_x then
                    self:close_horizontal_segment(top_segment, fixed_top_y, "top")
                end
                if bottom_segment.starting_x then
                    self:close_horizontal_segment(bottom_segment, fixed_bottom_y, "bottom")
                end
            end
        end
    end

    -- vertical segments
    for x = 1, #self.tiles[1] do
        local left_segment = {
            starting_y  = nil,
            finishing_y = nil
        }
        local right_segment = {
            starting_y  = nil,
            finishing_y = nil
        }
        local fixed_left_x  = (x - 1)*TILE_SIZE
        local fixed_right_x = x*TILE_SIZE

        for y = 1, #self.tiles do
            local tile = self.tiles[y][x]

            if Tile.is_shadow_casting_tile(tile) then
                -- generate one single segment
                -- check left tile
                if(x > 1) then
                    if not Tile.is_shadow_casting_tile(self.tiles[y][x-1]) then
                        if not left_segment.starting_y then left_segment.starting_y = y end
                        left_segment.finishing_y = y
                    else
                        if left_segment.starting_y then
                            -- generate left segment
                            self:close_vertical_segment(left_segment, fixed_left_x, "left")
                        end
                    end
                end
                -- check right tile
                if(x < #self.tiles[1]) then
                    if not Tile.is_shadow_casting_tile(self.tiles[y][x+1]) then
                        if not right_segment.starting_y then right_segment.starting_y = y end
                        right_segment.finishing_y = y
                    else
                        if right_segment.starting_y then
                            -- generate right segment
                            self:close_vertical_segment(right_segment, fixed_right_x, "right")
                        end
                    end
                end
            else
                -- close existing segments
                if left_segment.starting_y then
                    self:close_vertical_segment(left_segment, fixed_left_x, "left")
                end
                if right_segment.starting_y then
                    self:close_vertical_segment(right_segment, fixed_right_x, "right")
                end
            end
        end
    end

    -- Generate corner constraints

    -- local constraints = {}
    local function generate_constraint(first_point_segment, first_point, second_point_segment, second_point)
        table.insert(self.constraints, {
            first_point_segment = first_point_segment,
            first_point = first_point,
            second_point_segment = second_point_segment,
            second_point = second_point,
        } )
    end

    for i = 1, #self.shadow_casting_segments - 1 do
        for j = i + 1, #self.shadow_casting_segments do
            local current_segment = self.shadow_casting_segments[i]
            local check_segment = self.shadow_casting_segments[j]

            local a_a_distance = v2_distance(current_segment.segment.a, check_segment.segment.a)
            local a_b_distance = v2_distance(current_segment.segment.a, check_segment.segment.b)
            local b_a_distance = v2_distance(current_segment.segment.b, check_segment.segment.a)
            local b_b_distance = v2_distance(current_segment.segment.b, check_segment.segment.b)

            local CONSTRAINT_DISTANCE = 1
            local a_a_constraint = a_a_distance <= CONSTRAINT_DISTANCE
            local a_b_constraint = a_b_distance <= CONSTRAINT_DISTANCE
            local b_a_constraint = b_a_distance <= CONSTRAINT_DISTANCE
            local b_b_constraint = b_b_distance <= CONSTRAINT_DISTANCE

            if a_a_constraint then
                generate_constraint(current_segment, "a", check_segment, "a")
            end
            if a_b_constraint then
                generate_constraint(current_segment, "a", check_segment, "b")
            end
            if b_a_constraint then
                generate_constraint(current_segment, "b", check_segment, "a")
            end
            if b_b_constraint then
                generate_constraint(current_segment, "b", check_segment, "b")
            end
        end
    end

    -- Make segments shorter and closer to center of tiles
    for _, tile_segment in pairs(self.shadow_casting_segments) do
        local segment = tile_segment.segment
        local is_vertical = segment.a.x == segment.b.x -- Maybe small distance check

        local SHRINK_DISTANCE = 1
        if is_vertical then
            -- Vertical shrink (segments were created top to bottom)
            segment.a.y = segment.a.y + SHRINK_DISTANCE
            segment.b.y = segment.b.y - SHRINK_DISTANCE

            if tile_segment.side == "left" then
                -- Move segment to the right
                segment.a.x = segment.a.x + SHRINK_DISTANCE
                segment.b.x = segment.b.x + SHRINK_DISTANCE

            elseif tile_segment.side == "right" then
                -- Move segment to the left
                segment.a.x = segment.a.x - SHRINK_DISTANCE
                segment.b.x = segment.b.x - SHRINK_DISTANCE

            else
                print("[ERROR]: Side for vertical segment should be left or right")
                print(tile_segment.side)
            end
        else
            -- Horizontal shrink (segments were created left to right)
            segment.a.x = segment.a.x + SHRINK_DISTANCE
            segment.b.x = segment.b.x - SHRINK_DISTANCE

            if tile_segment.side == "top" then
                -- Move segment to the bottom
                segment.a.y = segment.a.y + SHRINK_DISTANCE
                segment.b.y = segment.b.y + SHRINK_DISTANCE

            elseif tile_segment.side == "bottom" then
                -- Move segment to the top
                segment.a.y = segment.a.y - SHRINK_DISTANCE
                segment.b.y = segment.b.y - SHRINK_DISTANCE

            else
                print("[ERROR]: Side for horizontal segment should be top or bottom")
                print(tile_segment.side)
            end
        end
    end

    -- Resolve constraints
    local broken_constraints = 0
    local constraint_intents = {}
    for i = 1, #self.constraints do
        local constraint = self.constraints[i]
        local first_point = constraint.first_point_segment.segment[constraint.first_point]
        local second_point = constraint.second_point_segment.segment[constraint.second_point]
        local distance = v2_distance(first_point, second_point)

        local CONSTRAINT_DISTANCE = 1
        -- Prevent initially crossroad constraints
        local MAX_CONSTRAINT_DISTANCE = math.ceil(2 * v2_length(V2(CONSTRAINT_DISTANCE, CONSTRAINT_DISTANCE)))
        if distance > CONSTRAINT_DISTANCE and distance <= MAX_CONSTRAINT_DISTANCE then
            broken_constraints = broken_constraints + 1
            local should_apply_constraint = true

            for j = 1, #self.constraints do
                local check_constraint = self.constraints[j]
                local third_point = check_constraint.first_point_segment.segment[check_constraint.first_point]
                local fourth_point = check_constraint.second_point_segment.segment[check_constraint.second_point]

                local some_points_match = (
                    v2_equals(first_point, third_point) or
                    v2_equals(first_point, fourth_point) or
                    v2_equals(second_point, third_point) or
                    v2_equals(second_point, fourth_point)
                )
                local is_not_same_constraint = i ~= j

                if is_not_same_constraint and some_points_match then
                    should_apply_constraint = false
                end
            end

            if should_apply_constraint then
                if segment_is_vertical(constraint.first_point_segment.segment) then
                    if segment_is_horizontal(constraint.second_point_segment.segment) then
                        table.insert(constraint_intents, {
                        } )
                        -- Extend vertically to second point y
                        first_point.y = second_point.y

                        -- Extend horizontally to first point x
                        second_point.x = first_point.x
                    end
                elseif segment_is_horizontal(constraint.first_point_segment.segment) then
                    if segment_is_vertical(constraint.second_point_segment.segment) then
                        -- Extend horizontally to second point x
                        first_point.x = second_point.x

                        -- Extend vertically to first point y
                        second_point.y = first_point.y
                    end
                end
            end
        end
    end

    -- Set shadow casting segments as regular segments
    local regular_segments = lume.map(self.shadow_casting_segments, function(s)
        return s.segment
    end)

    self.shadow_casting_segments = regular_segments
end

function TileMap:add_falling_spike(pos)
    local x_index = math.floor((pos.x / TILE_SIZE)) + 1
    local y_index = math.floor((pos.y / TILE_SIZE)) + 2

    while(y_index <= #self.tiles) do
        if(self.tiles[y_index][x_index].type ~= TileType.AIR) then
            y_index = y_index - 1
            break
        end
        y_index = y_index + 1
    end

    local height = y_index*TILE_SIZE - pos.y
    local falling_spike = FallingSpike(pos, height)

    table.insert(self.falling_spikes, falling_spike)
end

function TileMap:remove_falling_spike(falling_spike)
    for i, fs in pairs(self.falling_spikes) do
        if fs == falling_spike then
            table.remove(self.falling_spikes, i)

            return
        end
    end
end

function TileMap:add_falling_column(pos)
    local x_index = math.floor((pos.x / TILE_SIZE)) + 1
    local y_index = math.floor((pos.y / TILE_SIZE)) + 2

    while(y_index <= #self.tiles) do
        if(self.tiles[y_index][x_index].type ~= TileType.AIR) then
            y_index = y_index - 1
            break
        end
        y_index = y_index + 1
    end

    local height = (y_index + 1)*TILE_SIZE - pos.y
    local falling_column = FallingColumn(pos, height)

    table.insert(self.falling_columns, falling_column)
end

function TileMap:remove_falling_column(falling_column)
    for i, c in pairs(self.falling_columns) do
        if c == falling_column then
            table.remove(self.falling_columns, i)

            return
        end
    end
end

function TileMap:add_effect(type, target_time, data)
    local new_effect = {
        type = type,
        time = 0,
        target_time = target_time or -1,
        data = data or {},
    }

    local is_screenshake_effect = table_contains(Render.screenshake_effects, type)
    if is_screenshake_effect and game_state.config_screenshake_disabled then
        return
    end

    local is_flashy_effect = table_contains(Render.effects_effects, type)
    if is_flashy_effect and game_state.config_effects_disabled then
        return
    end

    table.insert(self.effects, new_effect)
end

function TileMap:remove_effect(type)
    local new_effects = {}

    for i, effect in pairs(self.effects) do
        if(effect.type ~= type) then
            table.insert(new_effects, effect)
        end
    end

    self.effects = new_effects
end

function TileMap:add_point_light(point_light)
    table.insert(self.point_lights, point_light)
end

function TileMap:remove_point_light(point_light)
    for i, light in pairs(self.point_lights) do
        if(light == point_light) then
            table.remove(self.point_lights, i)
        end
    end
end

function TileMap:update_timers(dt)
    for i, effect in pairs(self.effects) do
        effect.time = effect.time + dt

        if (effect.target_time ~= -1) and (effect.time > effect.target_time) then
            table.remove(self.effects, i)
        end
    end
end

function TileMap:tileset_from_tile(tile)
    local max_lesser_tileset = nil
    for _, tileset in pairs(self.tile_sets) do
        if (tile >= tileset.firstgid and ( (not max_lesser_tileset) or (max_lesser_tileset.firstgid < tileset.firstgid)) ) then
            max_lesser_tileset = tileset
        end
    end

    return max_lesser_tileset
end

function TileMap:remove_falling_column(falling_column)
    lume.remove(self.falling_columns, falling_column)
end

function TileMap:remove_snail(snail)
    lume.remove(self.snails, snail)
end

function TileMap:add_trigger_counter(trigger_counter)
    function match_counter(counter)
        return counter.trigger_id == trigger_counter.trigger_id
    end
    if(not lume.match(self.trigger_counters, match_counter)) then
        table.insert(self.trigger_counters, trigger_counter)
    end
end

function TileMap:dynamic_shadow_casting_segments()
    local result = {}

    if(self.falling_platforms) then
        for _, fp in pairs(self.falling_platforms) do
            local fp_shadow_casting_segments = fp:shadow_casting_segments()
            if(fp:is_solid() and fp_shadow_casting_segments) then
                for _, casting_segment in pairs(fp_shadow_casting_segments) do
                    table.insert(result, casting_segment)
                end
            end
        end
    end

    if(self.falling_columns) then
        for _, fc in pairs(self.falling_columns) do
            local fc_shadow_casting_segments = fc:shadow_casting_segments()
            if(fc_shadow_casting_segments) then
                for _, casting_segment in pairs(fc_shadow_casting_segments) do
                    table.insert(result, casting_segment)
                end
            end
        end
    end

    return result
end

function TileMap:add_sound(key, volume)
    table.insert(self.playing_sounds, {
        key = key,
        volume = volume
    } )
    Audio.fade_in_sound(key, 6, volume)
end

function TileMap:remove_sound(key)
    local idx = nil
    for i, sound in pairs(self.playing_sounds) do
        if sound.key == key then
            idx = i
        end
    end

    if(idx) then
        table.remove(self.playing_sounds, idx)
    end
    Audio.stop_sound(key)
end

function TileMap:handle_unload()
    Audio.stop_sound("flies")
    for _, sound in pairs(self.playing_sounds) do
        Audio.fade_out_sound(sound.key, 1)
    end
end

function TileMap:song_key()
    local file_key_map = {
        ["caves-background.png"] = "cave",
        ["jungle-background.png"] = "jungle",
        ["glitch-background.png"] = "glitch_start",
        ["temple-background.png"] = "temple",
        ["dark-background.png"] = "dark_ambience",
        ["puzzle-background.png"] = "puzzle",
        ["gallery-background.png"] = "gallery",
        ["lobby-background.png"] = "lobby",
        ["credits-background.png"] = "gallery",
        ["final-screen-background.png"] = "forest_ambiance"
    }

    local challenge_variant_song_keys = {
        jungle = "jungle_challenge",
        cave   = "cave_challenge",
        temple = "temple_challenge",
    }

    local base_song_key = file_key_map[self.background_file]
    local song_key = base_song_key

    if self.name:match("challenge") then
        song_key = challenge_variant_song_keys[base_song_key]
        if not song_key then
            print("Challenge variant not found for key:", base_song_key)
            song_key = base_song_key
        end
    end

    return song_key
end

function TileMap:area_key()
    return self:song_key() -- TODO: replace the other one with this name
end

function TileMap:background_color()
    local file_key_map = {
        ["caves-background.png"] = "#02161C",
        ["jungle-background.png"] = "#011c12",
        ["glitch-background.png"] = "#011c12",
        ["temple-background.png"] = "#151515",
        ["dark-background.png"] = "#000000",
        ["puzzle-background.png"] = "#150A19",
        ["gallery-background.png"] = "#151515",
        ["lobby-background.png"] = "#02161C",
        ["credits-background.png"] = "#151515"
    }

    return file_key_map[self.background_file] or "#000000"
end

function TileMap:add_brog(brog)
    table.insert(self.brogs, brog)
end

function TileMap:add_medal(medal)
    self:add_point_light(medal.light)
    table.insert(self.medals, medal)
end

function TileMap:add_image_trigger(image_trigger)
    table.insert(self.image_triggers, image_trigger)
end

function TileMap:add_music_frog(music_frog)
    table.insert(self.music_frogs, music_frog)
end

function TileMap:remove_medal(medal)
    for i, md in pairs(self.medals) do
        if md == medal then
            table.remove(self.medals, i)

            return
        end
    end
end

function TileMap:animate_entities()
    local entities_to_animate = {
        "brogs",
    }

    for _, entity_list_name in pairs(entities_to_animate) do
        if(self[entity_list_name]) then
            for _, entity in pairs(self[entity_list_name]) do
                entity:animate()
            end
        end
    end
end

function TileMap:add_trophy(trophy)
    table.insert(self.trophies, trophy)
end

function TileMap:remove_brog_if_exists()
    self.brogs = {}
end

function TileMap:flies_volume()
    local flies_count = 0
    for _, fly_cluster in pairs(self.fly_clusters) do
        flies_count = flies_count + #fly_cluster.flies
    end
    local MAX_FLY_COUNT = 10
    local clamped_count = lume.clamp(flies_count, 0, MAX_FLY_COUNT)

    local factor = clamped_count / MAX_FLY_COUNT
    local sound_volume = 0.1

    return factor * sound_volume
end
