local C = require("utils.Constants")

local PowerUp = {}
PowerUp.__index = PowerUp

local TYPES = {
    health = {color = {0.2, 1, 0.2}, symbol = "+"},
    speed  = {color = {0.2, 0.5, 1}, symbol = "S"},
    rapid  = {color = {1, 1, 0.2},   symbol = "R"},
    shield = {color = {0, 1, 1},     symbol = "O"},
    magnet = {color = {0.85, 0.25, 1}, symbol = "M"},
    spread = {color = {1, 0.5, 0},   symbol = "W"},
    heavy  = {color = {1, 0.3, 0.6}, symbol = "H"},
}

-- Weighted drop table: support types drop more often, then adapt to player state
local DROP_TABLE = {
    {type = "health", weight = 24},
    {type = "speed",  weight = 14},
    {type = "rapid",  weight = 14},
    {type = "shield", weight = 18},
    {type = "magnet", weight = 12},
    {type = "spread", weight = 9},
    {type = "heavy",  weight = 9},
}

local function addWeight(entries, targetType, delta)
    for _, entry in ipairs(entries) do
        if entry.type == targetType then
            entry.weight = math.max(0, entry.weight + delta)
            return
        end
    end
end

local function weightedRandomType(player)
    local entries = {}
    for _, entry in ipairs(DROP_TABLE) do
        table.insert(entries, {type = entry.type, weight = entry.weight})
    end

    if player then
        local hpRatio = player.hp / math.max(1, player.maxHp)
        if hpRatio < 0.4 then
            addWeight(entries, "health", 18)
            addWeight(entries, "shield", 8)
        end
        if player.shield then addWeight(entries, "shield", -10) end
        if player.speedBoost then addWeight(entries, "speed", -6) end
        if player.rapidFire then addWeight(entries, "rapid", -6) end
        if player.magnet then addWeight(entries, "magnet", -8) end
        if player.weaponType == "normal" then
            addWeight(entries, "spread", 4)
            addWeight(entries, "heavy", 4)
        end
    end

    local totalWeight = 0
    for _, entry in ipairs(entries) do
        totalWeight = totalWeight + entry.weight
    end
    local roll = math.random() * totalWeight
    local cumulative = 0
    for _, entry in ipairs(entries) do
        cumulative = cumulative + entry.weight
        if roll <= cumulative then
            return entry.type
        end
    end
    return entries[#entries].type
end

function PowerUp.new(x, y, puType)
    local self = setmetatable({}, PowerUp)
    self.x = x
    self.y = y
    self.type = puType or weightedRandomType()
    self.radius = C.POWERUP_RADIUS
    self.alive = true
    self.lifetime = C.POWERUP_LIFETIME
    self.timer = 0
    self.bobOffset = 0
    local def = TYPES[self.type]
    self.color = def.color
    self.symbol = def.symbol
    return self
end

function PowerUp:update(dt)
    self.timer = self.timer + dt
    self.bobOffset = math.sin(self.timer * 3) * 3
    self.lifetime = self.lifetime - dt
    if self.lifetime <= 0 then
        self.alive = false
    end
end

function PowerUp:draw()
    if not self.alive then return end

    -- Flashing when about to expire
    if self.lifetime < 2 then
        if math.sin(self.timer * 10) < 0 then return end
    end

    local y = self.y + self.bobOffset

    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 0.2)
    love.graphics.circle("fill", self.x, y, self.radius * 2)

    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 0.8)
    love.graphics.circle("fill", self.x, y, self.radius)

    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.circle("line", self.x, y, self.radius)

    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local tw = font:getWidth(self.symbol)
    local th = font:getHeight()
    love.graphics.print(self.symbol, self.x - tw / 2, y - th / 2)
end

function PowerUp.randomDrop(x, y, player)
    if math.random() < C.POWERUP_DROP_CHANCE then
        return PowerUp.new(x, y, weightedRandomType(player))
    end
    return nil
end

return PowerUp
