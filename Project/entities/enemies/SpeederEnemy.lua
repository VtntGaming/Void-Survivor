local BaseEnemy = require("entities.enemies.BaseEnemy")
local Utils = require("utils.Utils")

local SpeederEnemy = {}
SpeederEnemy.__index = SpeederEnemy
setmetatable(SpeederEnemy, {__index = BaseEnemy})

function SpeederEnemy.new(x, y, difficultyMult)
    local self = BaseEnemy.new("speeder", x, y, difficultyMult)
    setmetatable(self, SpeederEnemy)
    self.weaveTimer = math.random() * math.pi * 2  -- random start phase
    self.weaveFreq = 5    -- oscillation frequency
    self.weaveAmplitude = 80  -- perpendicular offset strength
    return self
end

function SpeederEnemy:update(dt, playerX, playerY, bullets)
    BaseEnemy.update(self, dt, playerX, playerY, bullets)
    if not self.alive then return end

    -- Zigzag movement: chase + sine wave perpendicular
    local dx, dy = Utils.normalize(playerX - self.x, playerY - self.y)
    self.weaveTimer = self.weaveTimer + dt * self.weaveFreq
    local weave = math.sin(self.weaveTimer) * self.weaveAmplitude
    -- Perpendicular direction
    local px, py = -dy, dx
    self.x = self.x + (dx * self.speed + px * weave) * dt
    self.y = self.y + (dy * self.speed + py * weave) * dt
end

function SpeederEnemy:draw()
    if not self.alive then return end
    self:setColor()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)
    love.graphics.polygon("fill",
        self.radius, 0,
        -self.radius * 0.5, -self.radius * 0.6,
        -self.radius * 0.5, self.radius * 0.6
    )
    love.graphics.pop()
    self:drawHPBar()
    love.graphics.setColor(1, 1, 1)
end

return SpeederEnemy
