local Utils = {}

function Utils.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

function Utils.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function Utils.clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

function Utils.checkCircleCollision(x1, y1, r1, x2, y2, r2)
    local dist = Utils.distance(x1, y1, x2, y2)
    return dist < (r1 + r2)
end

function Utils.normalize(x, y)
    local len = math.sqrt(x * x + y * y)
    if len == 0 then return 0, 0 end
    return x / len, y / len
end

function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.randomEdgePosition(margin)
    margin = margin or 20
    local side = math.random(1, 4)
    local x, y
    if side == 1 then -- top
        x = math.random(0, 800)
        y = -margin
    elseif side == 2 then -- bottom
        x = math.random(0, 800)
        y = 600 + margin
    elseif side == 3 then -- left
        x = -margin
        y = math.random(0, 600)
    else -- right
        x = 800 + margin
        y = math.random(0, 600)
    end
    return x, y
end

return Utils
