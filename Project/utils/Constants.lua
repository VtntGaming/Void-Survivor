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
        radius = 10, speed = 120, hp = 50,
        damage = 15, score = 10, behavior = "chase"
    },
    shooter = {
        color = {0.7, 0.2, 1},
        radius = 11, speed = 70, hp = 40,
        damage = 10, score = 20, behavior = "shoot",
        fireRate = 1.5, preferredDist = 200
    },
    tank = {
        color = {1, 0.6, 0.1},
        radius = 18, speed = 50, hp = 150,
        damage = 25, score = 30, behavior = "chase"
    },
    speeder = {
        color = {1, 1, 0.2},
        radius = 8, speed = 220, hp = 25,
        damage = 10, score = 15, behavior = "chase"
    },
    boss = {
        color = {1, 0.1, 0.1},
        color2 = {1, 0.8, 0.1},
        radius = 30, speed = 60, hp = 500,
        damage = 30, score = 500, behavior = "boss",
        fireRate = 0.8, fanCount = 5, fanSpread = math.rad(60)
    }
}

-- Waves
Constants.WAVE_BASE_ENEMIES = 5
Constants.WAVE_ENEMIES_PER_WAVE = 2
Constants.WAVE_BREAK_TIME = 5
Constants.WAVE_FIRST_BREAK = 2
Constants.WAVE_SPAWN_INTERVAL = 0.5
Constants.BOSS_WAVE_INTERVAL = 5  -- boss every 5 waves

-- Power-ups
Constants.POWERUP_RADIUS = 10
Constants.POWERUP_LIFETIME = 8
Constants.POWERUP_DROP_CHANCE = 0.25
Constants.POWERUP_BOSS_DROP_COUNT = 2
Constants.HEAL_AMOUNT = 25

-- Combo
Constants.COMBO_WINDOW = 2.0       -- seconds to keep combo
Constants.COMBO_TIERS = {1, 2, 4, 8}  -- multiplier tiers
Constants.COMBO_BREAK_DISPLAY = 1.5 -- seconds to show "COMBO BREAK"

-- Difficulty multipliers {speed, hp, damage, extraEnemyMult}
Constants.DIFFICULTY = {
    easy   = {speedMult = 0.75, hpMult = 0.75, damageMult = 0.75, enemyMult = 0.8},
    normal = {speedMult = 1.0,  hpMult = 1.0,  damageMult = 1.0,  enemyMult = 1.0},
    hard   = {speedMult = 1.3,  hpMult = 1.5,  damageMult = 1.3,  enemyMult = 1.3}
}
Constants.DIFFICULTY_LIST = {"easy", "normal", "hard"}

-- Audio
Constants.SFX_VOLUME = 0.3

-- Background
Constants.GRID_SPACING = 40
Constants.STAR_COUNT_SLOW = 30
Constants.STAR_COUNT_FAST = 20

return Constants
