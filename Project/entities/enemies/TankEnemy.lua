local BaseEnemy = require("entities.enemies.BaseEnemy")
local Utils = require("utils.Utils")

local TankEnemy = {}
TankEnemy.__index = TankEnemy
setmetatable(TankEnemy, {__index = BaseEnemy})

function TankEnemy.new(x, y, difficultyMult)
    local self = BaseEnemy.new("tank", x, y, difficultyMult)
    setmetatable(self, TankEnemy)
    return self
end

function TankEnemy:update(dt, playerX, playerY, bullets)
    BaseEnemy.update(self, dt, playerX, playerY, bullets)
    if not self.alive then return end

    local dx, dy = Utils.normalize(playerX - self.x, playerY - self.y)
    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt
end

function TankEnemy:draw()
    if not self.alive then return end
    self:setColor()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)
    local r = self.radius * 0.85
    love.graphics.polygon("fill", r, -r, r, r, -r, r, -r, -r)
    love.graphics.pop()
    self:drawHPBar()
    love.graphics.setColor(1, 1, 1)
end

return TankEnemy
