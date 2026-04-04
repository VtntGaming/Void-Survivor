local C = require("utils.Constants")

local UIRenderer = {}
UIRenderer.__index = UIRenderer

function UIRenderer.new()
    local self = setmetatable({}, UIRenderer)
    self.bigFont = love.graphics.newFont(32)
    self.medFont = love.graphics.newFont(20)
    self.smallFont = love.graphics.newFont(14)
    self.selectedDifficulty = 2  -- 1=easy, 2=normal, 3=hard
    return self
end

function UIRenderer:drawHUD(player, score, wave, highScore, comboMult, comboBreakDisplay)
    love.graphics.setFont(self.smallFont)

    -- HP Bar
    local barX, barY = 10, 10
    local barW, barH = 150, 16
    local ratio = player.hp / player.maxHp

    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", barX - 1, barY - 1, barW + 2, barH + 2)
    local r = 1 - ratio
    local g = ratio
    love.graphics.setColor(r, g, 0.1, 0.9)
    love.graphics.rectangle("fill", barX, barY, barW * ratio, barH)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("line", barX, barY, barW, barH)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("HP: " .. math.floor(player.hp) .. "/" .. player.maxHp, barX + 5, barY + 1)

    -- Score
    local font = self.smallFont
    local scoreText = "Score: " .. score
    local stw = font:getWidth(scoreText)
    love.graphics.setColor(1, 1, 0.5)
    love.graphics.print(scoreText, 790 - stw, 10)

    -- High Score
    local hsText = "Best: " .. highScore
    local hstw = font:getWidth(hsText)
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print(hsText, 790 - hstw, 28)

    -- Wave
    local waveText = "Wave " .. wave
    local wtw = font:getWidth(waveText)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(waveText, 400 - wtw / 2, 10)

    -- Combo multiplier
    if comboMult > 1 then
        love.graphics.setFont(self.medFont)
        local comboText = "x" .. comboMult
        local cw = self.medFont:getWidth(comboText)
        love.graphics.setColor(1, 0.8, 0.2, 0.9)
        love.graphics.print(comboText, 400 - cw / 2, 30)
        love.graphics.setFont(self.smallFont)
    end

    -- Combo break display
    if comboBreakDisplay and comboBreakDisplay > 0 then
        love.graphics.setFont(self.medFont)
        local breakText = "COMBO BREAK!"
        local bw = self.medFont:getWidth(breakText)
        local alpha = math.min(1, comboBreakDisplay)
        love.graphics.setColor(1, 0.2, 0.2, alpha)
        love.graphics.print(breakText, 400 - bw / 2, 55)
        love.graphics.setFont(self.smallFont)
    end

    -- Power-up indicators
    local indicatorY = 575
    local ix = 250
    if player.speedBoost then
        love.graphics.setColor(0.2, 0.5, 1, 0.8)
        love.graphics.rectangle("fill", ix, indicatorY, 60, 18, 3, 3)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("SPD " .. math.ceil(player.speedBoostTimer), ix + 5, indicatorY + 1)
        ix = ix + 65
    end
    if player.rapidFire then
        love.graphics.setColor(1, 1, 0.2, 0.8)
        love.graphics.rectangle("fill", ix, indicatorY, 60, 18, 3, 3)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("RPD " .. math.ceil(player.rapidFireTimer), ix + 5, indicatorY + 1)
        ix = ix + 65
    end
    if player.shield then
        love.graphics.setColor(0, 1, 1, 0.8)
        love.graphics.rectangle("fill", ix, indicatorY, 60, 18, 3, 3)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("SHIELD", ix + 3, indicatorY + 1)
        ix = ix + 65
    end
    if player.weaponType ~= "normal" then
        love.graphics.setColor(1, 0.5, 0, 0.8)
        love.graphics.rectangle("fill", ix, indicatorY, 75, 18, 3, 3)
        love.graphics.setColor(1, 1, 1)
        local wt = string.upper(player.weaponType) .. " " .. math.ceil(player.weaponTimer)
        love.graphics.print(wt, ix + 3, indicatorY + 1)
    end

    love.graphics.setColor(1, 1, 1)
end

function UIRenderer:drawTitle(highScore, difficulty)
    love.graphics.setColor(0.05, 0.05, 0.15)
    love.graphics.rectangle("fill", 0, 0, C.WINDOW_WIDTH, C.WINDOW_HEIGHT)

    -- Title
    love.graphics.setFont(self.bigFont)
    love.graphics.setColor(0.2, 0.8, 1)
    local title = "VOID SURVIVOR"
    local tw = self.bigFont:getWidth(title)
    love.graphics.print(title, 400 - tw / 2, 120)

    -- Subtitle
    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(0.6, 0.6, 0.8)
    local sub = "Top-Down Arena Survival Shooter"
    local sw = self.smallFont:getWidth(sub)
    love.graphics.print(sub, 400 - sw / 2, 165)

    -- Difficulty selector
    love.graphics.setFont(self.medFont)
    love.graphics.setColor(1, 1, 1, 0.7)
    local diffLabel = "Difficulty:"
    local dlw = self.medFont:getWidth(diffLabel)
    love.graphics.print(diffLabel, 400 - dlw / 2, 220)

    for i, diff in ipairs(C.DIFFICULTY_LIST) do
        local dx = 250 + (i - 1) * 120
        if diff == difficulty then
            love.graphics.setColor(0.2, 1, 0.5)
            love.graphics.rectangle("fill", dx - 5, 250, 100, 30, 4, 4)
            love.graphics.setColor(0, 0, 0)
        else
            love.graphics.setColor(0.3, 0.3, 0.4)
            love.graphics.rectangle("fill", dx - 5, 250, 100, 30, 4, 4)
            love.graphics.setColor(0.8, 0.8, 0.8)
        end
        local dt = string.upper(diff)
        local dtw = self.medFont:getWidth(dt)
        love.graphics.print(dt, dx + 50 - dtw / 2 - 5, 253)
    end

    -- Instructions
    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(0.6, 0.6, 0.8)
    love.graphics.print("Left/Right to change difficulty", 400 - self.smallFont:getWidth("Left/Right to change difficulty") / 2, 290)

    -- Start prompt
    love.graphics.setFont(self.medFont)
    love.graphics.setColor(1, 1, 1, 0.7 + math.sin(love.timer.getTime() * 3) * 0.3)
    local start = "Press ENTER to Start"
    local stw = self.medFont:getWidth(start)
    love.graphics.print(start, 400 - stw / 2, 340)

    -- Controls
    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(0.5, 0.5, 0.7)
    local controls = {
        "WASD / Arrows - Move",
        "Mouse - Aim",
        "Left Click - Shoot",
        "ESC - Pause"
    }
    for i, c in ipairs(controls) do
        local cw = self.smallFont:getWidth(c)
        love.graphics.print(c, 400 - cw / 2, 400 + (i - 1) * 20)
    end

    -- High Score
    if highScore > 0 then
        love.graphics.setColor(1, 1, 0.5)
        local hs = "High Score: " .. highScore
        local hsw = self.smallFont:getWidth(hs)
        love.graphics.print(hs, 400 - hsw / 2, 520)
    end

    love.graphics.setColor(1, 1, 1)
end

function UIRenderer:drawGameOver(score, wave, highScore, isNewHighScore, killCounts)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, C.WINDOW_WIDTH, C.WINDOW_HEIGHT)

    love.graphics.setFont(self.bigFont)
    love.graphics.setColor(1, 0.2, 0.2)
    local go = "GAME OVER"
    love.graphics.print(go, 400 - self.bigFont:getWidth(go) / 2, 100)

    love.graphics.setFont(self.medFont)
    love.graphics.setColor(1, 1, 1)
    local st = "Score: " .. score
    love.graphics.print(st, 400 - self.medFont:getWidth(st) / 2, 150)

    local wt = "Wave Reached: " .. wave
    love.graphics.print(wt, 400 - self.medFont:getWidth(wt) / 2, 180)

    if isNewHighScore then
        love.graphics.setColor(1, 1, 0.2)
        local nhs = "NEW HIGH SCORE!"
        love.graphics.print(nhs, 400 - self.medFont:getWidth(nhs) / 2, 215)
    end

    -- Kill breakdown
    if killCounts then
        love.graphics.setFont(self.smallFont)
        love.graphics.setColor(0.8, 0.8, 0.8)
        local totalKills = 0
        for _, v in pairs(killCounts) do totalKills = totalKills + v end
        local killTitle = "Kills: " .. totalKills
        love.graphics.print(killTitle, 400 - self.smallFont:getWidth(killTitle) / 2, 250)

        local killTypes = {
            {name = "Chaser", key = "chaser", color = {1, 0.2, 0.2}},
            {name = "Shooter", key = "shooter", color = {0.7, 0.2, 1}},
            {name = "Tank", key = "tank", color = {1, 0.6, 0.1}},
            {name = "Speeder", key = "speeder", color = {1, 1, 0.2}},
            {name = "Boss", key = "boss", color = {1, 0.3, 0.1}},
        }
        local ky = 270
        for _, kt in ipairs(killTypes) do
            local count = killCounts[kt.key] or 0
            if count > 0 then
                love.graphics.setColor(kt.color[1], kt.color[2], kt.color[3])
                local txt = kt.name .. ": " .. count
                love.graphics.print(txt, 400 - self.smallFont:getWidth(txt) / 2, ky)
                ky = ky + 18
            end
        end
        love.graphics.setFont(self.medFont)
    end

    love.graphics.setColor(0.7, 0.7, 0.7)
    local hs = "Best: " .. highScore
    love.graphics.print(hs, 400 - self.medFont:getWidth(hs) / 2, 340)

    love.graphics.setColor(1, 1, 1, 0.7 + math.sin(love.timer.getTime() * 3) * 0.3)
    local rt = "Press ENTER to Restart"
    love.graphics.print(rt, 400 - self.medFont:getWidth(rt) / 2, 390)

    love.graphics.setColor(1, 0.5, 0.5, 0.8)
    local qt = "Q - Quit to Menu"
    love.graphics.print(qt, 400 - self.medFont:getWidth(qt) / 2, 420)

    love.graphics.setColor(1, 1, 1)
end

function UIRenderer:drawPause()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, C.WINDOW_WIDTH, C.WINDOW_HEIGHT)

    love.graphics.setFont(self.bigFont)
    love.graphics.setColor(1, 1, 1)
    local pt = "PAUSED"
    love.graphics.print(pt, 400 - self.bigFont:getWidth(pt) / 2, 220)

    love.graphics.setFont(self.medFont)
    love.graphics.setColor(0.7, 0.7, 0.7)
    local rt = "ESC - Resume"
    love.graphics.print(rt, 400 - self.medFont:getWidth(rt) / 2, 280)

    love.graphics.setColor(0.5, 0.8, 1)
    local restart = "R - Restart"
    love.graphics.print(restart, 400 - self.medFont:getWidth(restart) / 2, 310)

    love.graphics.setColor(1, 0.5, 0.5)
    local quit = "Q - Quit to Menu"
    love.graphics.print(quit, 400 - self.medFont:getWidth(quit) / 2, 340)

    love.graphics.setColor(1, 1, 1)
end

function UIRenderer:drawWaveAnnouncement(waveNum, breakTimer, isBossWave)
    love.graphics.setFont(self.bigFont)
    love.graphics.setColor(1, 1, 1, 0.8)

    local text
    if isBossWave then
        love.graphics.setColor(1, 0.3, 0.1, 0.8 + math.sin(love.timer.getTime() * 5) * 0.2)
        text = "BOSS WAVE " .. waveNum
    else
        text = "Wave " .. waveNum
    end
    local tw = self.bigFont:getWidth(text)
    love.graphics.print(text, 400 - tw / 2, 240)

    love.graphics.setColor(1, 1, 1, 0.6)
    local countdown = tostring(math.ceil(breakTimer))
    local cw = self.bigFont:getWidth(countdown)
    love.graphics.print(countdown, 400 - cw / 2, 280)

    love.graphics.setColor(1, 1, 1)
end

return UIRenderer
