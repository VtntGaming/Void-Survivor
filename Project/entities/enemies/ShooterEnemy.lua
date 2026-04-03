local BaseEnemy = require("entities.enemies.BaseEnemy")
local Utils = require("utils.Utils")
local Bullet = require("entities.Bullet")

local ShooterEnemy = {}
ShooterEnemy.__index = ShooterEnemy
setmetatable(ShooterEnemy, {__index = BaseEnemy})

function ShooterEnemy.new(x, y, difficultyMult)
    local self = BaseEnemy.new("shooter", x, y, difficultyMult)
    setmetatable(self, ShooterEnemy)
    return self
end

function ShooterEnemy:update(dt, playerX, playerY, bullets)
    BaseEnemy.update(self, dt, playerX, playerY, bullets)
    if not self.alive then return end

    local dist = Utils.distance(self.x, self.y, playerX, playerY)

    if dist > self.preferredDist + 30 then
        local dx, dy = Utils.normalize(playerX - self.x, playerY - self.y)
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    elseif dist < self.preferredDist - 30 then
        local dx, dy = Utils.normalize(self.x - playerX, self.y - playerY)
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end

    self.fireTimer = self.fireTimer - dt
    if self.fireTimer <= 0 then
        local bx = self.x + math.cos(self.angle) * (self.radius + 5)
        local by = self.y + math.sin(self.angle) * (self.radius + 5)
        table.insert(bullets, Bullet.new(bx, by, self.angle, nil, false))
        self.fireTimer = self.fireRate
    end
end

function ShooterEnemy:draw()
    if not self.alive then return end
    self:setColor()
    local sides = 6
    local verts = {}
    for i = 1, sides do
        local a = (i / sides) * math.pi * 2 + self.angle
        table.insert(verts, self.x + math.cos(a) * self.radius)
        table.insert(verts, self.y + math.sin(a) * self.radius)
    end
    love.graphics.polygon("fill", verts)
    self:drawHPBar()
    love.graphics.setColor(1, 1, 1)
end

return ShooterEnemy
