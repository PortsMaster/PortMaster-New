-- A simple JSON encoding/decoding module for Lua
local json = {}

-- Simple encode implementation
function json.encode(val)
    if val == nil then
        return "null"
    elseif type(val) == "boolean" or type(val) == "number" then
        return tostring(val)
    elseif type(val) == "string" then
        val = string.gsub(val, "\\", "\\\\")
        val = string.gsub(val, "\"", "\\\"")
        val = string.gsub(val, "\n", "\\n")
        val = string.gsub(val, "\r", "\\r")
        val = string.gsub(val, "\t", "\\t")
        return '"' .. val .. '"'
    elseif type(val) == "table" then
        local isArray = function(t)
            local count = 0
            local isArr = true
            for k, v in pairs(t) do
                if type(k) == "number" and k > 0 and math.floor(k) == k then
                    count = count + 1
                else
                    isArr = false
                end
            end
            return isArr and count > 0
        end

        if isArray(val) then
            local res = {}
            for i, v in ipairs(val) do
                table.insert(res, json.encode(v))
            end
            return "[" .. table.concat(res, ",") .. "]"
        else
            local res = {}
            for k, v in pairs(val) do
                if type(k) == "string" and string.match(k, "^[%w_]+$") then
                    table.insert(res, '"' .. k .. '":' .. json.encode(v))
                else
                    table.insert(res, '[' .. json.encode(k) .. ']:' .. json.encode(v))
                end
            end
            return "{" .. table.concat(res, ",") .. "}"
        end
    else
        return "null" -- Unsupported type
    end
end

-- Simple JSON decode function
function json.decode(str)
    if str == nil or str == "" then
        return nil
    end
    
    -- Simplified JSON parser - only handles basic formats
    local pos = 1
    local char = function() return string.sub(str, pos, pos) end
    
    local function skipWhitespace()
        while pos <= #str and string.match(char(), "%s") do
            pos = pos + 1
        end
    end
    
    local function parseString()
        -- Skip opening quote
        pos = pos + 1
        local startPos = pos
        local escaped = false
        local result = ""
        
        while pos <= #str do
            local c = char()
            
            if escaped then
                if c == "\"" then result = result .. "\""
                elseif c == "\\" then result = result .. "\\"
                elseif c == "/" then result = result .. "/"
                elseif c == "b" then result = result .. "\b"
                elseif c == "f" then result = result .. "\f"
                elseif c == "n" then result = result .. "\n"
                elseif c == "r" then result = result .. "\r"
                elseif c == "t" then result = result .. "\t"
                else result = result .. c
                end
                escaped = false
            elseif c == "\\" then
                escaped = true
            elseif c == "\"" then
                pos = pos + 1
                return result
            else
                result = result .. c
            end
            
            pos = pos + 1
        end
        
        error("Unterminated string")
    end
    
    local function parseNumber()
        local startPos = pos
        while pos <= #str and string.match(char(), "[%d%.%-%+eE]") do
            pos = pos + 1
        end
        
        local numStr = string.sub(str, startPos, pos - 1)
        local num = tonumber(numStr)
        
        if not num then
            error("Invalid number format: " .. numStr)
        end
        return num
    end
    
    local parseValue -- Forward declaration
    
    local function parseArray()
        local result = {}
        
        -- Skip opening bracket
        pos = pos + 1
        skipWhitespace()
        
        -- Empty array check
        if char() == "]" then
            pos = pos + 1
            return result
        end
        
        -- Parse array elements
        while pos <= #str do
            table.insert(result, parseValue())
            skipWhitespace()
            
            if char() == "," then
                pos = pos + 1
                skipWhitespace()
            elseif char() == "]" then
                pos = pos + 1
                return result
            else
                error("Expected ',' or ']' in array at position " .. pos)
            end
        end
        
        error("Unterminated array")
    end
    
    local function parseObject()
        local result = {}
        
        -- Skip opening brace
        pos = pos + 1
        skipWhitespace()
        
        -- Empty object check
        if char() == "}" then
            pos = pos + 1
            return result
        end
        
        -- Parse object key-value pairs
        while pos <= #str do
            -- Key must be a string
            if char() ~= "\"" then
                error("Expected string key in object at position " .. pos)
            end
            
            local key = parseString()
            skipWhitespace()
            
            -- Expect colon after key
            if char() ~= ":" then
                error("Expected ':' after key in object at position " .. pos)
            end
            
            -- Skip colon
            pos = pos + 1
            skipWhitespace()
            
            -- Parse value
            local value = parseValue()
            result[key] = value
            
            skipWhitespace()
            
            if char() == "," then
                pos = pos + 1
                skipWhitespace()
            elseif char() == "}" then
                pos = pos + 1
                return result
            else
                error("Expected ',' or '}' in object at position " .. pos)
            end
        end
        
        error("Unterminated object")
    end
    
    -- Main value parser
    parseValue = function()
        skipWhitespace()
        
        if pos > #str then
            error("Unexpected end of input")
        end
        
        local c = char()
        
        if c == "{" then
            return parseObject()
        elseif c == "[" then
            return parseArray()
        elseif c == "\"" then
            return parseString()
        elseif string.match(c, "[%d%-%+]") then
            return parseNumber()
        elseif c == "t" and string.sub(str, pos, pos + 3) == "true" then
            pos = pos + 4
            return true
        elseif c == "f" and string.sub(str, pos, pos + 4) == "false" then
            pos = pos + 5
            return false
        elseif c == "n" and string.sub(str, pos, pos + 3) == "null" then
            pos = pos + 4
            return nil
        else
            error("Unexpected character at position " .. pos .. ": " .. c)
        end
    end
    
    -- Parse the main value
    skipWhitespace()
    local result = parseValue()
    skipWhitespace()
    
    -- Ensure we've parsed the entire string
    if pos <= #str then
        error("Unexpected data after end of JSON at position " .. pos)
    end
    
    return result
end

return json
