local UI = {}

function UI.drawHUD(player, score, wave, highScore)
    -- HP Bar
    local barX, barY = 10, 10
    local barW, barH = 150, 16
    local ratio = player.hp / player.maxHp

    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", barX - 1, barY - 1, barW + 2, barH + 2)

    -- HP color gradient (green to red)
    local r = 1 - ratio
    local g = ratio
    love.graphics.setColor(r, g, 0.1, 0.9)
    love.graphics.rectangle("fill", barX, barY, barW * ratio, barH)

    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("line", barX, barY, barW, barH)

    local font = love.graphics.getFont()
    local hpText = "HP: " .. player.hp .. "/" .. player.maxHp
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(hpText, barX + 5, barY + 1)

    -- Score
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

    -- Power-up indicators
    local indicatorY = 575
    local ix = 300
    if player.speedBoost then
        love.graphics.setColor(0.2, 0.5, 1, 0.8)
        love.graphics.rectangle("fill", ix, indicatorY, 60, 18, 3, 3)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("SPD " .. math.ceil(player.speedBoostTimer), ix + 5, indicatorY + 1)
        ix = ix + 70
    end
    if player.rapidFire then
        love.graphics.setColor(1, 1, 0.2, 0.8)
        love.graphics.rectangle("fill", ix, indicatorY, 60, 18, 3, 3)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("RPD " .. math.ceil(player.rapidFireTimer), ix + 5, indicatorY + 1)
        ix = ix + 70
    end
    if player.shield then
        love.graphics.setColor(0, 1, 1, 0.8)
        love.graphics.rectangle("fill", ix, indicatorY, 60, 18, 3, 3)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("SHIELD", ix + 3, indicatorY + 1)
    end

    love.graphics.setColor(1, 1, 1)
end

function UI.drawTitle(highScore)
    -- Background
    love.graphics.setColor(0.05, 0.05, 0.15)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Title
    love.graphics.setColor(0.2, 0.8, 1)
    local title = "VOID SURVIVOR"
    local font = love.graphics.getFont()
    local tw = font:getWidth(title)
    love.graphics.print(title, 400 - tw / 2, 180)

    -- Subtitle
    love.graphics.setColor(0.6, 0.6, 0.8)
    local sub = "Top-Down Arena Survival Shooter"
    local sw = font:getWidth(sub)
    love.graphics.print(sub, 400 - sw / 2, 220)

    -- Instructions
    love.graphics.setColor(1, 1, 1, 0.7 + math.sin(love.timer.getTime() * 3) * 0.3)
    local start = "Press ENTER to Start"
    local stw = font:getWidth(start)
    love.graphics.print(start, 400 - stw / 2, 320)

    -- Controls
    love.graphics.setColor(0.5, 0.5, 0.7)
    local controls = {
        "WASD / Arrows - Move",
        "Mouse - Aim",
        "Left Click - Shoot",
        "ESC - Pause"
    }
    for i, c in ipairs(controls) do
        local cw = font:getWidth(c)
        love.graphics.print(c, 400 - cw / 2, 380 + (i - 1) * 22)
    end

    -- High Score
    if highScore > 0 then
        love.graphics.setColor(1, 1, 0.5)
        local hs = "High Score: " .. highScore
        local hsw = font:getWidth(hs)
        love.graphics.print(hs, 400 - hsw / 2, 500)
    end

    love.graphics.setColor(1, 1, 1)
end

function UI.drawGameOver(score, wave, highScore, isNewHighScore)
    -- Dim overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    local font = love.graphics.getFont()

    -- Game Over text
    love.graphics.setColor(1, 0.2, 0.2)
    local go = "GAME OVER"
    local gow = font:getWidth(go)
    love.graphics.print(go, 400 - gow / 2, 180)

    -- Score
    love.graphics.setColor(1, 1, 1)
    local st = "Score: " .. score
    local stw = font:getWidth(st)
    love.graphics.print(st, 400 - stw / 2, 240)

    -- Wave reached
    local wt = "Wave Reached: " .. wave
    local wtw = font:getWidth(wt)
    love.graphics.print(wt, 400 - wtw / 2, 268)

    -- New High Score
    if isNewHighScore then
        love.graphics.setColor(1, 1, 0.2)
        local nhs = "NEW HIGH SCORE!"
        local nhsw = font:getWidth(nhs)
        love.graphics.print(nhs, 400 - nhsw / 2, 310)
    end

    -- Best
    love.graphics.setColor(0.7, 0.7, 0.7)
    local hs = "Best: " .. highScore
    local hsw = font:getWidth(hs)
    love.graphics.print(hs, 400 - hsw / 2, 340)

    -- Restart
    love.graphics.setColor(1, 1, 1, 0.7 + math.sin(love.timer.getTime() * 3) * 0.3)
    local rt = "Press ENTER to Restart"
    local rtw = font:getWidth(rt)
    love.graphics.print(rt, 400 - rtw / 2, 400)

    love.graphics.setColor(1, 1, 1)
end

function UI.drawPause()
    -- Dim overlay
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    local font = love.graphics.getFont()

    love.graphics.setColor(1, 1, 1)
    local pt = "PAUSED"
    local pw = font:getWidth(pt)
    love.graphics.print(pt, 400 - pw / 2, 260)

    love.graphics.setColor(0.7, 0.7, 0.7)
    local rt = "Press ESC to Resume"
    local rw = font:getWidth(rt)
    love.graphics.print(rt, 400 - rw / 2, 300)

    love.graphics.setColor(1, 1, 1)
end

return UI
