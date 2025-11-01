require("./lume")

function bool_to_number(value)
    assert(type(value) == "boolean")

    if value == true then
        return 1
    else
        return 0
    end
end

function create_table_with(length, value)
    local result = {}
    for _ = 0, length do
        table.insert(result, value)
    end

    return result
end

function create_2d_table_with(width, height, value)
    local result = {}
    for _ = 0, height do
        local row = create_table_with(width, value)
        table.insert(result, row)
    end

    return result
end

function right_pad_table_with(tb, value, n)
    for i = 1, n do
        table.insert(tb, value)
    end
end

function left_pad_table_with(tb, value, n)
    for i = 1, n do
        table.insert(tb, 1, value)
    end
end

function right_pad_2d_table_with(tb, value, n)
    for _, row in pairs(tb) do
        right_pad_table_with(row, value, n)
    end
end

function left_pad_2d_table_with(tb, value, n)
    for _, row in pairs(tb) do
        left_pad_table_with(row, value, n)
    end
end

function bottom_pad_2d_table_with(tb, value, n)
    local row_length = table_length(tb[1])
    for i = 1, n do
        local row = create_table_with(row_length, value)
        table.insert(tb, row)
    end
end

function top_pad_2d_table_with(tb, value, n)
    local row_length = table_length(tb[1])
    for i = 1, n do
        local row = create_table_with(row_length, value)
        table.insert(tb, 1, row)
    end
end

function table_length(tb)
    result = 0
    for i, v in pairs(tb) do
        result = result + 1
    end

    return result
end

function table_contains(t, v)
    for _, vv in pairs(t) do
        if vv == v then
            return true
        end
    end

    return false
end

function indexof(arr, v)
    for i, vv in pairs(arr) do
        if vv == v then
            return i
        end
    end

    return nil 
end

function random_string(length)
    local result = ""

    for i = 1, length do
        local chars = {
            tostring(math.floor(lume.random(0, 10))),
            string.char(lume.random(65, 90)),
            string.char(lume.random(97, 122)),
            string.char(lume.random(35, 38))
        }
        local char = lume.randomchoice(chars)
        result = result .. char
    end

    return result
end

function draw_hitbox(entity)
    local entity_hitbox = entity:hitbox()
    local x = entity_hitbox.top_left.x
    local y = entity_hitbox.top_left.y
    local dims = rectangle_dimensions(entity_hitbox)

    love.graphics.setColor(0.5, 0, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, dims.width, dims.height)

    love.graphics.setColor(1, 1, 1)
end

function find_first(t, fn)
    for _, el in pairs(t) do
        if(fn(el)) then
            return el
        end
    end
end

function get_canvas_offset()
    local width, height = love.graphics.getDimensions() 
    local canvas_width = BASE_RESOLUTION.width * scale
    local canvas_height = BASE_RESOLUTION.height * scale
    local offset_x = (width - canvas_width) / 2
    local offset_y = (height - canvas_height) / 2

    return V2(offset_x, offset_y)
end

function if_not_nil_else(value, default)
    if value ~= nil then
        return value
    else
        return default
    end
end

function resolution_scale()
    local width, height = love.graphics.getDimensions()

    local horizontal_scale = math.floor(width/BASE_RESOLUTION.width)
    local vertical_scale = math.floor(height/BASE_RESOLUTION.height)

    return math.min(horizontal_scale, vertical_scale)
end

function is_mobile_os()
    local os_string = love.system.getOS()

    return os_string == "Android" or os_string == "iOS"
end
