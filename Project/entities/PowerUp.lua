local C = require("utils.Constants")

local PowerUp = {}
PowerUp.__index = PowerUp

local TYPES = {
    health = {color = {0.2, 1, 0.2}, symbol = "+"},
    speed  = {color = {0.2, 0.5, 1}, symbol = "S"},
    rapid  = {color = {1, 1, 0.2},   symbol = "R"},
    shield = {color = {0, 1, 1},     symbol = "O"},
    spread = {color = {1, 0.5, 0},   symbol = "W"},
    heavy  = {color = {1, 0.3, 0.6}, symbol = "H"},
}

local TYPE_LIST = {"health", "speed", "rapid", "shield", "spread", "heavy"}

function PowerUp.new(x, y, puType)
    local self = setmetatable({}, PowerUp)
    self.x = x
    self.y = y
    self.type = puType or TYPE_LIST[math.random(#TYPE_LIST)]
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

function PowerUp.randomDrop(x, y)
    if math.random() < C.POWERUP_DROP_CHANCE then
        return PowerUp.new(x, y)
    end
    return nil
end

return PowerUp
