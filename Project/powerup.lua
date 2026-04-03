local Utils = require("utils")

local PowerUp = {}
PowerUp.__index = PowerUp

local TYPES = {
    health = {color = {0.2, 1, 0.2}, symbol = "+"},
    speed  = {color = {0.2, 0.5, 1}, symbol = "S"},
    rapid  = {color = {1, 1, 0.2},   symbol = "R"},
    shield = {color = {0, 1, 1},     symbol = "O"},
}

local TYPE_LIST = {"health", "speed", "rapid", "shield"}

function PowerUp.new(x, y, puType)
    local self = setmetatable({}, PowerUp)
    self.x = x
    self.y = y
    self.type = puType or TYPE_LIST[math.random(#TYPE_LIST)]
    self.radius = 10
    self.alive = true
    self.lifetime = 8
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

    local y = self.y + self.bobOffset

    -- Glow
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 0.2)
    love.graphics.circle("fill", self.x, y, self.radius * 2)

    -- Body
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 0.8)
    love.graphics.circle("fill", self.x, y, self.radius)

    -- Border
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.circle("line", self.x, y, self.radius)

    -- Symbol
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local tw = font:getWidth(self.symbol)
    local th = font:getHeight()
    love.graphics.print(self.symbol, self.x - tw / 2, y - th / 2)

    -- Flashing when about to expire
    if self.lifetime < 2 then
        local flash = math.sin(self.timer * 10) > 0
        if not flash then return end
    end
end

function PowerUp.randomDrop(x, y)
    -- 25% chance to drop a power-up
    if math.random() < 0.25 then
        return PowerUp.new(x, y)
    end
    return nil
end

return PowerUp
