local BaseEnemy = require("entities.enemies.BaseEnemy")
local Utils = require("utils.Utils")
local Bullet = require("entities.Bullet")
local C = require("utils.Constants")

local BossEnemy = {}
BossEnemy.__index = BossEnemy
setmetatable(BossEnemy, {__index = BaseEnemy})

function BossEnemy.new(x, y, difficultyMult)
    local self = BaseEnemy.new("boss", x, y, difficultyMult)
    setmetatable(self, BossEnemy)
    self.phase = 1
    self.orbitAngle = 0
    self.orbitSpeed = 1.2
    self.orbitDist = 180
    self.color2 = {C.ENEMY.boss.color2[1], C.ENEMY.boss.color2[2], C.ENEMY.boss.color2[3]}
    self.fanCount = C.ENEMY.boss.fanCount
    self.fanSpread = C.ENEMY.boss.fanSpread
    self.pulseTimer = 0
    self.phaseChanged = false
    -- Phase transition telegraph
    self.phaseTransitionTimer = 0
    self.phaseTransitionDuration = 1.5  -- seconds of telegraph before becoming aggressive
    self.inPhaseTransition = false
    return self
end

function BossEnemy:update(dt, playerX, playerY, bullets)
    BaseEnemy.update(self, dt, playerX, playerY, bullets)
    if not self.alive then return end

    self.pulseTimer = self.pulseTimer + dt

    -- Phase transition telegraph
    if self.inPhaseTransition then
        self.phaseTransitionTimer = self.phaseTransitionTimer - dt
        if self.phaseTransitionTimer <= 0 then
            self.inPhaseTransition = false
            self.fireRate = self.fireRate * 0.6
            self.speed = self.speed * 1.3
        end
        -- During transition, boss stands still and pulses
        return
    end

    -- Phase check
    if self.phase == 1 and self.hp <= self.maxHp * 0.5 then
        self.phase = 2
        self.phaseChanged = true
        self.inPhaseTransition = true
        self.phaseTransitionTimer = self.phaseTransitionDuration
    end

    if self.phase == 1 then
        -- Orbit around player
        self.orbitAngle = self.orbitAngle + self.orbitSpeed * dt
        local targetX = playerX + math.cos(self.orbitAngle) * self.orbitDist
        local targetY = playerY + math.sin(self.orbitAngle) * self.orbitDist
        local dx, dy = Utils.normalize(targetX - self.x, targetY - self.y)
        self.x = self.x + dx * self.speed * 2 * dt
        self.y = self.y + dy * self.speed * 2 * dt
    else
        -- Phase 2: charge at player
        local dx, dy = Utils.normalize(playerX - self.x, playerY - self.y)
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end

    -- Shooting: fan of bullets
    self.fireTimer = self.fireTimer - dt
    if self.fireTimer <= 0 then
        local baseAngle = self.angle
        local halfSpread = self.fanSpread / 2
        for i = 1, self.fanCount do
            local a = baseAngle - halfSpread + (i - 1) * (self.fanSpread / (self.fanCount - 1))
            local bx = self.x + math.cos(a) * (self.radius + 5)
            local by = self.y + math.sin(a) * (self.radius + 5)
            table.insert(bullets, Bullet.new(bx, by, a, nil, false))
        end
        self.fireTimer = self.fireRate
    end

    -- Clamp loosely
    self.x = Utils.clamp(self.x, -50, C.WINDOW_WIDTH + 50)
    self.y = Utils.clamp(self.y, -50, C.WINDOW_HEIGHT + 50)
end

function BossEnemy:draw()
    if not self.alive then return end

    local pulse = 1 + math.sin(self.pulseTimer * 4) * 0.08

    -- Outer glow
    local glowAlpha = 0.15 + math.sin(self.pulseTimer * 3) * 0.1
    love.graphics.setColor(1, 0.3, 0.1, glowAlpha)
    love.graphics.circle("fill", self.x, self.y, self.radius * 1.8 * pulse)

    -- Body gradient (lerp between color and color2 based on phase)
    local t = self.phase == 2 and 0.5 + math.sin(self.pulseTimer * 6) * 0.5 or 0
    local r = Utils.lerp(self.color[1], self.color2[1], t)
    local g = Utils.lerp(self.color[2], self.color2[2], t)
    local b = Utils.lerp(self.color[3], self.color2[3], t)

    if self.hitFlash > 0 then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(r, g, b)
    end

    -- Draw as octagon
    local sides = 8
    local verts = {}
    for i = 1, sides do
        local a = (i / sides) * math.pi * 2 + self.pulseTimer * 0.5
        table.insert(verts, self.x + math.cos(a) * self.radius * pulse)
        table.insert(verts, self.y + math.sin(a) * self.radius * pulse)
    end
    love.graphics.polygon("fill", verts)

    -- Inner eye
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.circle("fill", self.x, self.y, self.radius * 0.25)

    -- Phase indicator
    if self.phase == 2 then
        love.graphics.setColor(1, 0, 0, 0.4 + math.sin(self.pulseTimer * 8) * 0.3)
        love.graphics.circle("line", self.x, self.y, self.radius * 1.3 * pulse)
    end

    -- Phase transition telegraph
    if self.inPhaseTransition then
        local progress = 1 - (self.phaseTransitionTimer / self.phaseTransitionDuration)
        local expandRadius = self.radius * (1.5 + progress * 2)
        love.graphics.setColor(1, 0.1, 0, 0.6 * (0.5 + math.sin(self.pulseTimer * 12) * 0.5))
        love.graphics.circle("line", self.x, self.y, expandRadius)
        love.graphics.circle("line", self.x, self.y, expandRadius * 0.7)

        -- Warning text
        love.graphics.setColor(1, 0.2, 0, 0.8 + math.sin(self.pulseTimer * 10) * 0.2)
        local font = love.graphics.getFont()
        local warnText = "!! ENRAGED !!"
        local tw = font:getWidth(warnText)
        love.graphics.print(warnText, self.x - tw / 2, self.y - self.radius - 30)
    end

    -- HP bar (wider for boss)
    local barW = self.radius * 3
    local barH = 5
    local bx = self.x - barW / 2
    local by = self.y - self.radius - 12
    local ratio = self.hp / self.maxHp
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", bx, by, barW, barH)
    -- Color transitions from green to red
    love.graphics.setColor(1 - ratio, ratio, 0.1)
    love.graphics.rectangle("fill", bx, by, barW * ratio, barH)
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.rectangle("line", bx, by, barW, barH)

    love.graphics.setColor(1, 1, 1)
end

return BossEnemy
