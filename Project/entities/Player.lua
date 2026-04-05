local Utils = require("utils.Utils")
local C = require("utils.Constants")
local Bullet = require("entities.Bullet")

local Player = {}
Player.__index = Player

function Player.new()
    local self = setmetatable({}, Player)
    self.x = C.PLAYER_START_X
    self.y = C.PLAYER_START_Y
    self.radius = C.PLAYER_RADIUS
    self.speed = C.PLAYER_SPEED
    self.baseSpeed = C.PLAYER_SPEED
    self.hp = C.PLAYER_HP
    self.maxHp = C.PLAYER_HP
    self.alive = true
    self.angle = 0
    self.invincible = false
    self.invincibleTimer = 0
    self.invincibleDuration = C.PLAYER_INVINCIBLE_DURATION
    self.flashTimer = 0
    self.visible = true

    -- Power-up states
    self.speedBoost = false
    self.speedBoostTimer = 0
    self.rapidFire = false
    self.rapidFireTimer = 0
    self.shield = false
    self.magnet = false
    self.magnetTimer = 0
    self.magnetRange = C.MAGNET_RANGE
    self.magnetPullSpeed = C.MAGNET_PULL_SPEED

    -- Weapon system
    self.weaponType = "normal"  -- "normal", "spread", "heavy"
    self.weaponTimer = 0
    self.fireRate = C.PLAYER_FIRE_RATE
    self.baseFireRate = C.PLAYER_FIRE_RATE
    self.fireTimer = 0

    -- Damage chip display
    self.displayHp = C.PLAYER_HP  -- trailing HP for red bar effect
    self.chipDecayRate = 30       -- HP units per second the chip bar drains

    -- Input state (set by InputController)
    self.moveX = 0
    self.moveY = 0
    self.aimX = 0
    self.aimY = 0
    self.shooting = false

    return self
end

function Player:update(dt, bullets)
    if not self.alive then return end

    -- Movement (input already processed by InputController)
    local dx, dy = self.moveX, self.moveY
    if dx ~= 0 or dy ~= 0 then
        dx, dy = Utils.normalize(dx, dy)
    end

    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt
    self.x = Utils.clamp(self.x, self.radius, C.WINDOW_WIDTH - self.radius)
    self.y = Utils.clamp(self.y, self.radius, C.WINDOW_HEIGHT - self.radius)

    -- Aim
    self.angle = Utils.angle(self.x, self.y, self.aimX, self.aimY)

    -- Shooting
    self.fireTimer = self.fireTimer - dt
    if self.shooting and self.fireTimer <= 0 then
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

    if self.magnet then
        self.magnetTimer = self.magnetTimer - dt
        if self.magnetTimer <= 0 then
            self.magnet = false
        end
    end

    -- Weapon timer
    if self.weaponType ~= "normal" then
        self.weaponTimer = self.weaponTimer - dt
        if self.weaponTimer <= 0 then
            self.weaponType = "normal"
        end
    end

    -- Chip HP decay (trailing red bar)
    if self.displayHp > self.hp then
        self.displayHp = self.displayHp - self.chipDecayRate * dt
        if self.displayHp < self.hp then
            self.displayHp = self.hp
        end
    end
end

function Player:shoot(bullets)
    local spawnDist = self.radius + 5

    if self.weaponType == "spread" then
        for i = 1, C.SPREAD_COUNT do
            local offset = (i - math.ceil(C.SPREAD_COUNT / 2)) * C.SPREAD_ANGLE
            local a = self.angle + offset
            local bx = self.x + math.cos(a) * spawnDist
            local by = self.y + math.sin(a) * spawnDist
            table.insert(bullets, Bullet.new(bx, by, a, C.PLAYER_BULLET_SPEED, true))
        end
    elseif self.weaponType == "heavy" then
        local bx = self.x + math.cos(self.angle) * spawnDist
        local by = self.y + math.sin(self.angle) * spawnDist
        table.insert(bullets, Bullet.new(bx, by, self.angle, nil, true, "heavy"))
    else
        local bx = self.x + math.cos(self.angle) * spawnDist
        local by = self.y + math.sin(self.angle) * spawnDist
        table.insert(bullets, Bullet.new(bx, by, self.angle, C.PLAYER_BULLET_SPEED, true))
    end
end

function Player:takeDamage(amount)
    if self.invincible then return false end
    if self.shield then
        self.shield = false
        self.invincible = true
        self.invincibleTimer = self.invincibleDuration
        return false
    end
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self.hp = 0
        self.alive = false
    else
        self.invincible = true
        self.invincibleTimer = self.invincibleDuration
    end
    return true  -- damage was taken
end

function Player:heal(amount)
    self.hp = math.min(self.hp + amount, self.maxHp)
end

function Player:applyPowerUp(puType)
    if puType == "health" then
        self:heal(C.HEAL_AMOUNT)
    elseif puType == "speed" then
        self.speedBoost = true
        self.speedBoostTimer = C.SPEED_BOOST_DURATION
    elseif puType == "rapid" then
        self.rapidFire = true
        self.rapidFireTimer = C.RAPID_FIRE_DURATION
    elseif puType == "shield" then
        self.shield = true
    elseif puType == "magnet" then
        self.magnet = true
        self.magnetTimer = C.MAGNET_DURATION
    elseif puType == "spread" then
        self.weaponType = "spread"
        self.weaponTimer = C.WEAPON_POWERUP_DURATION
    elseif puType == "heavy" then
        self.weaponType = "heavy"
        self.weaponTimer = C.WEAPON_POWERUP_DURATION
    end
end

function Player:draw()
    if not self.alive then return end
    if not self.visible then return end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)

    -- Magnet field
    if self.magnet then
        love.graphics.setColor(0.8, 0.2, 1, 0.12)
        love.graphics.circle("fill", 0, 0, self.radius + 14 + math.sin(love.timer.getTime() * 6) * 2)
        love.graphics.setColor(0.9, 0.5, 1, 0.35)
        love.graphics.circle("line", 0, 0, self.radius + 10)
    end

    -- Shield bubble
    if self.shield then
        love.graphics.setColor(0, 1, 1, 0.3)
        love.graphics.circle("fill", 0, 0, self.radius + 5)
    end

    -- Ship body
    if self.weaponType == "spread" then
        love.graphics.setColor(1, 0.6, 0.2)
    elseif self.weaponType == "heavy" then
        love.graphics.setColor(1, 0.3, 0.6)
    else
        love.graphics.setColor(0.2, 0.8, 1)
    end
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
