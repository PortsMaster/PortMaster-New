-- In-game achievements browser for PortMaster (no Steam overlay).
-- Options → Achievements (plural), and Stats → Achievements.
-- Uses local SETTINGS.ACHIEVEMENTS_EARNED via fetch_achievements().
-- Disable with BALATRO_PM_SKIP_ACHIEVEMENTS_MENU=1.

local SKIP = G.BALATRO_PM_SKIP_ACHIEVEMENTS_MENU
if SKIP == nil then
    SKIP = os.getenv('BALATRO_PM_SKIP_ACHIEVEMENTS_MENU') == '1'
end
if SKIP then return end

local PAGE_SIZE = 5

-- Plural menu title for every language shipped with Balatro.
local ACHIEVEMENTS_LABEL = {
    ['en-us'] = 'Achievements',
    ['de'] = 'Erfolge',
    ['es_ES'] = 'Logros',
    ['es_419'] = 'Logros',
    ['fr'] = 'Succès',
    ['id'] = 'Prestasi',
    ['it'] = 'Obiettivi',
    ['ja'] = '実績',
    ['ko'] = '도전과제',
    ['nl'] = 'Prestaties',
    ['pl'] = 'Osiągnięcia',
    ['pt_BR'] = 'Conquistas',
    ['ru'] = 'Достижения',
    ['zh_CN'] = '成就',
    ['zh_TW'] = '成就',
}

local function inject_achievements_loc()
    if not (G and G.localization and G.localization.misc and
            G.localization.misc.dictionary) then
        return
    end
    local lang = (G.SETTINGS and G.SETTINGS.language) or 'en-us'
    G.localization.misc.dictionary.k_achievements =
        ACHIEVEMENTS_LABEL[lang] or ACHIEVEMENTS_LABEL['en-us']
end

local function achievements_label()
    inject_achievements_loc()
    local text = localize('k_achievements')
    if not text or text == 'ERROR' then
        local lang = (G.SETTINGS and G.SETTINGS.language) or 'en-us'
        text = ACHIEVEMENTS_LABEL[lang] or ACHIEVEMENTS_LABEL['en-us']
    end
    return text
end

inject_achievements_loc()

local original_set_language = Game.set_language
function Game:set_language(...)
    local result = original_set_language(self, ...)
    inject_achievements_loc()
    return result
end

local function achievement_list()
    fetch_achievements()
    local list = {}
    for id, data in pairs(G.ACHIEVEMENTS or {}) do
        list[#list + 1] = {id = id, data = data}
    end
    table.sort(list, function(a, b)
        return (a.data.order or 0) < (b.data.order or 0)
    end)
    return list
end

local function earned_count(list)
    local n = 0
    for i = 1, #list do
        if list[i].data.earned then n = n + 1 end
    end
    return n
end

local function tier_label(tier)
    if tier == 1 then return 'I'
    elseif tier == 2 then return 'II'
    end
    return 'III'
end

local function achievement_row(entry)
    local id, data = entry.id, entry.data
    local earned = not not data.earned
    local name = localize(id, 'achievement_names') or id
    local desc = localize(id, 'achievement_descriptions') or ''
    if type(desc) == 'table' then desc = table.concat(desc, ' ') end

    local name_colour = earned and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE
    local desc_colour = earned and G.C.JOKER_GREY or G.C.UI.TEXT_INACTIVE
    local row_colour = earned and mix_colours(G.C.GREEN, G.C.BLACK, 0.88) or G.C.BLACK

    local badge
    if earned then
        local check = Sprite(0, 0, 0.35, 0.35, G.ASSET_ATLAS['icons'], {x = 1, y = 0})
        check.states.drag.can = false
        check.states.hover.can = false
        check.states.collide.can = false
        badge = {n = G.UIT.O, config = {object = check}}
    else
        badge = {n = G.UIT.T, config = {
            text = tier_label(data.tier or 3), scale = 0.3,
            colour = G.C.UI.TEXT_INACTIVE}}
    end

    return {n = G.UIT.R, config = {
        align = 'cm', padding = 0.06, r = 0.1, colour = row_colour,
        minw = 8.2, emboss = 0.03,
    }, nodes = {
        {n = G.UIT.C, config = {align = 'cm', minw = 0.55, minh = 0.55},
            nodes = {badge}},
        {n = G.UIT.C, config = {align = 'cl', minw = 7.4, padding = 0.03}, nodes = {
            {n = G.UIT.R, config = {align = 'cl'}, nodes = {
                {n = G.UIT.T, config = {
                    text = name, scale = 0.38, colour = name_colour, shadow = true}},
            }},
            {n = G.UIT.R, config = {align = 'cl', maxw = 7.3}, nodes = {
                {n = G.UIT.T, config = {
                    text = desc, scale = 0.26, colour = desc_colour}},
            }},
        }},
    }}
end

function create_UIBox_pm_achievement_page(page)
    page = page or 0
    local list = achievement_list()
    local rows = {}
    local first = page * PAGE_SIZE + 1
    local last = math.min(#list, (page + 1) * PAGE_SIZE)
    for i = first, last do
        rows[#rows + 1] = achievement_row(list[i])
    end
    if #rows == 0 then
        rows[1] = {n = G.UIT.R, config = {align = 'cm', padding = 0.2}, nodes = {
            {n = G.UIT.T, config = {
                text = '—', scale = 0.4, colour = G.C.UI.TEXT_INACTIVE}},
        }}
    end
    return {n = G.UIT.ROOT, config = {align = 'cm', padding = 0.05,
        colour = G.C.CLEAR}, nodes = rows}
end

local function create_achievements_menu(back_func)
    local list = achievement_list()
    local total = #list
    local earned = earned_count(list)
    local pages = math.max(1, math.ceil(total / PAGE_SIZE))
    local page_options = {}
    for i = 1, pages do
        page_options[i] = localize('k_page') .. ' ' .. i .. '/' .. pages
    end

    return create_UIBox_generic_options({
        back_func = back_func or 'options',
        contents = {
            {n = G.UIT.R, config = {align = 'cm', padding = 0.1}, nodes = {
                {n = G.UIT.T, config = {
                    text = achievements_label(), scale = 0.55,
                    colour = G.C.UI.TEXT_LIGHT, shadow = true}},
            }},
            {n = G.UIT.R, config = {align = 'cm', padding = 0.05}, nodes = {
                {n = G.UIT.T, config = {
                    text = earned .. '/' .. total, scale = 0.4,
                    colour = G.C.FILTER, shadow = true}},
            }},
            {n = G.UIT.R, config = {
                align = 'cm', padding = 0.08, minh = 4.2, minw = 8.4,
                colour = G.C.CLEAR,
            }, nodes = {
                {n = G.UIT.O, config = {
                    id = 'pm_achievement_list',
                    object = UIBox{
                        definition = create_UIBox_pm_achievement_page(0),
                        config = {offset = {x = 0, y = 0}, align = 'cm'},
                    },
                }},
            }},
            {n = G.UIT.R, config = {align = 'cm', padding = 0.05}, nodes = {
                create_option_cycle({
                    options = page_options,
                    w = 4.5,
                    cycle_shoulders = true,
                    opt_callback = 'pm_achievements_page',
                    current_option = 1,
                    colour = G.C.RED,
                    no_pips = true,
                    focus_args = {snap_to = true, nav = 'wide'},
                }),
            }},
        },
    })
end

G.FUNCS.pm_achievements = function(e)
    G.SETTINGS.paused = true
    local back = 'options'
    if e and e.config and e.config.id == 'pm_achievements_stats' then
        back = 'high_scores'
    end
    G.FUNCS.overlay_menu{
        definition = create_achievements_menu(back),
    }
end

G.FUNCS.pm_achievements_page = function(args)
    if not args or not args.cycle_config then return end
    if not G.OVERLAY_MENU then return end
    local list = G.OVERLAY_MENU:get_UIE_by_ID('pm_achievement_list')
    if not list then return end
    if list.config.object then list.config.object:remove() end
    list.config.object = UIBox{
        definition = create_UIBox_pm_achievement_page(
            args.cycle_config.current_option - 1),
        config = {offset = {x = 0, y = 0}, align = 'cm', parent = list},
    }
end

local function node_has_button(node, name)
    if type(node) ~= 'table' then return false end
    if node.config and (node.config.button == name or node.config.id == name) then
        return true
    end
    if node.nodes then
        for _, child in pairs(node.nodes) do
            if node_has_button(child, name) then return true end
        end
    end
    return false
end

-- Called by options.lua immediately before appending Initialize Port Settings.
G.BALATRO_PM_options_before_port_setup = function()
    if G.F_NO_ACHIEVEMENTS then return nil end
    local ok, button = pcall(UIBox_button, {
        id = 'pm_achievements',
        label = {achievements_label()},
        button = 'pm_achievements',
        minw = 5,
        colour = G.C.BLUE,
    })
    if ok then return button end
end

local original_create_UIBox_high_scores = create_UIBox_high_scores
function create_UIBox_high_scores(...)
    local definition = original_create_UIBox_high_scores(...)
    if G.F_NO_ACHIEVEMENTS then return definition end

    local ok, button = pcall(UIBox_button, {
        id = 'pm_achievements_stats',
        button = 'pm_achievements',
        label = {achievements_label()},
        minw = 7.5,
        minh = 1,
        colour = G.C.BLUE,
        focus_args = {nav = 'wide'},
    })
    if not ok or not button then return definition end

    local function find_usage_column(node)
        if type(node) ~= 'table' or type(node.nodes) ~= 'table' then return nil end
        for _, child in pairs(node.nodes) do
            if node_has_button(child, 'usage') then
                return node
            end
        end
        for _, child in pairs(node.nodes) do
            local found = find_usage_column(child)
            if found then return found end
        end
        return nil
    end

    local column = find_usage_column(definition)
    if column and column.nodes then
        column.nodes[#column.nodes + 1] = button
    end
    return definition
end
