local Enemy = require("enemy")
local Utils = require("utils")

local Wave = {}
Wave.__index = Wave

function Wave.new()
    local self = setmetatable({}, Wave)
    self.current = 0
    self.enemies = {}
    self.spawnQueue = 0
    self.spawnTimer = 0
    self.spawnInterval = 0.5
    self.breakTime = 5
    self.breakTimer = 0
    self.inBreak = true
    self.active = false
    self.totalKilled = 0
    self.totalSpawned = 0
    self.waveEnemyCount = 0
    return self
end

function Wave:start()
    self.active = true
    self.inBreak = true
    self.breakTimer = 2 -- shorter first break
    self.current = 0
    self:nextWave()
end

function Wave:nextWave()
    self.current = self.current + 1
    self.inBreak = true
    self.breakTimer = self.current == 1 and 2 or self.breakTime
    self.waveEnemyCount = 5 + self.current * 2
    self.spawnQueue = self.waveEnemyCount
    self.totalSpawned = 0
    self.totalKilled = 0
end

function Wave:update(dt, playerX, playerY, bullets)
    if not self.active then return end

    -- Break between waves
    if self.inBreak then
        self.breakTimer = self.breakTimer - dt
        if self.breakTimer <= 0 then
            self.inBreak = false
        end
        return
    end

    -- Spawn enemies
    if self.spawnQueue > 0 then
        self.spawnTimer = self.spawnTimer - dt
        if self.spawnTimer <= 0 then
            self:spawnEnemy()
            self.spawnQueue = self.spawnQueue - 1
            self.totalSpawned = self.totalSpawned + 1
            -- Spawn faster in later waves
            self.spawnTimer = math.max(0.2, self.spawnInterval - self.current * 0.02)
        end
    end

    -- Update enemies
    for i = #self.enemies, 1, -1 do
        local e = self.enemies[i]
        e:update(dt, playerX, playerY, bullets)
        if not e.alive then
            table.remove(self.enemies, i)
        end
    end

    -- Check if wave complete
    if self.spawnQueue <= 0 and #self.enemies == 0 then
        self:nextWave()
    end
end

function Wave:spawnEnemy()
    local types = Enemy.getTypesForWave(self.current)
    local enemyType = types[math.random(#types)]
    local x, y = Utils.randomEdgePosition(30)
    local e = Enemy.new(enemyType, x, y)
    table.insert(self.enemies, e)
end

function Wave:getEnemies()
    return self.enemies
end

function Wave:onEnemyKilled()
    self.totalKilled = self.totalKilled + 1
end

function Wave:draw()
    -- Wave announcement
    if self.inBreak and self.active then
        love.graphics.setColor(1, 1, 1, 0.8)
        local font = love.graphics.getFont()
        local text = "Wave " .. self.current
        local tw = font:getWidth(text)
        love.graphics.print(text, 400 - tw / 2, 250)

        local countdown = math.ceil(self.breakTimer)
        local ct = tostring(countdown)
        local ctw = font:getWidth(ct)
        love.graphics.print(ct, 400 - ctw / 2, 280)
        love.graphics.setColor(1, 1, 1)
    end
end

return Wave
