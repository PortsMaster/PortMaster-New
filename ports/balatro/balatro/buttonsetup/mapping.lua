local M = {}

M.HAT_MASK = {u = 1, r = 2, d = 4, l = 8}

function M.split(mapping)
    local fields = {}
    for field in string.gmatch(mapping, '[^,]+') do
        fields[#fields + 1] = field
    end
    return fields
end

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

function M.conflict(one, other)
    if one == other then return true end
    local one_sign, one_axis = one:match('^([+-]?)a(%d+)$')
    local other_sign, other_axis = other:match('^([+-]?)a(%d+)$')
    if not one_axis or not other_axis or one_axis ~= other_axis then return false end
    return one_sign == '' or other_sign == '' or one_sign == other_sign
end

function M.sanitize_name(name)
    name = (name or ''):gsub(',', ' '):gsub('^%s+', ''):gsub('%s+$', '')
    if name == '' then name = 'Controller' end
    return name
end

function M.build(guid, name, learned, base)
    local order, values = {}, {}
    local function put(control, input)
        if values[control] == nil then order[#order + 1] = control end
        values[control] = input
    end

    if base and base ~= '' then
        local fields = M.split(base)
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
