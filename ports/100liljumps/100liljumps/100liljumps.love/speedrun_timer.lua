function initialize_timer()
    return {
        paused = false,
        start_time = love.timer.getTime(),
        current_time = 0
    }
end

function start_timer(timer)
    timer.paused = false
    timer.start_time = love.timer.getTime()
end

function pause_timer(timer)
    local difference = love.timer.getTime() - timer.start_time
    timer.current_time = difference

    timer.paused = true
end

function restart_timer(timer)
    timer.current_time = 0
    timer.start_time = love.timer.getTime()
    pause_timer(timer)
end

function time_difference(timer)
    if(timer.paused) then
        return timer.current_time
    else
        local difference = love.timer.getTime() - timer.start_time
        timer.current_time = difference

        return difference
    end
end

function zero_left_pad(number)
    if(#number == 1) then
        return "0" .. number
    end

    return number
end

function milliseconds_zero_left_pad(number)
    local result = number:sub(3, #number)
    if(#result < 3) then
        local zeroes_amount = 3 - #result
        local zeroes = string.rep("0", zeroes_amount)

        return zeroes .. result
    end

    return result
end

function time_display_string(time_in_seconds)
    if not time_in_seconds then
        -- This happens if you delete the save and manually set the game as won
        return "H4cK3r", ":D"
    end

    local hours = math.floor(math.floor(time_in_seconds) / (60 * 60))
    if(hours > 99) then
        return "99:99:99.", "999"
    end
    local unpadded_hours = tostring(hours)
    local hours_str = zero_left_pad(tostring(hours))
    time_in_seconds = time_in_seconds - hours*60*60

    local minutes = math.floor(math.floor(time_in_seconds) / 60)
    local unpadded_minutes = tostring(minutes)
    local minutes_str = zero_left_pad(tostring(minutes))
    time_in_seconds = time_in_seconds - minutes*60

    local seconds = math.floor(time_in_seconds)
    local seconds_str = zero_left_pad(tostring(seconds))
    time_in_seconds = time_in_seconds - seconds

    local milliseconds = math.floor(time_in_seconds*1000) / 1000
    local milliseconds_str = milliseconds_zero_left_pad(tostring(milliseconds))

    if(hours >= 10) then
        return hours_str .. ":" .. minutes_str .. ":" .. seconds_str .. ".", milliseconds_str
    elseif(hours > 0) then
        return unpadded_hours .. ":" .. minutes_str .. ":" .. seconds_str .. ".", milliseconds_str
    elseif(minutes >= 10) then
        return minutes_str .. ":" .. seconds_str .. ".", milliseconds_str
    else
        return unpadded_minutes .. ":" .. seconds_str .. ".", milliseconds_str
    end
end