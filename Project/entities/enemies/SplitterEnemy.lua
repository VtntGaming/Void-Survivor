local BaseEnemy = require("entities.enemies.BaseEnemy")
local Utils = require("utils.Utils")
local C = require("utils.Constants")

local SplitterEnemy = {}
SplitterEnemy.__index = SplitterEnemy
setmetatable(SplitterEnemy, {__index = BaseEnemy})

function SplitterEnemy.new(x, y, difficultyMult)
    local self = BaseEnemy.new("splitter", x, y, difficultyMult)
    setmetatable(self, SplitterEnemy)
    self.dashInterval = 2.2
    self.dashCooldown = 1.2 + math.random() * 0.8
    self.telegraphDuration = 0.45
    self.telegraphTimer = 0
    self.dashDuration = 0.38
    self.dashTimer = 0
    self.dashDirX = 0
    self.dashDirY = 0
    self.pulseTimer = math.random() * math.pi * 2
    return self
end

function SplitterEnemy:update(dt, playerX, playerY, bullets)
    BaseEnemy.update(self, dt, playerX, playerY, bullets)
    if not self.alive then return end

    self.pulseTimer = self.pulseTimer + dt * 6

    if self.telegraphTimer > 0 then
        self.telegraphTimer = self.telegraphTimer - dt
        if self.telegraphTimer <= 0 then
            self.dashTimer = self.dashDuration
            self.dashDirX, self.dashDirY = Utils.normalize(playerX - self.x, playerY - self.y)
        end
        return
    end

    if self.dashTimer > 0 then
        self.dashTimer = self.dashTimer - dt
        self.x = self.x + self.dashDirX * self.speed * 2.4 * dt
        self.y = self.y + self.dashDirY * self.speed * 2.4 * dt
    else
        local dx, dy = Utils.normalize(playerX - self.x, playerY - self.y)
        local dist = Utils.distance(self.x, self.y, playerX, playerY)
        local driftX, driftY = -dy, dx
        local drift = math.sin(self.pulseTimer) * 24

        if dist > 140 then
            self.x = self.x + (dx * self.speed + driftX * drift) * dt
            self.y = self.y + (dy * self.speed + driftY * drift) * dt
        else
            self.x = self.x + driftX * drift * dt * 1.4
            self.y = self.y + driftY * drift * dt * 1.4
        end

        self.dashCooldown = self.dashCooldown - dt
        if self.dashCooldown <= 0 then
            self.telegraphTimer = self.telegraphDuration
            self.dashCooldown = self.dashInterval + math.random() * 0.5
        end
    end

    self.x = Utils.clamp(self.x, self.radius, C.WINDOW_WIDTH - self.radius)
    self.y = Utils.clamp(self.y, self.radius, C.WINDOW_HEIGHT - self.radius)
end

function SplitterEnemy:draw()
    if not self.alive then return end

    local pulse = 1 + math.sin(self.pulseTimer) * 0.08
    if self.hitFlash > 0 then
        love.graphics.setColor(1, 1, 1, self.spawnFadeAlpha)
    else
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.spawnFadeAlpha)
    end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)
    love.graphics.polygon("fill",
        self.radius * pulse, 0,
        0, -self.radius * 0.85 * pulse,
        -self.radius * 0.8 * pulse, 0,
        0, self.radius * 0.85 * pulse
    )

    love.graphics.setColor(1, 0.95, 1, 0.75 * self.spawnFadeAlpha)
    love.graphics.rectangle("fill", -self.radius * 0.15, -self.radius * 0.7, self.radius * 0.3, self.radius * 1.4)
    love.graphics.rectangle("fill", -self.radius * 0.7, -self.radius * 0.15, self.radius * 1.4, self.radius * 0.3)
    love.graphics.pop()

    if self.telegraphTimer > 0 then
        local a = 0.35 + math.sin(self.pulseTimer * 2) * 0.2
        love.graphics.setColor(1, 0.85, 0.25, a)
        love.graphics.circle("line", self.x, self.y, self.radius * 1.8)
    end

    self:drawHPBar()
    love.graphics.setColor(1, 1, 1)
end

return SplitterEnemy
