--- FontManager: centralised font loading & access.
--  To change the font family, update FONT_DIR and STYLES.
--  To change sizes, update SIZES.
--  Every module that needs a font should call FontManager.get(styleName, sizeName).

local FontManager = {}

-- ── Configuration ──────────────────────────────────────────────────
-- Font directory (relative to the Project root that love.filesystem sees)
FontManager.FONT_DIR = "fonts/"

-- Map of weight names → .ttf file names inside FONT_DIR.
-- Add or remove entries when you swap font families.
FontManager.STYLES = {
    thin       = "Lexend-Thin.ttf",
    extralight = "Lexend-ExtraLight.ttf",
    light      = "Lexend-Light.ttf",
    regular    = "Lexend-Regular.ttf",
    medium     = "Lexend-Medium.ttf",
    semibold   = "Lexend-SemiBold.ttf",
    bold       = "Lexend-Bold.ttf",
    extrabold  = "Lexend-ExtraBold.ttf",
    black      = "Lexend-Black.ttf",
}

-- Named sizes used throughout the game.
FontManager.SIZES = {
    small  = 14,
    med    = 20,
    big    = 32,
}

-- Default style when none is specified.
FontManager.DEFAULT_STYLE = "regular"

-- ── Internal cache ─────────────────────────────────────────────────
-- cache[style][size] = Font object
local cache = {}

-- ── API ────────────────────────────────────────────────────────────

--- Get (or create) a font for the given style and size.
---@param style  string|nil  Weight name from STYLES (default: DEFAULT_STYLE)
---@param size   string|number  Named size from SIZES or a raw pixel number
---@return love.Font
function FontManager.get(style, size)
    style = style or FontManager.DEFAULT_STYLE
    local px = type(size) == "string" and FontManager.SIZES[size] or size
    assert(px, "FontManager: unknown size '" .. tostring(size) .. "'")

    cache[style] = cache[style] or {}
    if not cache[style][px] then
        local file = FontManager.STYLES[style]
        assert(file, "FontManager: unknown style '" .. tostring(style) .. "'")
        cache[style][px] = love.graphics.newFont(FontManager.FONT_DIR .. file, px)
    end
    return cache[style][px]
end

--- Shorthand accessors using DEFAULT_STYLE.
function FontManager.small()    return FontManager.get(nil, "small") end
function FontManager.med()      return FontManager.get(nil, "med")   end
function FontManager.big()      return FontManager.get(nil, "big")   end

--- Flush the cache (e.g. after changing FONT_DIR / STYLES at runtime).
function FontManager.clearCache()
    cache = {}
end

return FontManager
