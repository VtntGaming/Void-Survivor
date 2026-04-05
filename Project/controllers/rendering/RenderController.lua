local Particles = require("systems.Particles")
local C = require("utils.Constants")

local RenderController = {}
RenderController.__index = RenderController

function RenderController.new(backgroundRenderer, uiRenderer)
    local self = setmetatable({}, RenderController)
    self.bg = backgroundRenderer
    self.ui = uiRenderer
    self.zoomTimer = 0
    self.zoomDuration = 0.8
    self.zoomFrom = 1.6  -- start zoomed in
    self.zoomTo = 1.0
    return self
end

function RenderController:startZoomIntro()
    self.zoomTimer = self.zoomDuration
end

function RenderController:update(dt)
    self.bg:update(dt)
    if self.zoomTimer > 0 then
        self.zoomTimer = math.max(0, self.zoomTimer - dt)
    end
end

function RenderController:getZoomScale()
    if self.zoomTimer <= 0 then return 1.0 end
    local t = self.zoomTimer / self.zoomDuration
    -- Ease-out: smooth deceleration
    t = t * t
    return self.zoomTo + (self.zoomFrom - self.zoomTo) * t
end

function RenderController:drawGame(entities, waveCtrl, scoreCtrl, saveCtrl, screenShake)
    -- Apply screen shake multiplier from settings
    local shakeSetting = saveCtrl:getScreenShake()
    local shakeMult = C.SCREEN_SHAKE_MULT[shakeSetting] or 1.0
    screenShake = screenShake * shakeMult

    -- Screen shake
    local sx, sy = 0, 0
    if screenShake > 0 then
        local maxOff = C.SCREEN_SHAKE_MAX_OFFSET
        sx = math.max(-maxOff, math.min(maxOff, (math.random() - 0.5) * screenShake * 2))
        sy = math.max(-maxOff, math.min(maxOff, (math.random() - 0.5) * screenShake * 2))
    end
    love.graphics.push()
    love.graphics.translate(sx, sy)

    -- Zoom intro
    local zoomScale = self:getZoomScale()
    if zoomScale ~= 1.0 then
        love.graphics.translate(C.WINDOW_WIDTH / 2, C.WINDOW_HEIGHT / 2)
        love.graphics.scale(zoomScale, zoomScale)
        love.graphics.translate(-C.WINDOW_WIDTH / 2, -C.WINDOW_HEIGHT / 2)
    end

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

function RenderController:drawTitle(highScore, difficulty, version)
    self.ui:drawTitle(highScore, difficulty, version)
end

function RenderController:drawPause()
    self.ui:drawPause()
end

function RenderController:drawGameOver(score, wave, highScore, isNewHighScore, killCounts)
    self.ui:drawGameOver(score, wave, highScore, isNewHighScore, killCounts)
end

function RenderController:drawSettings(sfxVolume, screenShake, autoFire, musicVolume, language)
    self.ui:drawSettings(sfxVolume, screenShake, autoFire, musicVolume, language)
end

function RenderController:drawTutorial(step, timer, totalDuration)
    self.ui:drawTutorial(step, timer, totalDuration)
end

return RenderController
