local BaseEnemy = require("entities.enemies.BaseEnemy")
local Utils = require("utils.Utils")
local Bullet = require("entities.Bullet")

local ShooterEnemy = {}
ShooterEnemy.__index = ShooterEnemy
setmetatable(ShooterEnemy, {__index = BaseEnemy})

function ShooterEnemy.new(x, y, difficultyMult)
    local self = BaseEnemy.new("shooter", x, y, difficultyMult)
    setmetatable(self, ShooterEnemy)
    self.strafeDir = math.random() > 0.5 and 1 or -1
    self.strafeTimer = 0
    self.strafeInterval = 2 + math.random() * 2  -- change direction every 2-4s
    self.burstCount = 0
    self.burstDelay = 0.15  -- delay between burst shots
    self.burstTimer = 0
    return self
end

function ShooterEnemy:update(dt, playerX, playerY, bullets)
    BaseEnemy.update(self, dt, playerX, playerY, bullets)
    if not self.alive then return end

    local dist = Utils.distance(self.x, self.y, playerX, playerY)
    local dx, dy = Utils.normalize(playerX - self.x, playerY - self.y)

    -- Move towards/away from preferred distance
    if dist > self.preferredDist + 30 then
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    elseif dist < self.preferredDist - 30 then
        self.x = self.x - dx * self.speed * dt
        self.y = self.y - dy * self.speed * dt
    else
        -- Strafe laterally at preferred distance
        self.strafeTimer = self.strafeTimer + dt
        if self.strafeTimer >= self.strafeInterval then
            self.strafeTimer = 0
            self.strafeDir = -self.strafeDir
        end
        local perpX, perpY = -dy, dx
        self.x = self.x + perpX * self.speed * 0.6 * self.strafeDir * dt
        self.y = self.y + perpY * self.speed * 0.6 * self.strafeDir * dt
    end

    -- Burst firing: fire 2 shots in quick succession
    if self.burstCount > 0 then
        self.burstTimer = self.burstTimer - dt
        if self.burstTimer <= 0 then
            local bx = self.x + math.cos(self.angle) * (self.radius + 5)
            local by = self.y + math.sin(self.angle) * (self.radius + 5)
            table.insert(bullets, Bullet.new(bx, by, self.angle, nil, false))
            self.burstCount = self.burstCount - 1
            self.burstTimer = self.burstDelay
        end
    end

    self.fireTimer = self.fireTimer - dt
    if self.fireTimer <= 0 and self.burstCount == 0 then
        local bx = self.x + math.cos(self.angle) * (self.radius + 5)
        local by = self.y + math.sin(self.angle) * (self.radius + 5)
        table.insert(bullets, Bullet.new(bx, by, self.angle, nil, false))
        self.burstCount = 1  -- one more shot in burst
        self.burstTimer = self.burstDelay
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
