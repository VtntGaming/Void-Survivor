local C = require("utils.Constants")

local UIRenderer = {}
UIRenderer.__index = UIRenderer

function UIRenderer.new()
    local self = setmetatable({}, UIRenderer)
    self.bigFont = love.graphics.newFont(32)
    self.medFont = love.graphics.newFont(20)
    self.smallFont = love.graphics.newFont(14)
    self.selectedDifficulty = 2  -- 1=easy, 2=normal, 3=hard

    -- Clickable button regions: {id, x, y, w, h}
    self.buttons = {}
    return self
end

function UIRenderer:clearButtons()
    self.buttons = {}
end

function UIRenderer:addButton(id, x, y, w, h)
    table.insert(self.buttons, {id = id, x = x, y = y, w = w, h = h})
end

function UIRenderer:isHovered(bx, by, bw, bh)
    local mx, my = love.mouse.getPosition()
    return mx >= bx and mx <= bx + bw and my >= by and my <= by + bh
end

function UIRenderer:getClickedButton(mx, my)
    for _, btn in ipairs(self.buttons) do
        if mx >= btn.x and mx <= btn.x + btn.w and my >= btn.y and my <= btn.y + btn.h then
            return btn.id
        end
    end
    return nil
end

function UIRenderer:drawHUD(player, score, wave, highScore, comboMult, comboBreakDisplay)
    love.graphics.setFont(self.smallFont)

    -- HP Bar
    local barX, barY = 10, 10
    local barW, barH = 150, 16
    local ratio = player.hp / player.maxHp
    local chipRatio = (player.displayHp or player.hp) / player.maxHp

    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", barX - 1, barY - 1, barW + 2, barH + 2)

    -- Red chip damage trailing bar
    if chipRatio > ratio then
        love.graphics.setColor(0.8, 0.1, 0.1, 0.9)
        love.graphics.rectangle("fill", barX, barY, barW * chipRatio, barH)
    end

    -- Actual HP bar
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

    -- Power-up indicators (improved readability)
    local indicatorY = 568
    local indicatorH = 24
    local ix = 200
    local puSlots = {}

    if player.speedBoost then
        table.insert(puSlots, {
            label = "SPD",
            timer = player.speedBoostTimer,
            maxTime = C.SPEED_BOOST_DURATION,
            bgColor = {0.1, 0.3, 0.7, 0.9},
            barColor = {0.3, 0.6, 1, 0.9},
            textColor = {1, 1, 1}
        })
    end
    if player.rapidFire then
        table.insert(puSlots, {
            label = "RAPID",
            timer = player.rapidFireTimer,
            maxTime = C.RAPID_FIRE_DURATION,
            bgColor = {0.6, 0.5, 0.0, 0.9},
            barColor = {1, 0.9, 0.2, 0.9},
            textColor = {0, 0, 0}
        })
    end
    if player.shield then
        table.insert(puSlots, {
            label = "SHIELD",
            timer = -1,  -- no timer
            maxTime = 1,
            bgColor = {0.0, 0.5, 0.5, 0.9},
            barColor = {0, 1, 1, 0.9},
            textColor = {0, 0, 0}
        })
    end
    if player.weaponType ~= "normal" then
        table.insert(puSlots, {
            label = string.upper(player.weaponType),
            timer = player.weaponTimer,
            maxTime = C.WEAPON_POWERUP_DURATION,
            bgColor = {0.5, 0.2, 0.0, 0.9},
            barColor = {1, 0.5, 0.0, 0.9},
            textColor = {1, 1, 1}
        })
    end

    -- Center the power-up bar cluster
    local slotW = 90
    local slotGap = 5
    local totalPuW = #puSlots * slotW + math.max(0, #puSlots - 1) * slotGap
    ix = (C.WINDOW_WIDTH - totalPuW) / 2

    for _, slot in ipairs(puSlots) do
        -- Background
        love.graphics.setColor(0.1, 0.1, 0.15, 0.8)
        love.graphics.rectangle("fill", ix, indicatorY, slotW, indicatorH, 4, 4)

        -- Timer bar fill
        if slot.timer >= 0 then
            local ratio = math.max(0, slot.timer / slot.maxTime)
            love.graphics.setColor(slot.barColor)
            love.graphics.rectangle("fill", ix, indicatorY, slotW * ratio, indicatorH, 4, 4)

            -- Flash when low
            if slot.timer < 2 then
                local flash = math.sin(love.timer.getTime() * 8) * 0.3 + 0.7
                love.graphics.setColor(1, 0.2, 0.2, (1 - slot.timer / 2) * flash * 0.3)
                love.graphics.rectangle("fill", ix, indicatorY, slotW, indicatorH, 4, 4)
            end
        else
            love.graphics.setColor(slot.barColor)
            love.graphics.rectangle("fill", ix, indicatorY, slotW, indicatorH, 4, 4)
        end

        -- Border
        love.graphics.setColor(slot.bgColor)
        love.graphics.rectangle("line", ix, indicatorY, slotW, indicatorH, 4, 4)

        -- Label and timer text
        love.graphics.setColor(slot.textColor)
        local timerStr = slot.timer >= 0 and (" " .. math.ceil(slot.timer) .. "s") or ""
        local labelText = slot.label .. timerStr
        local tw = self.smallFont:getWidth(labelText)
        love.graphics.print(labelText, ix + (slotW - tw) / 2, indicatorY + 4)

        ix = ix + slotW + slotGap
    end

    love.graphics.setColor(1, 1, 1)
end

function UIRenderer:drawTitle(highScore, difficulty, version)
    self:clearButtons()
    love.graphics.setColor(0.05, 0.05, 0.15)
    love.graphics.rectangle("fill", 0, 0, C.WINDOW_WIDTH, C.WINDOW_HEIGHT)

    -- Title
    love.graphics.setFont(self.bigFont)
    love.graphics.setColor(0.2, 0.8, 1)
    local title = "VOID SURVIVOR"
    local tw = self.bigFont:getWidth(title)
    love.graphics.print(title, 400 - tw / 2, 120)

    -- Subtitle + version
    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(0.6, 0.6, 0.8)
    local sub = "Top-Down Arena Survival Shooter"
    local sw = self.smallFont:getWidth(sub)
    love.graphics.print(sub, 400 - sw / 2, 165)

    version = version or "dev"
    local versionText = "Version v" .. version
    love.graphics.setColor(1, 0.85, 0.35)
    love.graphics.print(versionText, 400 - self.smallFont:getWidth(versionText) / 2, 184)

    -- Difficulty selector
    love.graphics.setFont(self.medFont)
    love.graphics.setColor(1, 1, 1, 0.7)
    local diffLabel = "Difficulty:"
    local dlw = self.medFont:getWidth(diffLabel)
    love.graphics.print(diffLabel, 400 - dlw / 2, 220)

    for i, diff in ipairs(C.DIFFICULTY_LIST) do
        local dx = 250 + (i - 1) * 120
        local bx, by, bw, bh = dx - 5, 250, 100, 30
        local hovered = self:isHovered(bx, by, bw, bh)
        self:addButton("diff_" .. i, bx, by, bw, bh)

        if diff == difficulty then
            love.graphics.setColor(0.2, 1, 0.5)
            love.graphics.rectangle("fill", bx, by, bw, bh, 4, 4)
            love.graphics.setColor(0, 0, 0)
        elseif hovered then
            love.graphics.setColor(0.5, 0.5, 0.6)
            love.graphics.rectangle("fill", bx, by, bw, bh, 4, 4)
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0.3, 0.3, 0.4)
            love.graphics.rectangle("fill", bx, by, bw, bh, 4, 4)
            love.graphics.setColor(0.8, 0.8, 0.8)
        end
        local dt = string.upper(diff)
        local dtw = self.medFont:getWidth(dt)
        love.graphics.print(dt, dx + 50 - dtw / 2 - 5, 253)
    end

    -- Instructions
    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(0.6, 0.6, 0.8)
    love.graphics.print("Left/Right or click to change difficulty", 400 - self.smallFont:getWidth("Left/Right or click to change difficulty") / 2, 290)

    -- Start button (clickable)
    love.graphics.setFont(self.medFont)
    local start = "Press ENTER to Start"
    local stw = self.medFont:getWidth(start)
    local startX, startY, startW, startH = 400 - stw / 2 - 10, 332, stw + 20, 35
    local startHover = self:isHovered(startX, startY, startW, startH)
    self:addButton("start", startX, startY, startW, startH)

    if startHover then
        love.graphics.setColor(0.3, 0.3, 0.5, 0.5)
        love.graphics.rectangle("fill", startX, startY, startW, startH, 4, 4)
    end
    love.graphics.setColor(1, 1, 1, 0.7 + math.sin(love.timer.getTime() * 3) * 0.3)
    love.graphics.print(start, 400 - stw / 2, 340)

    -- Settings button
    love.graphics.setFont(self.smallFont)
    local settingsText = "Settings"
    local settW = self.smallFont:getWidth(settingsText)
    local sbx, sby, sbw, sbh = 400 - settW / 2 - 10, 372, settW + 20, 22
    local settHover = self:isHovered(sbx, sby, sbw, sbh)
    self:addButton("settings", sbx, sby, sbw, sbh)
    if settHover then
        love.graphics.setColor(0.4, 0.4, 0.6, 0.5)
        love.graphics.rectangle("fill", sbx, sby, sbw, sbh, 3, 3)
    end
    love.graphics.setColor(0.7, 0.7, 0.9)
    love.graphics.print(settingsText, 400 - settW / 2, 375)

    -- Tips panel
    love.graphics.setFont(self.smallFont)
    local panelX, panelY, panelW, panelH = 80, 405, 640, 150
    love.graphics.setColor(0.08, 0.08, 0.2, 0.6)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 6, 6)
    love.graphics.setColor(0.3, 0.3, 0.5, 0.5)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 6, 6)

    local leftCol = {
        {color = {0.4, 0.7, 1}, text = "Controls"},
        {color = {0.6, 0.6, 0.8}, text = "WASD / Arrows - Move"},
        {color = {0.6, 0.6, 0.8}, text = "Mouse - Aim & Shoot"},
        {color = {0.6, 0.6, 0.8}, text = "ESC - Pause  |  F11 - Fullscreen"},
    }
    local rightCol = {
        {color = {1, 0.8, 0.3}, text = "Tips"},
        {color = {0.6, 0.6, 0.8}, text = "Kill fast for combo multiplier!"},
        {color = {0.6, 0.6, 0.8}, text = "Grab power-ups for weapons & heals"},
        {color = {0.6, 0.6, 0.8}, text = "Every 5th wave spawns a boss"},
    }

    local lx = panelX + 20
    local rx = panelX + panelW / 2 + 20
    for i, entry in ipairs(leftCol) do
        love.graphics.setColor(entry.color)
        love.graphics.print(entry.text, lx, panelY + 10 + (i - 1) * 18)
    end
    for i, entry in ipairs(rightCol) do
        love.graphics.setColor(entry.color)
        love.graphics.print(entry.text, rx, panelY + 10 + (i - 1) * 18)
    end

    -- High Score
    if highScore > 0 then
        love.graphics.setColor(1, 1, 0.5)
        local hs = "High Score: " .. highScore
        local hsw = self.smallFont:getWidth(hs)
        love.graphics.print(hs, 400 - hsw / 2, panelY + panelH + 10)
    end

    love.graphics.setColor(1, 1, 1)
end

function UIRenderer:drawGameOver(score, wave, highScore, isNewHighScore, killCounts)
    self:clearButtons()
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

    -- Restart button (clickable)
    local rt = "Press ENTER to Restart"
    local rtw = self.medFont:getWidth(rt)
    local rbx, rby, rbw, rbh = 400 - rtw / 2 - 10, 382, rtw + 20, 35
    local restartHover = self:isHovered(rbx, rby, rbw, rbh)
    self:addButton("restart", rbx, rby, rbw, rbh)
    if restartHover then
        love.graphics.setColor(0.4, 0.4, 0.5, 0.5)
        love.graphics.rectangle("fill", rbx, rby, rbw, rbh, 4, 4)
    end
    love.graphics.setColor(1, 1, 1, 0.7 + math.sin(love.timer.getTime() * 3) * 0.3)
    love.graphics.print(rt, 400 - rtw / 2, 390)

    -- Quit button (clickable)
    local qt = "Q - Quit to Menu"
    local qtw = self.medFont:getWidth(qt)
    local qx, qy, qw, qh = 400 - qtw / 2 - 10, 418, qtw + 20, 30
    local quitHover = self:isHovered(qx, qy, qw, qh)
    self:addButton("quit", qx, qy, qw, qh)
    if quitHover then
        love.graphics.setColor(0.6, 0.3, 0.3, 0.5)
        love.graphics.rectangle("fill", qx, qy, qw, qh, 4, 4)
    end
    love.graphics.setColor(1, 0.5, 0.5, 0.8)
    love.graphics.print(qt, 400 - qtw / 2, 420)

    love.graphics.setColor(1, 1, 1)
end

function UIRenderer:drawPause()
    self:clearButtons()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, C.WINDOW_WIDTH, C.WINDOW_HEIGHT)

    love.graphics.setFont(self.bigFont)
    love.graphics.setColor(1, 1, 1)
    local pt = "PAUSED"
    love.graphics.print(pt, 400 - self.bigFont:getWidth(pt) / 2, 220)

    love.graphics.setFont(self.medFont)

    -- Resume button
    local rt = "ESC - Resume"
    local rtw = self.medFont:getWidth(rt)
    local rbx, rby, rbw, rbh = 400 - rtw / 2 - 10, 273, rtw + 20, 30
    local resumeHover = self:isHovered(rbx, rby, rbw, rbh)
    self:addButton("resume", rbx, rby, rbw, rbh)
    if resumeHover then
        love.graphics.setColor(0.4, 0.4, 0.5, 0.5)
        love.graphics.rectangle("fill", rbx, rby, rbw, rbh, 4, 4)
    end
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print(rt, 400 - rtw / 2, 280)

    -- Restart button
    local restart = "R - Restart"
    local rstw = self.medFont:getWidth(restart)
    local rsx, rsy, rsw, rsh = 400 - rstw / 2 - 10, 303, rstw + 20, 30
    local restartHover = self:isHovered(rsx, rsy, rsw, rsh)
    self:addButton("restart", rsx, rsy, rsw, rsh)
    if restartHover then
        love.graphics.setColor(0.3, 0.5, 0.6, 0.5)
        love.graphics.rectangle("fill", rsx, rsy, rsw, rsh, 4, 4)
    end
    love.graphics.setColor(0.5, 0.8, 1)
    love.graphics.print(restart, 400 - rstw / 2, 310)

    -- Quit button
    local quit = "Q - Quit to Menu"
    local qtw = self.medFont:getWidth(quit)
    local qx, qy, qw, qh = 400 - qtw / 2 - 10, 333, qtw + 20, 30
    local quitHover = self:isHovered(qx, qy, qw, qh)
    self:addButton("quit", qx, qy, qw, qh)
    if quitHover then
        love.graphics.setColor(0.6, 0.3, 0.3, 0.5)
        love.graphics.rectangle("fill", qx, qy, qw, qh, 4, 4)
    end
    love.graphics.setColor(1, 0.5, 0.5)
    love.graphics.print(quit, 400 - qtw / 2, 340)

    -- Settings button
    love.graphics.setFont(self.smallFont)
    local settText = "Settings"
    local stw = self.smallFont:getWidth(settText)
    local sx, sy, sw, sh = 400 - stw / 2 - 10, 370, stw + 20, 22
    local settHover = self:isHovered(sx, sy, sw, sh)
    self:addButton("settings", sx, sy, sw, sh)
    if settHover then
        love.graphics.setColor(0.4, 0.4, 0.6, 0.5)
        love.graphics.rectangle("fill", sx, sy, sw, sh, 3, 3)
    end
    love.graphics.setColor(0.7, 0.7, 0.9)
    love.graphics.print(settText, 400 - stw / 2, 373)

    love.graphics.setColor(1, 1, 1)
end

function UIRenderer:drawWaveAnnouncement(waveNum, breakTimer, isBossWave)
    love.graphics.setFont(self.bigFont)
    love.graphics.setColor(1, 1, 1, 0.8)

    local text
    if isBossWave then
        -- Flashing WARNING text above
        love.graphics.setColor(1, 0.1, 0, 0.7 + math.sin(love.timer.getTime() * 8) * 0.3)
        local warn = "!! WARNING !!"
        local ww = self.bigFont:getWidth(warn)
        love.graphics.print(warn, 400 - ww / 2, 200)

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

function UIRenderer:drawSettings(sfxVolume, screenShake, autoFire, musicVolume)
    self:clearButtons()
    love.graphics.setColor(0.05, 0.05, 0.15)
    love.graphics.rectangle("fill", 0, 0, C.WINDOW_WIDTH, C.WINDOW_HEIGHT)

    -- Title
    love.graphics.setFont(self.bigFont)
    love.graphics.setColor(0.2, 0.8, 1)
    local title = "SETTINGS"
    local tw = self.bigFont:getWidth(title)
    love.graphics.print(title, 400 - tw / 2, 60)

    -- SFX Volume
    love.graphics.setFont(self.medFont)
    love.graphics.setColor(1, 1, 1)
    local volLabel = "SFX Volume"
    local vlw = self.medFont:getWidth(volLabel)
    love.graphics.print(volLabel, 400 - vlw / 2, 120)

    self:drawVolumeSlider("vol", sfxVolume, 155)

    -- Music Volume
    love.graphics.setFont(self.medFont)
    love.graphics.setColor(1, 1, 1)
    musicVolume = musicVolume or 0.5
    local musLabel = "Music Volume"
    local mlw = self.medFont:getWidth(musLabel)
    love.graphics.print(musLabel, 400 - mlw / 2, 210)

    self:drawVolumeSlider("music", musicVolume, 245)

    -- Instructions
    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(0.6, 0.6, 0.8)
    local hint = "Click [-]/[+] or use Left/Right to adjust"
    love.graphics.print(hint, 400 - self.smallFont:getWidth(hint) / 2, 290)

    -- Screen Shake setting
    love.graphics.setFont(self.medFont)
    love.graphics.setColor(1, 1, 1)
    local shakeLabel = "Screen Shake"
    local slw = self.medFont:getWidth(shakeLabel)
    love.graphics.print(shakeLabel, 400 - slw / 2, 320)

    screenShake = screenShake or "full"
    local options = C.SCREEN_SHAKE_OPTIONS
    for i, opt in ipairs(options) do
        local ox = 250 + (i - 1) * 120
        local bx, by, bw, bh = ox - 5, 350, 100, 30
        local hovered = self:isHovered(bx, by, bw, bh)
        self:addButton("shake_" .. opt, bx, by, bw, bh)

        if opt == screenShake then
            love.graphics.setColor(0.2, 1, 0.5)
            love.graphics.rectangle("fill", bx, by, bw, bh, 4, 4)
            love.graphics.setColor(0, 0, 0)
        elseif hovered then
            love.graphics.setColor(0.5, 0.5, 0.6)
            love.graphics.rectangle("fill", bx, by, bw, bh, 4, 4)
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0.3, 0.3, 0.4)
            love.graphics.rectangle("fill", bx, by, bw, bh, 4, 4)
            love.graphics.setColor(0.8, 0.8, 0.8)
        end
        local ot = string.upper(opt)
        local otw = self.medFont:getWidth(ot)
        love.graphics.print(ot, ox + 50 - otw / 2 - 5, 353)
    end

    -- Auto-fire toggle
    love.graphics.setFont(self.medFont)
    love.graphics.setColor(1, 1, 1)
    local afLabel = "Auto-Fire"
    local afw = self.medFont:getWidth(afLabel)
    love.graphics.print(afLabel, 400 - afw / 2, 400)

    autoFire = autoFire or false
    local afOptions = {{"ON", true}, {"OFF", false}}
    for i, opt in ipairs(afOptions) do
        local ox = 310 + (i - 1) * 120
        local bx, by, bw, bh = ox - 5, 430, 100, 30
        local hovered = self:isHovered(bx, by, bw, bh)
        self:addButton("autofire_" .. tostring(opt[2]), bx, by, bw, bh)

        if autoFire == opt[2] then
            love.graphics.setColor(0.2, 1, 0.5)
            love.graphics.rectangle("fill", bx, by, bw, bh, 4, 4)
            love.graphics.setColor(0, 0, 0)
        elseif hovered then
            love.graphics.setColor(0.5, 0.5, 0.6)
            love.graphics.rectangle("fill", bx, by, bw, bh, 4, 4)
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0.3, 0.3, 0.4)
            love.graphics.rectangle("fill", bx, by, bw, bh, 4, 4)
            love.graphics.setColor(0.8, 0.8, 0.8)
        end
        local otw = self.medFont:getWidth(opt[1])
        love.graphics.print(opt[1], ox + 50 - otw / 2 - 5, 433)
    end

    -- Back button
    love.graphics.setFont(self.medFont)
    local backText = "ESC - Back"
    local btw = self.medFont:getWidth(backText)
    local bbx, bby, bbw, bbh = 400 - btw / 2 - 10, 490, btw + 20, 35
    local backHover = self:isHovered(bbx, bby, bbw, bbh)
    self:addButton("back", bbx, bby, bbw, bbh)
    if backHover then
        love.graphics.setColor(0.4, 0.4, 0.5, 0.5)
        love.graphics.rectangle("fill", bbx, bby, bbw, bbh, 4, 4)
    end
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print(backText, 400 - btw / 2, 495)

    love.graphics.setColor(1, 1, 1)
end

function UIRenderer:drawVolumeSlider(prefix, volume, sliderY)
    love.graphics.setFont(self.medFont)
    local sliderX = 200
    local sliderW, sliderH = 400, 25
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", sliderX, sliderY, sliderW, sliderH, 4, 4)
    love.graphics.setColor(0.2, 0.7, 1, 0.8)
    love.graphics.rectangle("fill", sliderX, sliderY, sliderW * volume, sliderH, 4, 4)
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.rectangle("line", sliderX, sliderY, sliderW, sliderH, 4, 4)

    -- Volume text
    love.graphics.setColor(1, 1, 1)
    local volText = math.floor(volume * 100) .. "%"
    local vtw = self.medFont:getWidth(volText)
    love.graphics.print(volText, 400 - vtw / 2, sliderY + 2)

    -- Buttons
    local downText = "[-]"
    local upText = "[+]"
    local dnw = self.medFont:getWidth(downText)
    local upw = self.medFont:getWidth(upText)

    local dbx, dby, dbw, dbh = sliderX - dnw - 20, sliderY, dnw + 10, sliderH
    local downHover = self:isHovered(dbx, dby, dbw, dbh)
    self:addButton(prefix .. "_down", dbx, dby, dbw, dbh)
    if downHover then
        love.graphics.setColor(0.5, 0.3, 0.3, 0.5)
        love.graphics.rectangle("fill", dbx, dby, dbw, dbh, 4, 4)
    end
    love.graphics.setColor(1, 0.5, 0.5)
    love.graphics.print(downText, dbx + 5, dby + 1)

    local ubx, uby, ubw, ubh = sliderX + sliderW + 10, sliderY, upw + 10, sliderH
    local upHover = self:isHovered(ubx, uby, ubw, ubh)
    self:addButton(prefix .. "_up", ubx, uby, ubw, ubh)
    if upHover then
        love.graphics.setColor(0.3, 0.5, 0.3, 0.5)
        love.graphics.rectangle("fill", ubx, uby, ubw, ubh, 4, 4)
    end
    love.graphics.setColor(0.5, 1, 0.5)
    love.graphics.print(upText, ubx + 5, uby + 1)
end

function UIRenderer:drawTutorial(step, timer, totalDuration)
    if not step then return end

    -- Fade in/out
    local alpha = 1
    if timer > totalDuration - 0.5 then
        alpha = (totalDuration - timer) / 0.5  -- fade in
    elseif timer < 0.5 then
        alpha = timer / 0.5  -- fade out
    end
    alpha = math.max(0, math.min(1, alpha))

    -- Background panel
    local panelW, panelH = 400, 50
    local panelX = (C.WINDOW_WIDTH - panelW) / 2
    local panelY = C.WINDOW_HEIGHT - 100

    love.graphics.setColor(0.05, 0.05, 0.2, 0.75 * alpha)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8)
    love.graphics.setColor(0.3, 0.6, 1, 0.6 * alpha)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8)

    -- Icon indicator
    love.graphics.setColor(0.3, 0.8, 1, alpha)
    love.graphics.setFont(self.smallFont)
    local arrow = ">>  "
    local arrowW = self.smallFont:getWidth(arrow)

    -- Tutorial text
    love.graphics.setFont(self.medFont)
    love.graphics.setColor(1, 1, 1, alpha)
    local textW = self.medFont:getWidth(step.text)
    local totalW = arrowW + textW
    local tx = (C.WINDOW_WIDTH - totalW) / 2
    local ty = panelY + (panelH - self.medFont:getHeight()) / 2

    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(0.3, 0.8, 1, alpha)
    love.graphics.print(arrow, tx, ty + 3)

    love.graphics.setFont(self.medFont)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.print(step.text, tx + arrowW, ty)

    love.graphics.setColor(1, 1, 1)
end

return UIRenderer
