require("./lume")

function V2(x, y)
    return {
        x = x,
        y = y,
    }
end

function v2_add(v1, v2)
    return V2(v1.x + v2.x, v1.y + v2.y)
end

function v2_sub(v1, v2)
    return V2(v1.x - v2.x, v1.y - v2.y)
end

function v2_distance(v1, v2)
    return v2_length(v2_sub(v1, v2))
end

function v2_length(v)
    return math.sqrt(v.x*v.x + v.y*v.y)
end

function v2_equals(v1, v2)
    return v1.x == v2.x and v1.y == v2.y
end

function v2_normal(v)
    local v_length = v2_length(v)

    return V2(v.x / v_length, v.y / v_length)
end

function v2_scale(v, s)
    return V2(v.x*s, v.y*s)
end

function v2_clamp(v, max_length)
    local direction = v2_normal(v)
    local v_length = v2_length(v)

    if v_length > max_length then
        return v2_scale(direction, max_length)
    else
        return v
    end
end

function Rectangle(top_left, bottom_right)
    return {
        top_left = top_left,
        bottom_right = bottom_right,
    }
end

function Circle(center, radius)
    return {
        center = center,
        radius = radius
    }
end

function rectangle_dimensions(rectangle)
    local left_x   = rectangle.top_left.x
    local top_y    = rectangle.top_left.y
    local right_x  = rectangle.bottom_right.x
    local bottom_y = rectangle.bottom_right.y

    return {
        width  = math.abs(right_x - left_x),
        height = math.abs(bottom_y - top_y),
    }
end

function check_circ_circ_collision(c1, c2)
    local distance = v2_length(v2_sub(c1.center, c2.center))

    return distance <= (c1.radius + c2.radius)
end

function check_rect_rect_collision(r1, r2)
    local r1_width  = math.abs(r1.bottom_right.x - r1.top_left.x)
    local r1_height = math.abs(r1.bottom_right.y - r1.top_left.y)
    local r2_width  = math.abs(r2.bottom_right.x - r2.top_left.x)
    local r2_height = math.abs(r2.bottom_right.y - r2.top_left.y)
    local check1 = r1.bottom_right.x > r2.top_left.x
    local check2 = r1.top_left.x < r2.bottom_right.x
    local check3 = r1.bottom_right.y > r2.top_left.y
    local check4 = r1.top_left.y < r2.bottom_right.y

    return check1 and check2 and check3 and check4
end

function check_combined_hitbox_rect_collision(rects, target_rect)
    local collisions = {}
    for _, rect in rects do
        if(check_rect_rect_collision(rect, target_rect)) then
            table_insert(collisions, rect)
        end
    end

    return collisions
end

function create_segment(a, b)
    return {a = a, b = b}
end

function segment_is_vertical(segment)
    return segment.a.x == segment.b.x
end

function segment_is_horizontal(segment)
    return segment.a.y == segment.b.y
end

function easeIn(t, p)
    local p = p or 3
    return math.pow(t, p)
end

function easeOut(t, p)
    local p = p or 3
    return 1 - math.pow(1 - t, p)
end

function easeInOut(t, p)
    local t_to_p = math.pow(t, p)
    return t_to_p / (t_to_p + math.pow(1 - t, p))
end

function easeOutBack(t, amount)
    local c1 = amount
    local c3 = c1 + 1

    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
end

function easeInBack(t, amount)
    local c1 = amount
    local c3 = c1 + 1

    return c3*math.pow(t, 3) - c1*math.pow(t, 2)
end

function unclamped_lerp(a, b, amount)
    return a + (b - a) * amount
end

function color_lerp(c1, c2, t)
    local r = lume.lerp(c1[1], c2[1], t)
    local g = lume.lerp(c1[2], c2[2], t)
    local b = lume.lerp(c1[3], c2[3], t)

    return {r, g, b}
end

function float_to_fix_point_int(number, decimals)
    local decimals = decimals or 10000000

    return math.floor(number * decimals)
end

function fix_point_int_to_float(number, decimals)
    local decimals = decimals or 10000000
    assert(decimals ~= 0)

    return number / decimals
end
