--[[
    Theme
    Design tokens and color system
]]

local Theme = {}

-- Color palette
Theme.colors = {
    background = Color3.fromRGB(27, 32, 40),      -- #1b2028
    surface = Color3.fromRGB(52, 64, 79),         -- #34404f
    surfaceLight = Color3.fromRGB(56, 70, 90),    -- #38465a

    text = Color3.fromRGB(228, 234, 245),         -- #e4eaf5
    textMuted = Color3.fromRGB(152, 171, 197),    -- #98abc5
    textDim = Color3.fromRGB(145, 161, 182),      -- #91a1b6

    accent = Color3.fromRGB(128, 173, 250),       -- #80adfa (default)
    accentDim = Color3.fromRGB(134, 152, 177),    -- #8698b1

    border = Color3.fromRGB(188, 207, 234),       -- #bccfea at 15% opacity
    borderBright = Color3.fromRGB(201, 218, 250), -- #c9dafa at 21% opacity

    white = Color3.fromRGB(255, 255, 255),
    black = Color3.fromRGB(0, 0, 0),
}

-- Opacity values (0-1)
Theme.opacity = {
    border = 0.15,
    borderBright = 0.21,
    muted = 0.85,
    dim = 0.6,
    subtle = 0.08,
}

-- Spacing
Theme.spacing = {
    xs = 5,
    sm = 8,
    md = 12,
    lg = 15,
    xl = 18,
    xxl = 22,
}

-- Typography
Theme.typography = {
    size = {
        xs = 9,
        sm = 10,
        md = 11,
        base = 12,
        lg = 13,
        title = 19,
        heading = 24,
    },
    weight = {
        regular = Enum.FontWeight.Regular,
        medium = Enum.FontWeight.Medium,
        semibold = Enum.FontWeight.SemiBold,
    },
    font = Enum.Font.GothamMedium,
}

-- Corner radius (configurable via config.radius)
Theme.radius = {
    sm = 3,
    md = 5,
    lg = 8,
    xl = 12,
}

-- Animation
Theme.animation = {
    -- Durations in seconds (scaled by config.speed)
    duration = {
        instant = 0.001,
        fast = 0.14,
        normal = 0.22,
        slow = 0.36,
        slower = 0.5,
    },
    -- Easing
    easing = Enum.EasingStyle.Cubic,
    direction = Enum.EasingDirection.Out,
}

-- Z-Index layers
Theme.zIndex = {
    background = 1,
    content = 2,
    overlay = 3,
    modal = 4,
    tooltip = 5,
}

-- Helper: Create color with transparency
function Theme.withAlpha(color, alpha)
    return Color3.new(
        color.R * alpha,
        color.G * alpha,
        color.B * alpha
    )
end

-- Helper: Blend two colors
function Theme.blend(color1, color2, ratio)
    return Color3.new(
        color1.R + (color2.R - color1.R) * ratio,
        color1.G + (color2.G - color1.G) * ratio,
        color1.B + (color2.B - color1.B) * ratio
    )
end

return Theme
