local C = require("utils.Constants")

local WaveController = {}
WaveController.__index = WaveController

function WaveController.new(eventBus, spawnController)
    local self = setmetatable({}, WaveController)
    self.eventBus = eventBus
    self.spawnController = spawnController
    self.current = 0
    self.spawnQueue = 0
    self.spawnTimer = 0
    self.breakTimer = 0
    self.inBreak = true
    self.active = false
    self.isBossWave = false
    self.bossAlive = false
    return self
end

function WaveController:start()
    self.active = true
    self.current = 0
    self:nextWave()
end

function WaveController:reset()
    self.current = 0
    self.spawnQueue = 0
    self.spawnTimer = 0
    self.breakTimer = 0
    self.inBreak = true
    self.active = false
    self.isBossWave = false
    self.bossAlive = false
end

function WaveController:nextWave()
    self.current = self.current + 1
    self.inBreak = true
    self.breakTimer = self.current == 1 and C.WAVE_FIRST_BREAK or C.WAVE_BREAK_TIME

    self.isBossWave = (self.current % C.BOSS_WAVE_INTERVAL == 0)
    self.bossAlive = false

    if self.isBossWave then
        self.spawnQueue = 0  -- boss wave: only boss
    else
        self.spawnQueue = self.spawnController:getEnemyCountForWave(self.current)
    end

    self.eventBus:emit("wave:start", self.current, self.isBossWave)
end

function WaveController:update(dt, enemies)
    if not self.active then return end

    if self.inBreak then
        self.breakTimer = self.breakTimer - dt
        if self.breakTimer <= 0 then
            self.inBreak = false
            -- Spawn boss immediately if boss wave
            if self.isBossWave and not self.bossAlive then
                local boss = self.spawnController:spawnBoss()
                table.insert(enemies, boss)
                self.bossAlive = true
            end
        end
        return
    end

    -- Spawn regular enemies
    if self.spawnQueue > 0 then
        self.spawnTimer = self.spawnTimer - dt
        if self.spawnTimer <= 0 then
            local e = self.spawnController:spawnEnemy(self.current)
            table.insert(enemies, e)
            self.spawnQueue = self.spawnQueue - 1
            self.spawnTimer = math.max(0.2, C.WAVE_SPAWN_INTERVAL - self.current * 0.02)
        end
    end

    -- Check wave complete
    if self.spawnQueue <= 0 and #enemies == 0 then
        self.eventBus:emit("wave:complete", self.current)
        self:nextWave()
    end
end

function WaveController:onBossKilled()
    self.bossAlive = false
end

function WaveController:getBreakTimer()
    return self.breakTimer
end

return WaveController
