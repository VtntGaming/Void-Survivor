local C = require("utils.Constants")
local EventBus = require("systems.EventBus")
local Particles = require("systems.Particles")

local StateController = require("controllers.StateController")
local InputController = require("controllers.input.InputController")
local AudioController = require("controllers.audio.AudioController")
local SaveController = require("controllers.data.SaveController")
local EntityController = require("controllers.gameplay.EntityController")
local SpawnController = require("controllers.gameplay.SpawnController")
local WaveController = require("controllers.gameplay.WaveController")
local CollisionController = require("controllers.gameplay.CollisionController")
local ScoreController = require("controllers.gameplay.ScoreController")
local BackgroundRenderer = require("controllers.rendering.BackgroundRenderer")
local UIRenderer = require("controllers.rendering.UIRenderer")
local RenderController = require("controllers.rendering.RenderController")

local STATES = StateController.STATES

local GameController = {}
GameController.__index = GameController

function GameController.new(appVersion)
    local self = setmetatable({}, GameController)
    self.appVersion = appVersion or "dev"

    -- Event bus
    self.eventBus = EventBus.new()

    -- Controllers
    self.state = StateController.new(self.eventBus)
    self.input = InputController.new()
    self.save = SaveController.new()
    self.audio = AudioController.new(self.eventBus)
    self.entity = EntityController.new(self.eventBus)
    self.spawn = SpawnController.new(self.eventBus)
    self.wave = WaveController.new(self.eventBus, self.spawn)
    self.collision = CollisionController.new(self.eventBus)
    self.score = ScoreController.new(self.eventBus)

    -- Rendering
    self.bgRenderer = BackgroundRenderer.new()
    self.uiRenderer = UIRenderer.new()
    self.render = RenderController.new(self.bgRenderer, self.uiRenderer)

    -- Game state
    self.isNewHighScore = false
    self.difficulty = self.save:getDifficulty()
    self.selectedDiffIdx = self:diffNameToIndex(self.difficulty)

    -- Screen flash
    self.screenFlash = 0
    self.screenFlashColor = {1, 1, 1}

    -- Settings return state
    self.settingsReturnState = STATES.MENU

    -- Kill tracker
    self.killCounts = {chaser = 0, shooter = 0, tank = 0, speeder = 0, boss = 0}

    -- Apply saved volume
    self.audio:setVolume(self.save:getSfxVolume())

    -- Tutorial system
    self.tutorialActive = false
    self.tutorialStep = 0
    self.tutorialTimer = 0
    self.tutorialSteps = {
        {duration = 4, text = "WASD / Arrow Keys to Move", icon = "move"},
        {duration = 4, text = "Mouse to Aim, Click to Shoot", icon = "aim"},
        {duration = 4, text = "Grab Power-ups dropped by enemies!", icon = "pickup"},
    }

    -- Register event handlers
    self:registerEvents()

    return self
end

function GameController:registerEvents()
    self.eventBus:on("enemy:killed", function(enemy)
        self.score:onEnemyKilled(enemy)
        -- Track kill counts
        if self.killCounts[enemy.type] then
            self.killCounts[enemy.type] = self.killCounts[enemy.type] + 1
        end
    end)

    self.eventBus:on("boss:killed", function(boss)
        self.wave:onBossKilled()
        self:triggerFlash({1, 0.2, 0.1}, 0.2)
    end)

    self.eventBus:on("boss:phase_change", function()
        self:triggerFlash({1, 1, 1}, C.SCREEN_FLASH_DURATION)
    end)

    self.eventBus:on("wave:complete", function(waveNum)
        self.score:addWaveBonus(waveNum)
    end)

    self.eventBus:on("player:damaged", function(amount, newHp)
        -- handled by audio via eventbus
    end)
end

function GameController:startGame()
    self.difficulty = C.DIFFICULTY_LIST[self.selectedDiffIdx]
    self.save:setDifficulty(self.difficulty)
    self.spawn:setDifficulty(self.difficulty)

    self.entity:reset()
    self.score:reset()
    self.wave:reset()
    self.wave:start()
    self.isNewHighScore = false
    self.killCounts = {chaser = 0, shooter = 0, tank = 0, speeder = 0, boss = 0}
    self.screenFlash = 0
    Particles.clear()

    self.state:change(STATES.PLAYING)
    self.render:startZoomIntro()

    -- Apply auto-fire setting
    self.input.autoFire = self.save:getAutoFire()

    -- Start tutorial on first run
    if self.save:isFirstRun() then
        self.tutorialActive = true
        self.tutorialStep = 1
        self.tutorialTimer = self.tutorialSteps[1].duration
        self.save:setFirstRunDone()
    end
end

function GameController:update(dt)
    dt = math.min(dt, 1/30)

    local currentState = self.state:get()

    if currentState == STATES.PLAYING then
        -- Input
        self.input:update(dt)
        self.input:applyToPlayer(self.entity.player)

        -- Entity updates
        local p = self.entity.player
        self.entity:update(dt, p.x, p.y)

        -- Feed player position to spawn controller for safe radius
        self.spawn:setPlayerPos(p.x, p.y)

        -- Wave update
        self.wave:update(dt, self.entity.enemies)

        -- Collision
        self.collision:update(dt, p, self.entity.enemies, self.entity.bullets, self.entity.powerups)

        -- Score combo timer
        self.score:update(dt)

        -- Tutorial update
        if self.tutorialActive then
            self.tutorialTimer = self.tutorialTimer - dt
            if self.tutorialTimer <= 0 then
                self.tutorialStep = self.tutorialStep + 1
                if self.tutorialStep > #self.tutorialSteps then
                    self.tutorialActive = false
                else
                    self.tutorialTimer = self.tutorialSteps[self.tutorialStep].duration
                end
            end
        end

        -- Rendering updates
        self.render:update(dt)

        -- Screen flash decay
        if self.screenFlash > 0 then
            self.screenFlash = self.screenFlash - dt
        end

        -- Check game over
        if not p.alive then
            self.state:change(STATES.GAMEOVER)
            self.isNewHighScore = self.save:setHighScore(self.score:getScore())
            self.eventBus:emit("game:over")
        end

        -- Clear consumed keys at end of frame
        self.input:clearKeys()

    elseif currentState == STATES.MENU then
        -- nothing in update
    end
end

function GameController:draw()
    local currentState = self.state:get()

    if currentState == STATES.MENU then
        self.render:drawTitle(
            self.save:getHighScore(),
            C.DIFFICULTY_LIST[self.selectedDiffIdx],
            self.appVersion
        )

    elseif currentState == STATES.SETTINGS then
        self.render:drawSettings(
            self.save:getSfxVolume(),
            self.save:getScreenShake(),
            self.save:getAutoFire(),
            self.save:getMusicVolume()
        )

    elseif currentState == STATES.PLAYING or currentState == STATES.PAUSED or currentState == STATES.GAMEOVER then
        self.render:drawGame(
            self.entity,
            self.wave,
            self.score,
            self.save,
            self.collision:getScreenShake()
        )

        -- Screen flash overlay
        if self.screenFlash > 0 then
            local alpha = self.screenFlash / C.SCREEN_FLASH_DURATION
            love.graphics.setColor(self.screenFlashColor[1], self.screenFlashColor[2], self.screenFlashColor[3], alpha * 0.4)
            love.graphics.rectangle("fill", 0, 0, C.WINDOW_WIDTH, C.WINDOW_HEIGHT)
            love.graphics.setColor(1, 1, 1)
        end

        if currentState == STATES.PAUSED then
            self.render:drawPause()
        elseif currentState == STATES.GAMEOVER then
            self.render:drawGameOver(
                self.score:getScore(),
                self.wave.current,
                self.save:getHighScore(),
                self.isNewHighScore,
                self.killCounts
            )
        end

        -- Tutorial overlay
        if self.tutorialActive and currentState == STATES.PLAYING then
            local step = self.tutorialSteps[self.tutorialStep]
            if step then
                self.render:drawTutorial(step, self.tutorialTimer, step.duration)
            end
        end
    end
end

function GameController:keypressed(key)
    self.input:keypressed(key)
    local currentState = self.state:get()

    if key == "return" or key == "kpenter" then
        if currentState == STATES.MENU or currentState == STATES.GAMEOVER then
            self:startGame()
        end
    elseif key == "escape" then
        if currentState == STATES.PLAYING then
            self.state:change(STATES.PAUSED)
        elseif currentState == STATES.PAUSED then
            self.state:change(STATES.PLAYING)
        elseif currentState == STATES.SETTINGS then
            self.state:change(self.settingsReturnState)
        elseif currentState == STATES.MENU then
            love.event.quit()
        end
    elseif key == "r" then
        if currentState == STATES.PAUSED then
            self:startGame()
        end
    elseif key == "q" then
        if currentState == STATES.PAUSED or currentState == STATES.GAMEOVER then
            self:goToMenu()
        end
    elseif key == "left" or key == "a" then
        if currentState == STATES.MENU then
            self.selectedDiffIdx = math.max(1, self.selectedDiffIdx - 1)
        elseif currentState == STATES.SETTINGS then
            self:adjustVolume(-0.1)
        end
    elseif key == "right" or key == "d" then
        if currentState == STATES.MENU then
            self.selectedDiffIdx = math.min(#C.DIFFICULTY_LIST, self.selectedDiffIdx + 1)
        elseif currentState == STATES.SETTINGS then
            self:adjustVolume(0.1)
        end
    elseif key == "up" or key == "down" then
        if currentState == STATES.SETTINGS then
            self:cycleScreenShake(key == "up" and -1 or 1)
        end
    elseif key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
end

function GameController:triggerFlash(color, duration)
    self.screenFlash = duration or C.SCREEN_FLASH_DURATION
    self.screenFlashColor = color or {1, 1, 1}
end

function GameController:mousepressed(x, y, button)
    if button ~= 1 then return end
    local currentState = self.state:get()
    local clicked = self.uiRenderer:getClickedButton(x, y)
    if not clicked then return end

    if currentState == STATES.MENU then
        if clicked == "start" then
            self:startGame()
        elseif clicked == "settings" then
            self:openSettings(STATES.MENU)
        elseif clicked:sub(1, 5) == "diff_" then
            local idx = tonumber(clicked:sub(6))
            if idx and idx >= 1 and idx <= #C.DIFFICULTY_LIST then
                self.selectedDiffIdx = idx
            end
        end
    elseif currentState == STATES.PAUSED then
        if clicked == "resume" then
            self.state:change(STATES.PLAYING)
        elseif clicked == "restart" then
            self:startGame()
        elseif clicked == "quit" then
            self:goToMenu()
        elseif clicked == "settings" then
            self:openSettings(STATES.PAUSED)
        end
    elseif currentState == STATES.GAMEOVER then
        if clicked == "restart" then
            self:startGame()
        elseif clicked == "quit" then
            self:goToMenu()
        end
    elseif currentState == STATES.SETTINGS then
        if clicked == "back" then
            self.state:change(self.settingsReturnState)
        elseif clicked == "vol_down" then
            self:adjustVolume(-0.1)
        elseif clicked == "vol_up" then
            self:adjustVolume(0.1)
        elseif clicked == "music_down" then
            self:adjustMusicVolume(-0.1)
        elseif clicked == "music_up" then
            self:adjustMusicVolume(0.1)
        elseif clicked:sub(1, 6) == "shake_" then
            local val = clicked:sub(7)
            self.save:setScreenShake(val)
        elseif clicked == "autofire_true" then
            self.save:setAutoFire(true)
        elseif clicked == "autofire_false" then
            self.save:setAutoFire(false)
        end
    end
end

function GameController:openSettings(returnState)
    self.settingsReturnState = returnState
    self.state:change(STATES.SETTINGS)
end

function GameController:cycleScreenShake(dir)
    local options = C.SCREEN_SHAKE_OPTIONS
    local current = self.save:getScreenShake()
    local idx = 1
    for i, opt in ipairs(options) do
        if opt == current then idx = i break end
    end
    idx = idx + dir
    if idx < 1 then idx = #options end
    if idx > #options then idx = 1 end
    self.save:setScreenShake(options[idx])
end

function GameController:adjustVolume(delta)
    local vol = self.save:getSfxVolume()
    vol = math.max(0, math.min(1, vol + delta))
    vol = math.floor(vol * 10 + 0.5) / 10  -- round to 0.1
    self.save:setSfxVolume(vol)
    self.audio:setVolume(vol)
end

function GameController:adjustMusicVolume(delta)
    local vol = self.save:getMusicVolume()
    vol = math.max(0, math.min(1, vol + delta))
    vol = math.floor(vol * 10 + 0.5) / 10
    self.save:setMusicVolume(vol)
end

function GameController:diffNameToIndex(name)
    for i, d in ipairs(C.DIFFICULTY_LIST) do
        if d == name then return i end
    end
    return 2 -- normal
end

function GameController:goToMenu()
    self.entity:reset()
    self.score:reset()
    self.wave:reset()
    Particles.clear()
    self.state:change(STATES.MENU)
end

return GameController
