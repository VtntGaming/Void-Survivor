local BaseEnemy = require("entities.enemies.BaseEnemy")
local Utils = require("utils.Utils")

local ChaserEnemy = {}
ChaserEnemy.__index = ChaserEnemy
setmetatable(ChaserEnemy, {__index = BaseEnemy})

function ChaserEnemy.new(x, y, difficultyMult)
    local self = BaseEnemy.new("chaser", x, y, difficultyMult)
    setmetatable(self, ChaserEnemy)
    return self
end

function ChaserEnemy:update(dt, playerX, playerY, bullets)
    BaseEnemy.update(self, dt, playerX, playerY, bullets)
    if not self.alive then return end

    local dx, dy = Utils.normalize(playerX - self.x, playerY - self.y)
    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt
end

function ChaserEnemy:draw()
    if not self.alive then return end
    self:setColor()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)
    love.graphics.polygon("fill",
        self.radius, 0,
        0, -self.radius * 0.7,
        -self.radius * 0.6, 0,
        0, self.radius * 0.7
    )
    love.graphics.pop()
    self:drawHPBar()
    love.graphics.setColor(1, 1, 1)
end

return ChaserEnemy
