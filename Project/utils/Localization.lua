local Localization = {}
Localization.__index = Localization

local currentLang = "en"

local strings = {
    en = {
        -- Title screen
        title = "VOID SURVIVOR",
        subtitle = "Top-Down Arena Survival Shooter",
        difficulty = "Difficulty:",
        easy = "EASY",
        normal = "NORMAL",
        hard = "HARD",
        start = "Press ENTER to Start",
        settings = "Settings",
        high_score = "High Score: %d",
        diff_hint = "Left/Right or click to change difficulty",

        -- Controls / tips
        controls = "Controls",
        ctrl_move = "WASD / Arrows - Move",
        ctrl_aim = "Mouse - Aim & Shoot",
        ctrl_pause = "ESC - Pause  |  F11 - Fullscreen",
        tips = "Tips",
        tip_combo = "Kill fast for combo multiplier!",
        tip_powerup = "Grab power-ups for weapons & heals",
        tip_boss = "Every 5th wave spawns a boss",

        -- HUD
        hp_label = "HP: %d/%d",
        score_label = "Score: %d",
        best_label = "Best: %d",
        wave_label = "Wave %d",
        combo_break = "COMBO BREAK!",

        -- Pause
        paused = "PAUSED",
        resume = "ESC - Resume",
        restart_key = "R - Restart",
        quit_menu = "Q - Quit to Menu",

        -- Game over
        game_over = "GAME OVER",
        score = "Score: %d",
        wave_reached = "Wave Reached: %d",
        new_high_score = "NEW HIGH SCORE!",
        kills = "Kills: %d",
        restart = "Press ENTER to Restart",

        -- Settings
        settings_title = "SETTINGS",
        sfx_volume = "SFX Volume",
        music_volume = "Music Volume",
        screen_shake = "Screen Shake",
        auto_fire = "Auto-Fire",
        on = "ON",
        off = "OFF",
        low = "LOW",
        full = "FULL",
        back = "ESC - Back",
        vol_hint = "Click [-]/[+] or use Left/Right to adjust",

        -- Tutorial
        tut_move = "WASD / Arrow Keys to Move",
        tut_aim = "Mouse to Aim, Click to Shoot",
        tut_pickup = "Grab Power-ups dropped by enemies!",

        -- Wave announcement
        warning = "!! WARNING !!",
        boss_wave = "BOSS WAVE %d",

        -- Enemy names
        chaser = "Chaser",
        shooter = "Shooter",
        tank = "Tank",
        speeder = "Speeder",
        splitter = "Splitter",
        boss = "Boss",
    },

    vn = {
        -- Title screen
        title = "VOID SURVIVOR",
        subtitle = "Game Sinh Tồn Bắn Súng Từ Trên Xuống",
        difficulty = "Độ Khó:",
        easy = "DỄ",
        normal = "THƯỜNG",
        hard = "KHÓ",
        start = "Nhấn ENTER để Bắt Đầu",
        settings = "Cài Đặt",
        high_score = "Điểm Cao: %d",
        diff_hint = "Trái/Phải hoặc nhấp để đổi độ khó",

        -- Controls / tips
        controls = "Điều Khiển",
        ctrl_move = "WASD / Mũi Tên - Di Chuyển",
        ctrl_aim = "Chuột - Ngắm & Bắn",
        ctrl_pause = "ESC - Tạm Dừng  |  F11 - Toàn Màn Hình",
        tips = "Mẹo",
        tip_combo = "Tiêu diệt nhanh để nhân điểm combo!",
        tip_powerup = "Nhặt vật phẩm để có vũ khí & hồi máu",
        tip_boss = "Mỗi 5 đợt sẽ xuất hiện Boss",

        -- HUD
        hp_label = "HP: %d/%d",
        score_label = "Điểm: %d",
        best_label = "Cao Nhất: %d",
        wave_label = "Đợt %d",
        combo_break = "MẤT COMBO!",

        -- Pause
        paused = "TẠM DỪNG",
        resume = "ESC - Tiếp Tục",
        restart_key = "R - Chơi Lại",
        quit_menu = "Q - Về Menu",

        -- Game over
        game_over = "THUA CUỘC",
        score = "Điểm: %d",
        wave_reached = "Đợt Đạt Được: %d",
        new_high_score = "ĐIỂM CAO MỚI!",
        kills = "Tiêu Diệt: %d",
        restart = "Nhấn ENTER để Chơi Lại",

        -- Settings
        settings_title = "CÀI ĐẶT",
        sfx_volume = "Âm Lượng SFX",
        music_volume = "Âm Lượng Nhạc",
        screen_shake = "Rung Màn Hình",
        auto_fire = "Tự Động Bắn",
        on = "BẬT",
        off = "TẮT",
        low = "THẤP",
        full = "ĐẦY ĐỦ",
        back = "ESC - Quay Lại",
        vol_hint = "Nhấp [-]/[+] hoặc Trái/Phải để chỉnh",

        -- Tutorial
        tut_move = "WASD / Mũi Tên để Di Chuyển",
        tut_aim = "Chuột để Ngắm, Nhấp để Bắn",
        tut_pickup = "Nhặt Vật Phẩm từ kẻ địch!",

        -- Wave announcement
        warning = "!! CẢNH BÁO !!",
        boss_wave = "ĐỢT BOSS %d",

        -- Enemy names
        chaser = "Truy Đuổi",
        shooter = "Xạ Thủ",
        tank = "Xe Tăng",
        speeder = "Tốc Độ",
        splitter = "Phân Tách",
        boss = "Boss",
    }
}

function Localization.setLanguage(lang)
    if strings[lang] then
        currentLang = lang
    end
end

function Localization.getLanguage()
    return currentLang
end

function Localization.get(key, ...)
    local str = strings[currentLang] and strings[currentLang][key]
    if not str then
        str = strings.en[key] or ("?" .. key .. "?")
    end
    if select("#", ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

function Localization.getLanguages()
    return {"en", "vn"}
end

return Localization
