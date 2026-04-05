local Constants = {}

-- Window
Constants.WINDOW_WIDTH = 800
Constants.WINDOW_HEIGHT = 600

-- Player
Constants.PLAYER_START_X = 400
Constants.PLAYER_START_Y = 300
Constants.PLAYER_RADIUS = 12
Constants.PLAYER_SPEED = 200
Constants.PLAYER_HP = 100
Constants.PLAYER_FIRE_RATE = 0.15
Constants.PLAYER_BULLET_SPEED = 500
Constants.PLAYER_BULLET_DAMAGE = 25
Constants.PLAYER_INVINCIBLE_DURATION = 0.5

-- Bullet
Constants.PLAYER_BULLET_RADIUS = 3
Constants.ENEMY_BULLET_RADIUS = 4
Constants.ENEMY_BULLET_DAMAGE = 15
Constants.ENEMY_BULLET_SPEED = 250

-- Heavy bullet (weapon power-up)
Constants.HEAVY_BULLET_RADIUS = 6
Constants.HEAVY_BULLET_SPEED = 300
Constants.HEAVY_BULLET_DAMAGE = 50
Constants.HEAVY_AOE_RADIUS = 40

-- Spread weapon
Constants.SPREAD_COUNT = 3
Constants.SPREAD_ANGLE = math.rad(15)

-- Weapon power-up duration
Constants.WEAPON_POWERUP_DURATION = 10

-- Enemy types
Constants.ENEMY = {
    chaser = {
        color = {1, 0.2, 0.2},
        radius = 10, speed = 110, hp = 40,
        damage = 12, score = 10, behavior = "chase"
    },
    shooter = {
        color = {0.7, 0.2, 1},
        radius = 11, speed = 65, hp = 35,
        damage = 10, score = 20, behavior = "shoot",
        fireRate = 1.8, preferredDist = 200
    },
    tank = {
        color = {1, 0.6, 0.1},
        radius = 18, speed = 45, hp = 120,
        damage = 20, score = 30, behavior = "chase"
    },
    speeder = {
        color = {1, 1, 0.2},
        radius = 8, speed = 200, hp = 20,
        damage = 8, score = 15, behavior = "chase"
    },
    splitter = {
        color = {1, 0.25, 0.85},
        radius = 14, speed = 90, hp = 70,
        damage = 14, score = 35, behavior = "splitter"
    },
    boss = {
        color = {1, 0.1, 0.1},
        color2 = {1, 0.8, 0.1},
        radius = 30, speed = 55, hp = 350,
        damage = 25, score = 500, behavior = "boss",
        fireRate = 1.3, fanCount = 7, fanSpread = math.rad(80)
    }
}

-- Waves
Constants.WAVE_BASE_ENEMIES = 5
Constants.WAVE_ENEMIES_PER_WAVE = 2
Constants.WAVE_BREAK_TIME = 3.5
Constants.WAVE_FIRST_BREAK = 1.5
Constants.WAVE_SPAWN_INTERVAL = 0.5
Constants.BOSS_WAVE_INTERVAL = 5  -- boss every 5 waves

-- Power-ups
Constants.POWERUP_RADIUS = 10
Constants.POWERUP_LIFETIME = 8
Constants.POWERUP_DROP_CHANCE = 0.25
Constants.POWERUP_BOSS_DROP_COUNT = 2
Constants.HEAL_AMOUNT = 25
Constants.SPEED_BOOST_DURATION = 5
Constants.RAPID_FIRE_DURATION = 5
Constants.MAGNET_DURATION = 6
Constants.MAGNET_RANGE = 180
Constants.MAGNET_PULL_SPEED = 320

-- Combo
Constants.COMBO_WINDOW = 2.5       -- seconds to keep combo (was 2.0)
Constants.COMBO_TIERS = {1, 2, 3, 5, 8}  -- multiplier tiers (added tier 5)
Constants.COMBO_TIER_KILLS = 3     -- kills per tier-up
Constants.COMBO_BREAK_DISPLAY = 1.5 -- seconds to show "COMBO BREAK"

-- Difficulty multipliers {speed, hp, damage, extraEnemyMult}
Constants.DIFFICULTY = {
    easy   = {speedMult = 0.7, hpMult = 0.65, damageMult = 0.6, enemyMult = 0.7},
    normal = {speedMult = 1.0,  hpMult = 1.0,  damageMult = 1.0,  enemyMult = 1.0},
    hard   = {speedMult = 1.35, hpMult = 1.6,  damageMult = 1.4,  enemyMult = 1.4}
}
Constants.DIFFICULTY_LIST = {"easy", "normal", "hard"}

-- Audio
Constants.SFX_VOLUME = 0.3

-- Screen shake
Constants.SCREEN_SHAKE_MAX_OFFSET = 6
Constants.SCREEN_SHAKE_DECAY_RATE = 8
Constants.SCREEN_SHAKE_ENEMY_HIT = 2
Constants.SCREEN_SHAKE_PLAYER_HIT_BULLET = 3
Constants.SCREEN_SHAKE_PLAYER_HIT_CONTACT = 4
Constants.SCREEN_SHAKE_BOSS_KILL = 6
Constants.SCREEN_SHAKE_OPTIONS = {"off", "low", "full"}
Constants.SCREEN_SHAKE_MULT = {off = 0, low = 0.4, full = 1.0}

-- Collision
Constants.ENEMY_KNOCKBACK_DIST = 30
Constants.AOE_DAMAGE_MULT = 0.5

-- Spawn safety
Constants.SPAWN_FADE_IN_DURATION = 1.0  -- seconds to fade in
Constants.SPAWN_GRACE_DURATION = 0.8    -- seconds before enemy can deal contact damage
Constants.SPAWN_SAFE_RADIUS = 120       -- minimum distance from player when spawning

-- Entity limits
Constants.MAX_BULLETS = 200
Constants.MAX_PARTICLES = 300
Constants.MAX_POWERUPS = 15

-- Screen flash
Constants.SCREEN_FLASH_DURATION = 0.15

-- Background
Constants.GRID_SPACING = 40
Constants.STAR_COUNT_SLOW = 30
Constants.STAR_COUNT_FAST = 20

-- Key bindings (remap plan: change values here to rebind)
Constants.KEY_BINDINGS = {
    move_up    = {"w", "up"},
    move_down  = {"s", "down"},
    move_left  = {"a", "left"},
    move_right = {"d", "right"},
    pause      = {"escape"},
    restart    = {"r"},
    quit       = {"q"},
    fullscreen = {"f11"},
    confirm    = {"return", "kpenter"},
}

return Constants
