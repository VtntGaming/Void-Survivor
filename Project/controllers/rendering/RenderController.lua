local Particles = require("systems.Particles")

local RenderController = {}
RenderController.__index = RenderController

function RenderController.new(backgroundRenderer, uiRenderer)
    local self = setmetatable({}, RenderController)
    self.bg = backgroundRenderer
    self.ui = uiRenderer
    return self
end

function RenderController:update(dt)
    self.bg:update(dt)
end

function RenderController:drawGame(entities, waveCtrl, scoreCtrl, saveCtrl, screenShake)
    -- Screen shake
    local sx, sy = 0, 0
    if screenShake > 0 then
        sx = (math.random() - 0.5) * screenShake * 2
        sy = (math.random() - 0.5) * screenShake * 2
    end
    love.graphics.push()
    love.graphics.translate(sx, sy)

    -- Background
    self.bg:draw()

    -- Power-ups
    for _, pu in ipairs(entities.powerups) do
        pu:draw()
    end

    -- Enemies
    for _, e in ipairs(entities.enemies) do
        e:draw()
    end

    -- Player
    entities.player:draw()

    -- Bullets
    for _, b in ipairs(entities.bullets) do
        b:draw()
    end

    -- Particles
    Particles.draw()

    -- Wave announcement
    if waveCtrl.inBreak and waveCtrl.active then
        self.ui:drawWaveAnnouncement(waveCtrl.current, waveCtrl:getBreakTimer(), waveCtrl.isBossWave)
    end

    -- HUD
    self.ui:drawHUD(
        entities.player,
        scoreCtrl:getScore(),
        waveCtrl.current,
        saveCtrl:getHighScore(),
        scoreCtrl:getComboMultiplier(),
        scoreCtrl.comboBreakDisplay
    )

    love.graphics.pop()

    -- FPS
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.setFont(self.ui.smallFont)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 5, 580)
    love.graphics.setColor(1, 1, 1)
end

function RenderController:drawTitle(highScore, difficulty)
    self.ui:drawTitle(highScore, difficulty)
end

function RenderController:drawPause()
    self.ui:drawPause()
end

function RenderController:drawGameOver(score, wave, highScore, isNewHighScore)
    self.ui:drawGameOver(score, wave, highScore, isNewHighScore)
end

return RenderController
