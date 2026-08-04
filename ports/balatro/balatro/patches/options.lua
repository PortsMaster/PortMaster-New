local BUTTON_MAP_FILE = os.getenv('BALATRO_PM_BUTTON_MAP_FILE')
local SETUP_FILE = os.getenv('BALATRO_PM_SETUP_FILE')
local IS_ANDROID = love.system.getOS() == 'Android'
local ANDROID_SETUP_REQUEST = 'android-port-setup.request'

local function file_missing(path)
    if not path then return false end
    local file = io.open(path, 'r')
    if not file then return true end
    file:close()
    return false
end

local function setup_is_pending()
    if IS_ANDROID then
        return love.filesystem.getInfo(ANDROID_SETUP_REQUEST, 'file') ~= nil
    end
    if not SETUP_FILE then return false end
    local file = io.open(SETUP_FILE, 'r')
    if not file then return true end
    local pending = false
    for line in file:lines() do
        if line:match('^%s*ask%s*=%s*1%s*$') then pending = true end
    end
    file:close()
    return pending
end

local function request_setup()
    if IS_ANDROID then
        love.filesystem.write(ANDROID_SETUP_REQUEST, '1\n')
        return
    end
    if not SETUP_FILE then return end
    local file = io.open(SETUP_FILE, 'a')
    if not file then
        os.remove(SETUP_FILE)
        return
    end
    file:write('ask=1\n')
    file:close()
end

local BUTTON = 'pm_port_setup'
local LABEL = 'Initialize Port Settings'
local PENDING_LABEL = 'Port Settings: On Restart'
local EXPLANATION = IS_ANDROID and {
    'Sets the screen layout and performance',
    'again on the next launch.',
} or {
    'Sets the screen layout, performance and',
    'your buttons again on the next launch.',
}
local PENDING_EXPLANATION = IS_ANDROID and {
    'Restart the app to set the layout and',
    'performance again.',
} or {
    'Restart the port to set the layout,',
    'performance and buttons again.',
}

local function is_active()
    return IS_ANDROID or SETUP_FILE ~= nil or BUTTON_MAP_FILE ~= nil
end

local function is_pending()
    return setup_is_pending() or file_missing(BUTTON_MAP_FILE)
end

local function request_setup_all()
    request_setup()
    if not IS_ANDROID and BUTTON_MAP_FILE then os.remove(BUTTON_MAP_FILE) end
end

local function line_node(text)
    return {n = G.UIT.R, config = {align = 'cm', padding = 0}, nodes = {
        {n = G.UIT.T, config = {text = text, scale = 0.3,
            colour = G.C.UI.TEXT_LIGHT}}
    }}
end

local function entry_node()
    local pending = is_pending()
    local column = {
        UIBox_button{
            id = BUTTON,
            label = {pending and PENDING_LABEL or LABEL},
            button = BUTTON,
            minw = 5, colour = G.C.BLUE
        },
    }
    for _, line in ipairs(pending and PENDING_EXPLANATION or EXPLANATION) do
        column[#column + 1] = line_node(line)
    end
    return {n = G.UIT.R, config = {align = 'cm'}, nodes = {
        {n = G.UIT.C, config = {align = 'cm', padding = 0.04}, nodes = column}
    }}
end

local function node_holds_button(node)
    if type(node) ~= 'table' then return false end
    if node.config and node.config.button then return true end
    if node.nodes then
        for _, child in pairs(node.nodes) do
            if node_holds_button(child) then return true end
        end
    end
    return false
end

local function find_button_list(node, best)
    if type(node) ~= 'table' or type(node.nodes) ~= 'table' then return best end
    local count = 0
    for _, child in pairs(node.nodes) do
        if node_holds_button(child) then count = count + 1 end
    end
    if count >= 2 and count > (best and best.count or 0) then
        best = {list = node.nodes, count = count}
    end
    for _, child in pairs(node.nodes) do
        best = find_button_list(child, best)
    end
    return best
end

local function shaped_like(sibling, node)
    if type(sibling) ~= 'table' or sibling.config and sibling.config.button then
        return node
    end
    if type(sibling.nodes) ~= 'table' or #sibling.nodes ~= 1 then return node end
    return {n = sibling.n, config = {align = sibling.config and sibling.config.align},
        nodes = {node}}
end

local function append_to_button_list(definition)
    local best = find_button_list(definition, nil)
    if not best then return end
    local sibling
    for _, child in pairs(best.list) do
        if node_holds_button(child) then sibling = child end
    end
    local ok, node = pcall(entry_node)
    if ok and node then
        best.list[#best.list+1] = shaped_like(sibling, node)
    end
end

local building_options, added_to_contents = false, false

if type(create_UIBox_generic_options) == 'function' then
    local original_generic = create_UIBox_generic_options
    function create_UIBox_generic_options(args, ...)
        if building_options and type(args) == 'table' and
           type(args.contents) == 'table' then
            local ok, node = pcall(entry_node)
            if ok and node then
                args.contents[#args.contents+1] = node
                added_to_contents = true
            end
        end
        return original_generic(args, ...)
    end
end

local function add_setup_options(build, ...)
    if not is_active() then return build(...) end
    building_options, added_to_contents = true, false
    local ok, definition = pcall(build, ...)
    building_options = false
    if not ok then error(definition) end
    if not added_to_contents then
        pcall(append_to_button_list, definition)
    end
    return definition
end

local rebuild_options

G.FUNCS[BUTTON] = function()
    request_setup_all()
    if rebuild_options then
        pcall(function()
            G.FUNCS.overlay_menu{definition = rebuild_options()}
        end)
    end
end

if type(create_UIBox_options) == 'function' then
    local original_options = create_UIBox_options
    rebuild_options = function(...)
        return add_setup_options(original_options, ...)
    end
    function create_UIBox_options(...)
        return rebuild_options(...)
    end
elseif G.UIDEF and type(G.UIDEF.options) == 'function' then
    local original_options = G.UIDEF.options
    rebuild_options = function(...)
        return add_setup_options(original_options, ...)
    end
    G.UIDEF.options = rebuild_options
end
