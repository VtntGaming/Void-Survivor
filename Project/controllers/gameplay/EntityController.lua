local Particles = require("systems.Particles")
local Player = require("entities.Player")
local C = require("utils.Constants")
local Utils = require("utils.Utils")

local EntityController = {}
EntityController.__index = EntityController

function EntityController.new(eventBus)
    local self = setmetatable({}, EntityController)
    self.eventBus = eventBus
    self.player = nil
    self.enemies = {}
    self.bullets = {}
    self.powerups = {}
    return self
end

function EntityController:reset()
    self.player = Player.new()
    self.enemies = {}
    self.bullets = {}
    self.powerups = {}
    Particles.clear()
end

function EntityController:update(dt, playerX, playerY)
    -- Update player
    self.player:update(dt, self.bullets)

    -- Update enemies
    for i = #self.enemies, 1, -1 do
        local e = self.enemies[i]
        e:update(dt, playerX, playerY, self.bullets)
        if not e.alive then
            table.remove(self.enemies, i)
        end
    end

    -- Update bullets
    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b:update(dt)
        if not b.alive then
            table.remove(self.bullets, i)
        end
    end
    -- Enforce bullet limit
    while #self.bullets > C.MAX_BULLETS do
        table.remove(self.bullets, 1)
    end

    -- Update power-ups
    for i = #self.powerups, 1, -1 do
        local pu = self.powerups[i]

        if self.player and self.player.magnet and pu.alive then
            local dist = Utils.distance(self.player.x, self.player.y, pu.x, pu.y)
            if dist <= self.player.magnetRange then
                local dx, dy = Utils.normalize(self.player.x - pu.x, self.player.y - pu.y)
                local pullStrength = self.player.magnetPullSpeed * (0.35 + 0.65 * (1 - dist / self.player.magnetRange))
                pu.x = pu.x + dx * pullStrength * dt
                pu.y = pu.y + dy * pullStrength * dt
            end
        end

        pu:update(dt)
        if not pu.alive then
            table.remove(self.powerups, i)
        end
    end
    -- Enforce powerup limit
    while #self.powerups > C.MAX_POWERUPS do
        table.remove(self.powerups, 1)
    end

    -- Update particles
    Particles.update(dt)
end

return EntityController
