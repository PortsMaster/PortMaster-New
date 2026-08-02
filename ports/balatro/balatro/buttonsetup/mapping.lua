-- SDL controller mapping strings.
--
-- A mapping line is a GUID, a display name, and then any number of
-- `control:input` pairs, e.g.
--
--   03000000...,Anbernic gamepad,a:b1,b:b0,dpup:h0.1,platform:Linux,
--
-- The wizard only ever learns a handful of controls, so the device's existing
-- mapping is used as the base and the learned entries replace their
-- counterparts in it. Everything the device already had right -- sticks,
-- triggers, the D-pad -- is carried across untouched.
--
-- Kept separate from main.lua because it is the only part with a right and a
-- wrong answer that can be checked without a handheld in front of you.

local M = {}

-- SDL hat bitmask, as it appears after the dot in `dpup:h0.1`.
M.HAT_MASK = {u = 1, r = 2, d = 4, l = 8}

function M.split(mapping)
    local fields = {}
    for field in string.gmatch(mapping, '[^,]+') do
        fields[#fields + 1] = field
    end
    return fields
end

-- The set of controls a mapping already binds, by name.
function M.controls(mapping)
    local bound = {}
    if not mapping or mapping == '' then return bound end
    local fields = M.split(mapping)
    for i = 3, #fields do
        local control = fields[i]:match('^([^:]+):')
        if control then bound[control] = true end
    end
    return bound
end

-- Whether one press would answer for both inputs, which is what makes binding
-- them to two controls wrong. `a3` is the whole of axis 3 and so collides with
-- either half of it, but `+a3` and `-a3` are opposite ends of one stick -- left
-- and right, or up and down -- and are no more the same input than two buttons
-- are. Treating those two as one is what would stop a D-pad or a pair of
-- triggers sharing an axis from ever being answered.
function M.conflict(one, other)
    if one == other then return true end
    local one_sign, one_axis = one:match('^([+-]?)a(%d+)$')
    local other_sign, other_axis = other:match('^([+-]?)a(%d+)$')
    if not one_axis or not other_axis or one_axis ~= other_axis then return false end
    return one_sign == '' or other_sign == '' or one_sign == other_sign
end

-- A name with a comma in it would be read back as an extra control field.
function M.sanitize_name(name)
    name = (name or ''):gsub(',', ' '):gsub('^%s+', ''):gsub('%s+$', '')
    if name == '' then name = 'Controller' end
    return name
end

-- learned is an ordered list of {control=..., input=...}, so the same answers
-- always produce the same line regardless of table iteration order.
function M.build(guid, name, learned, base)
    local order, values = {}, {}
    local function put(control, input)
        if values[control] == nil then order[#order + 1] = control end
        values[control] = input
    end

    if base and base ~= '' then
        local fields = M.split(base)
        -- The base line's own name is the one the device is known by, so keep
        -- it -- unless it is the `*` that a catch-all database entry carries
        -- instead of a name, which says nothing about the pad in hand. SDL
        -- matches on the GUID and only ever shows this, so the pad's own name
        -- is the better answer whenever the base has none worth having.
        local base_name = fields[2]
        if base_name and base_name ~= '' and base_name ~= '*' then
            name = base_name
        end
        for i = 3, #fields do
            local control, input = fields[i]:match('^([^:]+):(.+)$')
            if control then put(control, input) end
        end
    end

    for _, entry in ipairs(learned) do
        put(entry.control, entry.input)
    end

    -- An answer was given with the button in hand; a base entry that claims the
    -- same input for something else was already wrong, and is the reason for
    -- being here at all. Drop it rather than leave SDL with one input bound
    -- twice, which would make that button do both things at once. Compared
    -- through conflict rather than as text, because a base line writing an axis
    -- as `+a2` and an answer writing it as `a2` are still the one input.
    local answered = {}
    for _, entry in ipairs(learned) do answered[entry.control] = true end
    for control, input in pairs(values) do
        if not answered[control] then
            for _, entry in ipairs(learned) do
                if M.conflict(entry.input, input) then
                    values[control] = nil
                    break
                end
            end
        end
    end

    -- SDL ignores a mapping whose platform is not the one it is running on.
    put('platform', 'Linux')

    local out = {guid, M.sanitize_name(name)}
    for _, control in ipairs(order) do
        if values[control] then
            out[#out + 1] = control .. ':' .. values[control]
        end
    end
    return table.concat(out, ',') .. ','
end

return M
