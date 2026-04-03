local Utils = require("utils.Utils")
local C = require("utils.Constants")
local Particles = require("systems.Particles")

local CollisionController = {}
CollisionController.__index = CollisionController

function CollisionController.new(eventBus)
    local self = setmetatable({}, CollisionController)
    self.eventBus = eventBus
    self.screenShake = 0
    return self
end

function CollisionController:update(dt, player, enemies, bullets, powerups)
    self:playerBulletsVsEnemies(player, enemies, bullets, powerups)
    self:enemyBulletsVsPlayer(player, bullets)
    self:enemyContactVsPlayer(player, enemies)
    self:playerVsPowerUps(player, powerups)

    if self.screenShake > 0 then
        self.screenShake = self.screenShake - dt * 8
        if self.screenShake < 0 then self.screenShake = 0 end
    end
end

function CollisionController:playerBulletsVsEnemies(player, enemies, bullets, powerups)
    local PowerUp = require("entities.PowerUp")
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if b.isPlayerBullet and b.alive then
            for j = #enemies, 1, -1 do
                local e = enemies[j]
                if e.alive and Utils.checkCircleCollision(b.x, b.y, b.radius, e.x, e.y, e.radius) then
                    b:onHit()
                    local killed = e:takeDamage(b.damage)
                    Particles.spawn(b.x, b.y, e.color, 4, 80, 0.3)

                    -- AOE for heavy bullets
                    if b.bulletType == "heavy" and b.aoeRadius then
                        for _, other in ipairs(enemies) do
                            if other ~= e and other.alive then
                                if Utils.checkCircleCollision(b.x, b.y, b.aoeRadius, other.x, other.y, other.radius) then
                                    local aoeKilled = other:takeDamage(b.damage * 0.5)
                                    if aoeKilled then
                                        self.eventBus:emit("enemy:killed", other)
                                        Particles.spawn(other.x, other.y, other.color, 8, 120, 0.5)
                                        local pu = PowerUp.randomDrop(other.x, other.y)
                                        if pu then table.insert(powerups, pu) end
                                    end
                                end
                            end
                        end
                        Particles.spawn(b.x, b.y, {1, 0.6, 0.1}, 10, 120, 0.4)
                    end

                    if killed then
                        self.eventBus:emit("enemy:killed", e)
                        Particles.spawn(e.x, e.y, e.color, 12, 150, 0.6)
                        self.screenShake = math.max(self.screenShake, e.type == "boss" and 6 or 2)

                        -- Boss drops guaranteed power-ups
                        if e.type == "boss" then
                            for k = 1, C.POWERUP_BOSS_DROP_COUNT do
                                local pu = PowerUp.new(
                                    e.x + (math.random() - 0.5) * 30,
                                    e.y + (math.random() - 0.5) * 30
                                )
                                table.insert(powerups, pu)
                            end
                            self.eventBus:emit("boss:killed", e)
                        else
                            local pu = PowerUp.randomDrop(e.x, e.y)
                            if pu then table.insert(powerups, pu) end
                        end
                    end
                    break
                end
            end
        end
    end
end

function CollisionController:enemyBulletsVsPlayer(player, bullets)
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if not b.isPlayerBullet and b.alive then
            if Utils.checkCircleCollision(b.x, b.y, b.radius, player.x, player.y, player.radius) then
                b.alive = false
                local damaged = player:takeDamage(b.damage)
                if damaged then
                    self.eventBus:emit("player:damaged", b.damage, player.hp)
                end
                Particles.spawn(b.x, b.y, {1, 0.3, 0.3}, 6, 100, 0.4)
                self.screenShake = math.max(self.screenShake, 3)
            end
        end
    end
end

function CollisionController:enemyContactVsPlayer(player, enemies)
    for _, e in ipairs(enemies) do
        if e.alive and Utils.checkCircleCollision(player.x, player.y, player.radius, e.x, e.y, e.radius) then
            local damaged = player:takeDamage(e.damage)
            if damaged then
                self.eventBus:emit("player:damaged", e.damage, player.hp)
            end
            self.screenShake = math.max(self.screenShake, 4)
            Particles.spawn(player.x, player.y, {1, 0.5, 0.2}, 8, 120, 0.4)
            local angle = Utils.angle(player.x, player.y, e.x, e.y)
            e.x = e.x + math.cos(angle) * 30
            e.y = e.y + math.sin(angle) * 30
        end
    end
end

function CollisionController:playerVsPowerUps(player, powerups)
    for i = #powerups, 1, -1 do
        local pu = powerups[i]
        if pu.alive and Utils.checkCircleCollision(player.x, player.y, player.radius, pu.x, pu.y, pu.radius + 5) then
            player:applyPowerUp(pu.type)
            self.eventBus:emit("player:powerup", pu.type)
            Particles.spawn(pu.x, pu.y, pu.color, 10, 80, 0.5)
            pu.alive = false
            table.remove(powerups, i)
        end
    end
end

function CollisionController:getScreenShake()
    return self.screenShake
end

return CollisionController
