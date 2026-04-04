local Utils = require("utils.Utils")
local C = require("utils.Constants")

local BaseEnemy = {}
BaseEnemy.__index = BaseEnemy

function BaseEnemy.new(enemyType, x, y, difficultyMult)
    local self = setmetatable({}, BaseEnemy)
    local def = C.ENEMY[enemyType]
    difficultyMult = difficultyMult or C.DIFFICULTY.normal

    self.type = enemyType
    self.x = x or 0
    self.y = y or 0
    self.radius = def.radius
    self.speed = def.speed * difficultyMult.speedMult
    self.hp = def.hp * difficultyMult.hpMult
    self.maxHp = self.hp
    self.damage = def.damage * difficultyMult.damageMult
    self.score = def.score
    self.color = {def.color[1], def.color[2], def.color[3]}
    self.behavior = def.behavior
    self.alive = true
    self.angle = 0
    self.hitFlash = 0
    self.fireRate = def.fireRate or 0
    self.fireTimer = def.fireRate or 0
    self.preferredDist = def.preferredDist or 0

    -- Spawn fade-in system
    self.spawnFadeTimer = C.SPAWN_FADE_IN_DURATION
    self.spawnGraceTimer = C.SPAWN_GRACE_DURATION
    self.spawnFadeAlpha = 0

    return self
end

function BaseEnemy:update(dt, playerX, playerY, bullets)
    if not self.alive then return end

    self.angle = Utils.angle(self.x, self.y, playerX, playerY)

    if self.hitFlash > 0 then
        self.hitFlash = self.hitFlash - dt
    end

    -- Spawn fade-in
    if self.spawnFadeTimer > 0 then
        self.spawnFadeTimer = self.spawnFadeTimer - dt
        self.spawnFadeAlpha = 1 - (self.spawnFadeTimer / C.SPAWN_FADE_IN_DURATION)
    else
        self.spawnFadeAlpha = 1
    end

    -- Grace timer
    if self.spawnGraceTimer > 0 then
        self.spawnGraceTimer = self.spawnGraceTimer - dt
    end
end

function BaseEnemy:canDealContactDamage()
    return self.spawnGraceTimer <= 0
end

function BaseEnemy:takeDamage(amount)
    self.hp = self.hp - amount
    self.hitFlash = 0.08
    if self.hp <= 0 then
        self.alive = false
        return true
    end
    return false
end

function BaseEnemy:drawHPBar()
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
end

function BaseEnemy:setColor()
    if self.hitFlash > 0 then
        love.graphics.setColor(1, 1, 1, self.spawnFadeAlpha)
    else
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.spawnFadeAlpha)
    end
end

function BaseEnemy:draw()
    if not self.alive then return end
    self:setColor()
    love.graphics.circle("fill", self.x, self.y, self.radius)
    self:drawHPBar()
    love.graphics.setColor(1, 1, 1)
end

function BaseEnemy.getTypesForWave(wave)
    local types = {"chaser"}
    if wave >= 4 then table.insert(types, "shooter") end
    if wave >= 7 then table.insert(types, "tank") end
    if wave >= 10 then table.insert(types, "speeder") end
    return types
end

return BaseEnemy
