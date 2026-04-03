local C = require("utils.Constants")

local Bullet = {}
Bullet.__index = Bullet

function Bullet.new(x, y, angle, speed, isPlayerBullet, bulletType)
    local self = setmetatable({}, Bullet)
    self.x = x
    self.y = y
    self.angle = angle
    self.isPlayerBullet = isPlayerBullet or false
    self.bulletType = bulletType or "normal"
    self.alive = true
    self.pierced = false  -- for heavy bullets

    if self.bulletType == "heavy" then
        self.speed = speed or C.HEAVY_BULLET_SPEED
        self.radius = C.HEAVY_BULLET_RADIUS
        self.damage = C.HEAVY_BULLET_DAMAGE
        self.aoeRadius = C.HEAVY_AOE_RADIUS
    elseif self.isPlayerBullet then
        self.speed = speed or C.PLAYER_BULLET_SPEED
        self.radius = C.PLAYER_BULLET_RADIUS
        self.damage = C.PLAYER_BULLET_DAMAGE
    else
        self.speed = speed or C.ENEMY_BULLET_SPEED
        self.radius = C.ENEMY_BULLET_RADIUS
        self.damage = C.ENEMY_BULLET_DAMAGE
    end

    self.vx = math.cos(angle) * self.speed
    self.vy = math.sin(angle) * self.speed
    return self
end

function Bullet:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    if self.x < -20 or self.x > C.WINDOW_WIDTH + 20
    or self.y < -20 or self.y > C.WINDOW_HEIGHT + 20 then
        self.alive = false
    end
end

function Bullet:onHit()
    if self.bulletType == "heavy" and not self.pierced then
        self.pierced = true  -- pierce once then die on next hit
    else
        self.alive = false
    end
end

function Bullet:draw()
    if self.bulletType == "heavy" then
        love.graphics.setColor(1, 0.6, 0.1)
        love.graphics.circle("fill", self.x, self.y, self.radius)
        love.graphics.setColor(1, 0.6, 0.1, 0.3)
        love.graphics.circle("fill", self.x, self.y, self.radius * 2.5)
    elseif self.isPlayerBullet then
        love.graphics.setColor(1, 1, 0.3)
        love.graphics.circle("fill", self.x, self.y, self.radius)
        love.graphics.setColor(1, 1, 0.3, 0.3)
        love.graphics.circle("fill", self.x, self.y, self.radius * 2)
    else
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.circle("fill", self.x, self.y, self.radius)
        love.graphics.setColor(1, 0.2, 0.2, 0.3)
        love.graphics.circle("fill", self.x, self.y, self.radius * 2)
    end
    love.graphics.setColor(1, 1, 1)
end

return Bullet
