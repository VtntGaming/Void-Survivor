local C = require("utils.Constants")
local Utils = require("utils.Utils")
local ChaserEnemy = require("entities.enemies.ChaserEnemy")
local ShooterEnemy = require("entities.enemies.ShooterEnemy")
local TankEnemy = require("entities.enemies.TankEnemy")
local SpeederEnemy = require("entities.enemies.SpeederEnemy")
local SplitterEnemy = require("entities.enemies.SplitterEnemy")
local BossEnemy = require("entities.enemies.BossEnemy")
local BaseEnemy = require("entities.enemies.BaseEnemy")

local SpawnController = {}
SpawnController.__index = SpawnController

local ENEMY_CONSTRUCTORS = {
    chaser = ChaserEnemy.new,
    shooter = ShooterEnemy.new,
    tank = TankEnemy.new,
    speeder = SpeederEnemy.new,
    splitter = SplitterEnemy.new,
}

function SpawnController.new(eventBus)
    local self = setmetatable({}, SpawnController)
    self.eventBus = eventBus
    self.difficultyMult = C.DIFFICULTY.normal
    self.playerX = C.PLAYER_START_X
    self.playerY = C.PLAYER_START_Y
    return self
end

function SpawnController:setDifficulty(diffName)
    self.difficultyMult = C.DIFFICULTY[diffName] or C.DIFFICULTY.normal
end

function SpawnController:setPlayerPos(x, y)
    self.playerX = x
    self.playerY = y
end

function SpawnController:safeEdgePosition(margin)
    local maxAttempts = 10
    for _ = 1, maxAttempts do
        local x, y = Utils.randomEdgePosition(margin)
        local dist = Utils.distance(x, y, self.playerX, self.playerY)
        if dist >= C.SPAWN_SAFE_RADIUS then
            return x, y
        end
    end
    return Utils.randomEdgePosition(margin)
end

function SpawnController:spawnEnemy(wave)
    local enemyType

    -- Elite splitter starts appearing in later waves at a controlled rate
    if wave >= 8 and math.random() < math.min(0.10 + wave * 0.005, 0.22) then
        enemyType = "splitter"
    else
        local types = BaseEnemy.getTypesForWave(wave)
        enemyType = types[math.random(#types)]
    end

    local x, y = self:safeEdgePosition(30)
    local constructor = ENEMY_CONSTRUCTORS[enemyType]
    return constructor(x, y, self.difficultyMult)
end

function SpawnController:spawnBoss()
    local x, y = self:safeEdgePosition(50)
    local boss = BossEnemy.new(x, y, self.difficultyMult)
    -- Boss skips fade-in for dramatic effect
    boss.spawnFadeTimer = 0
    boss.spawnFadeAlpha = 1
    boss.spawnGraceTimer = 0
    self.eventBus:emit("boss:spawned", boss)
    return boss
end

function SpawnController:getEnemyCountForWave(wave)
    local count = C.WAVE_BASE_ENEMIES + wave * C.WAVE_ENEMIES_PER_WAVE
    return math.floor(count * self.difficultyMult.enemyMult)
end

return SpawnController
