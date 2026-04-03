local Bullet = {}
Bullet.__index = Bullet

function Bullet.new(x, y, angle, speed, isPlayerBullet)
    local self = setmetatable({}, Bullet)
    self.x = x
    self.y = y
    self.angle = angle
    self.speed = speed or 400
    self.radius = isPlayerBullet and 3 or 4
    self.isPlayerBullet = isPlayerBullet or false
    self.damage = isPlayerBullet and 25 or 15
    self.alive = true
    self.vx = math.cos(angle) * self.speed
    self.vy = math.sin(angle) * self.speed
    return self
end

function Bullet:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    -- Remove if off screen
    if self.x < -20 or self.x > 820 or self.y < -20 or self.y > 620 then
        self.alive = false
    end
end

function Bullet:draw()
    if self.isPlayerBullet then
        love.graphics.setColor(1, 1, 0.3)
    else
        love.graphics.setColor(1, 0.2, 0.2)
    end
    love.graphics.circle("fill", self.x, self.y, self.radius)

    -- Glow effect
    if self.isPlayerBullet then
        love.graphics.setColor(1, 1, 0.3, 0.3)
    else
        love.graphics.setColor(1, 0.2, 0.2, 0.3)
    end
    love.graphics.circle("fill", self.x, self.y, self.radius * 2)

    love.graphics.setColor(1, 1, 1)
end

return Bullet
