local C = require("utils.Constants")
local Utils = require("utils.Utils")
local ChaserEnemy = require("entities.enemies.ChaserEnemy")
local ShooterEnemy = require("entities.enemies.ShooterEnemy")
local TankEnemy = require("entities.enemies.TankEnemy")
local SpeederEnemy = require("entities.enemies.SpeederEnemy")
local BossEnemy = require("entities.enemies.BossEnemy")
local BaseEnemy = require("entities.enemies.BaseEnemy")

local SpawnController = {}
SpawnController.__index = SpawnController

local ENEMY_CONSTRUCTORS = {
    chaser = ChaserEnemy.new,
    shooter = ShooterEnemy.new,
    tank = TankEnemy.new,
    speeder = SpeederEnemy.new,
}

function SpawnController.new(eventBus)
    local self = setmetatable({}, SpawnController)
    self.eventBus = eventBus
    self.difficultyMult = C.DIFFICULTY.normal
    return self
end

function SpawnController:setDifficulty(diffName)
    self.difficultyMult = C.DIFFICULTY[diffName] or C.DIFFICULTY.normal
end

function SpawnController:spawnEnemy(wave)
    local types = BaseEnemy.getTypesForWave(wave)
    local enemyType = types[math.random(#types)]
    local x, y = Utils.randomEdgePosition(30)
    local constructor = ENEMY_CONSTRUCTORS[enemyType]
    return constructor(x, y, self.difficultyMult)
end

function SpawnController:spawnBoss()
    local x, y = Utils.randomEdgePosition(50)
    local boss = BossEnemy.new(x, y, self.difficultyMult)
    self.eventBus:emit("boss:spawned", boss)
    return boss
end

function SpawnController:getEnemyCountForWave(wave)
    local count = C.WAVE_BASE_ENEMIES + wave * C.WAVE_ENEMIES_PER_WAVE
    return math.floor(count * self.difficultyMult.enemyMult)
end

return SpawnController
