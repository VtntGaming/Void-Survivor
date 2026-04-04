local Particles = require("systems.Particles")
local Player = require("entities.Player")
local C = require("utils.Constants")

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
