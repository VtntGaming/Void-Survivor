local Utils = require("utils")
local Bullet = require("bullet")

local Enemy = {}
Enemy.__index = Enemy

-- Enemy type definitions
local TYPES = {
    chaser = {
        color = {1, 0.2, 0.2},
        radius = 10,
        speed = 120,
        hp = 50,
        damage = 15,
        score = 10,
        behavior = "chase"
    },
    shooter = {
        color = {0.7, 0.2, 1},
        radius = 11,
        speed = 70,
        hp = 40,
        damage = 10,
        score = 20,
        behavior = "shoot",
        fireRate = 1.5,
        preferredDist = 200
    },
    tank = {
        color = {1, 0.6, 0.1},
        radius = 18,
        speed = 50,
        hp = 150,
        damage = 25,
        score = 30,
        behavior = "chase"
    },
    speeder = {
        color = {1, 1, 0.2},
        radius = 8,
        speed = 220,
        hp = 25,
        damage = 10,
        score = 15,
        behavior = "chase"
    }
}

function Enemy.new(enemyType, x, y)
    local self = setmetatable({}, Enemy)
    local def = TYPES[enemyType]
    self.type = enemyType
    self.x = x or 0
    self.y = y or 0
    self.radius = def.radius
    self.speed = def.speed
    self.hp = def.hp
    self.maxHp = def.hp
    self.damage = def.damage
    self.score = def.score
    self.color = def.color
    self.behavior = def.behavior
    self.alive = true
    self.fireRate = def.fireRate or 0
    self.fireTimer = def.fireRate or 0
    self.preferredDist = def.preferredDist or 0
    self.angle = 0
    self.hitFlash = 0
    return self
end

function Enemy:update(dt, playerX, playerY, bullets)
    if not self.alive then return end

    self.angle = Utils.angle(self.x, self.y, playerX, playerY)
    local dist = Utils.distance(self.x, self.y, playerX, playerY)

    if self.behavior == "chase" then
        local dx, dy = Utils.normalize(playerX - self.x, playerY - self.y)
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    elseif self.behavior == "shoot" then
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
            table.insert(bullets, Bullet.new(bx, by, self.angle, 250, false))
            self.fireTimer = self.fireRate
        end
    end

    -- Keep in bounds (loosely)
    self.x = Utils.clamp(self.x, -30, 830)
    self.y = Utils.clamp(self.y, -30, 630)

    -- Hit flash
    if self.hitFlash > 0 then
        self.hitFlash = self.hitFlash - dt
    end
end

function Enemy:takeDamage(amount)
    self.hp = self.hp - amount
    self.hitFlash = 0.08
    if self.hp <= 0 then
        self.alive = false
        return true -- killed
    end
    return false
end

function Enemy:draw()
    if not self.alive then return end

    -- Body
    if self.hitFlash > 0 then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    end

    if self.type == "chaser" then
        -- Diamond shape
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
    elseif self.type == "shooter" then
        -- Hexagon-ish shape
        local sides = 6
        local verts = {}
        for i = 1, sides do
            local a = (i / sides) * math.pi * 2 + self.angle
            table.insert(verts, self.x + math.cos(a) * self.radius)
            table.insert(verts, self.y + math.sin(a) * self.radius)
        end
        love.graphics.polygon("fill", verts)
    elseif self.type == "tank" then
        -- Square rotated
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(self.angle)
        local r = self.radius * 0.85
        love.graphics.polygon("fill", r, -r, r, r, -r, r, -r, -r)
        love.graphics.pop()
    elseif self.type == "speeder" then
        -- Small triangle
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(self.angle)
        love.graphics.polygon("fill",
            self.radius, 0,
            -self.radius * 0.5, -self.radius * 0.6,
            -self.radius * 0.5, self.radius * 0.6
        )
        love.graphics.pop()
    end

    -- HP bar (only if damaged)
    if self.hp < self.maxHp then
        local barW = self.radius * 2
        local barH = 3
        local bx = self.x - barW / 2
        local by = self.y - self.radius - 8
        local ratio = self.hp / self.maxHp
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", bx, by, barW, barH)
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.rectangle("fill", bx, by, barW * ratio, barH)
    end

    love.graphics.setColor(1, 1, 1)
end

function Enemy.getTypesForWave(wave)
    local types = {"chaser"}
    if wave >= 4 then table.insert(types, "shooter") end
    if wave >= 7 then table.insert(types, "tank") end
    if wave >= 10 then table.insert(types, "speeder") end
    return types
end

return Enemy
