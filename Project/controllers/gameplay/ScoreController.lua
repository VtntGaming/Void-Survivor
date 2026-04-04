local C = require("utils.Constants")

local ScoreController = {}
ScoreController.__index = ScoreController

function ScoreController.new(eventBus)
    local self = setmetatable({}, ScoreController)
    self.eventBus = eventBus
    self.score = 0
    self.combo = 0          -- current kill streak
    self.comboTier = 1      -- index into COMBO_TIERS
    self.comboMultiplier = C.COMBO_TIERS[1]
    self.comboTimer = 0
    self.comboBreakDisplay = 0
    self.lastComboMultiplier = 1
    return self
end

function ScoreController:reset()
    self.score = 0
    self.combo = 0
    self.comboTier = 1
    self.comboMultiplier = C.COMBO_TIERS[1]
    self.comboTimer = 0
    self.comboBreakDisplay = 0
end

function ScoreController:update(dt)
    if self.comboTimer > 0 then
        self.comboTimer = self.comboTimer - dt
        if self.comboTimer <= 0 and self.combo > 0 then
            -- Combo break
            self.lastComboMultiplier = self.comboMultiplier
            self.comboBreakDisplay = C.COMBO_BREAK_DISPLAY
            self.eventBus:emit("combo:break")
            self.combo = 0
            self.comboTier = 1
            self.comboMultiplier = C.COMBO_TIERS[1]
        end
    end

    if self.comboBreakDisplay > 0 then
        self.comboBreakDisplay = self.comboBreakDisplay - dt
    end
end

function ScoreController:onEnemyKilled(enemy)
    local baseScore = enemy.score
    self.combo = self.combo + 1
    self.comboTimer = C.COMBO_WINDOW

    -- Tier up: every 3 kills increases tier
    local newTier = math.min(math.floor(self.combo / 3) + 1, #C.COMBO_TIERS)
    if newTier ~= self.comboTier then
        self.comboTier = newTier
        self.comboMultiplier = C.COMBO_TIERS[self.comboTier]
        self.eventBus:emit("combo:update", self.comboMultiplier)
    end

    local points = baseScore * self.comboMultiplier
    self.score = self.score + points
    self.eventBus:emit("score:update", self.score, self.comboMultiplier)
    return points
end

function ScoreController:addWaveBonus(wave)
    local bonus = wave * 50
    self.score = self.score + bonus
    self.eventBus:emit("score:update", self.score, self.comboMultiplier)
    return bonus
end

function ScoreController:getScore()
    return self.score
end

function ScoreController:getComboMultiplier()
    return self.comboMultiplier
end

return ScoreController
