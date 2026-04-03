local Utils = require("utils")

local Player = {}
Player.__index = Player

function Player.new()
    local self = setmetatable({}, Player)
    self.x = 400
    self.y = 300
    self.radius = 12
    self.speed = 200
    self.baseSpeed = 200
    self.hp = 100
    self.maxHp = 100
    self.alive = true
    self.angle = 0
    self.invincible = false
    self.invincibleTimer = 0
    self.invincibleDuration = 0.5
    self.flashTimer = 0
    self.visible = true
    -- Power-up states
    self.speedBoost = false
    self.speedBoostTimer = 0
    self.rapidFire = false
    self.rapidFireTimer = 0
    self.shield = false
    -- Shooting
    self.fireRate = 0.15
    self.baseFireRate = 0.15
    self.fireTimer = 0
    return self
end

function Player:update(dt, bullets)
    if not self.alive then return end

    -- Movement
    local dx, dy = 0, 0
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then dy = -1 end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then dy = 1 end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then dx = -1 end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then dx = 1 end

    if dx ~= 0 or dy ~= 0 then
        dx, dy = Utils.normalize(dx, dy)
    end

    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt

    -- Clamp to arena
    self.x = Utils.clamp(self.x, self.radius, 800 - self.radius)
    self.y = Utils.clamp(self.y, self.radius, 600 - self.radius)

    -- Aim toward mouse
    local mx, my = love.mouse.getPosition()
    self.angle = Utils.angle(self.x, self.y, mx, my)

    -- Shooting
    self.fireTimer = self.fireTimer - dt
    if love.mouse.isDown(1) and self.fireTimer <= 0 then
        self:shoot(bullets)
        self.fireTimer = self.fireRate
    end

    -- Invincibility
    if self.invincible then
        self.invincibleTimer = self.invincibleTimer - dt
        self.flashTimer = self.flashTimer + dt
        if self.flashTimer >= 0.07 then
            self.flashTimer = 0
            self.visible = not self.visible
        end
        if self.invincibleTimer <= 0 then
            self.invincible = false
            self.visible = true
        end
    end

    -- Power-up timers
    if self.speedBoost then
        self.speedBoostTimer = self.speedBoostTimer - dt
        self.speed = self.baseSpeed * 1.5
        if self.speedBoostTimer <= 0 then
            self.speedBoost = false
            self.speed = self.baseSpeed
        end
    end

    if self.rapidFire then
        self.rapidFireTimer = self.rapidFireTimer - dt
        self.fireRate = self.baseFireRate / 2
        if self.rapidFireTimer <= 0 then
            self.rapidFire = false
            self.fireRate = self.baseFireRate
        end
    end
end

function Player:shoot(bullets)
    local bx = self.x + math.cos(self.angle) * (self.radius + 5)
    local by = self.y + math.sin(self.angle) * (self.radius + 5)
    local Bullet = require("bullet")
    table.insert(bullets, Bullet.new(bx, by, self.angle, 500, true))
end

function Player:takeDamage(amount)
    if self.invincible then return end
    if self.shield then
        self.shield = false
        self.invincible = true
        self.invincibleTimer = self.invincibleDuration
        return
    end
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self.hp = 0
        self.alive = false
    else
        self.invincible = true
        self.invincibleTimer = self.invincibleDuration
    end
end

function Player:heal(amount)
    self.hp = math.min(self.hp + amount, self.maxHp)
end

function Player:applyPowerUp(type)
    if type == "health" then
        self:heal(25)
    elseif type == "speed" then
        self.speedBoost = true
        self.speedBoostTimer = 5
    elseif type == "rapid" then
        self.rapidFire = true
        self.rapidFireTimer = 5
    elseif type == "shield" then
        self.shield = true
    end
end

function Player:draw()
    if not self.alive then return end
    if not self.visible then return end

    -- Draw ship body
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)

    -- Ship shape (triangle)
    if self.shield then
        love.graphics.setColor(0, 1, 1, 0.3)
        love.graphics.circle("fill", 0, 0, self.radius + 5)
    end

    love.graphics.setColor(0.2, 0.8, 1)
    love.graphics.polygon("fill",
        self.radius, 0,
        -self.radius * 0.7, -self.radius * 0.6,
        -self.radius * 0.4, 0,
        -self.radius * 0.7, self.radius * 0.6
    )

    -- Engine glow
    love.graphics.setColor(1, 0.5, 0.1, 0.8)
    love.graphics.polygon("fill",
        -self.radius * 0.4, -self.radius * 0.3,
        -self.radius * 0.9, 0,
        -self.radius * 0.4, self.radius * 0.3
    )

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1)
end

return Player
